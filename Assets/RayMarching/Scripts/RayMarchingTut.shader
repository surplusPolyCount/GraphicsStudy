// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/RayMarchingTut"
{
    Properties
    {
       // _MainTex ("Texture", 2D) = "white" {}
    }
        SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "RayMarching.cginc"

            uniform float4x4 _FrustumCornersES; 
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_TexelSize; 
            uniform float4x4 _CameraInvViewMatrix; 
            uniform float4x4 _MatSphere_M;
            uniform float4x4 _MatSphere_M1;
            uniform float4x4 _MatSphere_M2;
            uniform float3 _CameraWS; //ray origin aka cam pos 

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 ray : TEXCOORD1; 
            };

            float sphere(float3 p, float3 o, float r)
            {
                return length(o - p) - r;
            }



            float BeerLambert(float absorptionCoefficient, float distanceTraveled)
            {
                return exp(-absorptionCoefficient * distanceTraveled);
            }
            //https://timcoster.com/2020/02/13/raymarching-shader-pt3-smooth-blending-operators/
            float smoothUnionSDF(float distA, float distB, float k)
            {
                float h = clamp(0.5 + 0.5 * (distA - distB) / k, 0., 1.);
                return lerp(distA, distB, h) - k * h * (1. - h);
            }

            float opU(float d1, float d2)
            {
                return min(d1, d2);
            }

            // Subtraction
            // Adapted from: http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
            float opS(float d1, float d2)
            {
                return max(-d1, d2);
            }

            // Intersection
            // Adapted from: http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
            float opI(float d1, float d2)
            {
                return max(d1, d2);
            }

            //https://iquilezles.org/articles/distfunctions/
            float sdTorus(float3 p, float2 t)
            {
                float2 q = float2(length(p.xz) - t.x, p.y);
                return length(q) - t.y;
            }

            float map(float3 p)
            {
                //return sdTorus(p, float2(1, 0.2)); 
                float s1 = sphere(p, float3(0, 0, 0), 1.0);
                float s2 = sphere(p, mul(_MatSphere_M, float4(0, 0.65f, 0, 1)), 0.65f);
                float s3 = sphere(p, mul(_MatSphere_M1, float4(0.0f, -0.75f, 0, 1)), 0.75);
                float s4 = sphere(p, mul(_MatSphere_M2, float4(0, 0.0f, 0.9f, 1)), 1.25f);
                return smoothUnionSDF(smoothUnionSDF(s1, s2, 0.35f), smoothUnionSDF(s3, s4, 0.35f), 0.35f);
            }
            float3 calcNormal(in float3 pos)
            {
                // epsilon - used to approximate dx when taking the derivative
                const float2 eps = float2(0.001, 0.0);

                // The idea here is to find the "gradient" of the distance field at pos
                // Remember, the distance field is not boolean - even if you are inside an object
                // the number is negative, so this calculation still works.
                // Essentially you are approximating the derivative of the distance field at this point.
                float3 nor = float3(
                    map(pos + eps.xyy).x - map(pos - eps.xyy).x,
                    map(pos + eps.yxy).x - map(pos - eps.yxy).x,
                    map(pos + eps.yyx).x - map(pos - eps.yyx).x);
                return normalize(nor);
            }
            
             
            fixed3 hash(fixed3 p3) //https://www.shadertoy.com/view/Wl2XzW
            {
                fixed3 HASHSCALE1 = fixed3(.1031, 0.1031, 0.1031);

	            p3 = frac(p3 * HASHSCALE1);
	            p3 += dot(p3, p3.yxz+19.19);
	            return frac((p3.xxy + p3.yxx)*p3.zyx);
            }

            fixed4 mod289(fixed4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
            fixed4 perm(fixed4 x) { return mod289(((x * 34.0) + 1.0) * x); }

            //https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
            float noise_c(fixed3 p) {
                fixed3 a = floor(p);
                fixed3 d = p - a;
                d = d * d * (3.0 - 2.0 * d);

                fixed4 b = a.xxyy + fixed4(0.0, 1.0, 0.0, 1.0);
                fixed4 k1 = perm(b.xyxy);
                fixed4 k2 = perm(k1.xyxy + b.zzww);

                fixed4 c = k2 + a.zzzz;
                fixed4 k3 = perm(c);
                fixed4 k4 = perm(c + 1.0);

                fixed4 o1 = frac(k3 * (1.0 / 41.0));
                fixed4 o2 = frac(k4 * (1.0 / 41.0));

                fixed4 o3 = o2 * d.z + o1 * (1.0 - d.z);
                fixed2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

                return o4.y * d.y + o4.x * (1.0 - d.y);
            }
            
            // DUMMY EXPENSIVE 
            /*
            float noise(in fixed3 x)
            {
                // grid
                fixed3 p = floor(x);
                fixed3 w = frac(x);

                // quintic interpolant
                fixed3 u = w * w * w * (w * (w * 6.0 - 15.0) + 10.0);


                // gradients
                fixed3 ga = hash(p + fixed3(0.0, 0.0, 0.0));
                fixed3 gb = hash(p + fixed3(1.0, 0.0, 0.0));
                fixed3 gc = hash(p + fixed3(0.0, 1.0, 0.0));
                fixed3 gd = hash(p + fixed3(1.0, 1.0, 0.0));
                fixed3 ge = hash(p + fixed3(0.0, 0.0, 1.0));
                fixed3 gf = hash(p + fixed3(1.0, 0.0, 1.0));
                fixed3 gg = hash(p + fixed3(0.0, 1.0, 1.0));
                fixed3 gh = hash(p + fixed3(1.0, 1.0, 1.0));

                // projections
                float va = dot(ga, w - fixed3(0.0, 0.0, 0.0));
                float vb = dot(gb, w - fixed3(1.0, 0.0, 0.0));
                float vc = dot(gc, w - fixed3(0.0, 1.0, 0.0));
                float vd = dot(gd, w - fixed3(1.0, 1.0, 0.0));
                float ve = dot(ge, w - fixed3(0.0, 0.0, 1.0));
                float vf = dot(gf, w - fixed3(1.0, 0.0, 1.0));
                float vg = dot(gg, w - fixed3(0.0, 1.0, 1.0));
                float vh = dot(gh, w - fixed3(1.0, 1.0, 1.0));

                // interpolation
                return va +
                    u.x * (vb - va) +
                    u.y * (vc - va) +
                    u.z * (ve - va) +
                    u.x * u.y * (va - vb - vc + vd) +
                    u.y * u.z * (va - vc - ve + vg) +
                    u.z * u.x * (va - vb - ve + vf) +
                    u.x * u.y * u.z * (-va + vb + vc - vd + ve - vf - vg + vh);
            }
           */
           
            // fbm https://iquilezles.org/articles/fbm/
            //SET H to be 1
            float fbm( in fixed3 x, in float H )
            {
                float G = exp2(-H);
                float f = 1.0;
                float a = 1.0;
                float t = 0.0;
                int numOctaves = 5; 
                for( int i=0; i<numOctaves; i++ )
                {
                    t += a*noise_c(f*x);
                    f *= 2.0;
                    a *= G;
                }
                return t;
            }
            

            fixed4 raymarch_N(float3 ro, float3 rd, float s)
            {
                fixed4 ret = fixed4(0, 0, 0, 0);
                float opaqueVis = 1.0f;

                const int maxstep = 64;
                float t = 0;

                for (int i = 0; i < maxstep; ++i)
                {

                    float3 p = ro + rd * t;
                    float d = map(p * (fbm(p, 0.5)));

                    if (d < 0.001)
                    {
                        if (t >= s)
                        {
                            ret = fixed4(0.0, 0.0, 0.0, 0.0);
                            break;
                        }

                        float3 n = calcNormal(p);
                        float a = max(dot(n, _WorldSpaceLightPos0), 0.0);
                        ret = fixed4(fixed3(1.0, 0.0, 1.0) * a, 1);
                    }

                    t += d;
                }

                return ret;
            }
             
            fixed4 raymarch(float3 ro, float3 rd, float s)
            {
                fixed4 ret = fixed4(0, 0, 0, 0);

                const int maxstep = 64;
                float t = 0; //amount to travel along the ray

                for (int i = 0; i < maxstep; ++i)
                {

                    float3 p = ro + rd * t; //travel along ray 
                    float d = map(p); //check if distance traveled intersected with anything

                    if (t >= s) //if we have traveled past the maximum distance for this ray, 
                                //break and return transparent color 
                    {
                        ret = fixed4(0.0, 0.0, 0.0, 0.0);
                        break;
                    }

                    if (d < 0.001) //if we have essentially hit the object, 
                                   //return the color of the surface
                    {
                        float3 n = calcNormal(p);
                        float a = max(dot(n, _WorldSpaceLightPos0), 0.0);
                        ret = fixed4(fixed3(1.0, 0.0, 1.0) * a, 1);
                        break; 
                    }

                    t += d;
                }

                return ret;
            }

            fixed4 raymarch_V(float3 ro, float3 rd, float s)
            {
                fixed3 surf_albedo = fixed3(1.0, 0.0, 1.0);
                fixed4 volumetricColor = fixed4(0.0, 0.0, 0.0, 0.0);
                fixed4 ret = fixed4(0.0, 0.0, 0.0, 0.0);
                float opaqueVis = 1.0f;
                float volumeDepth = 0.0;
                float opaqueDepth = 1.0;
                //close to water absorbtio coefficient
                float ABSORPTION_COEFFICIENT = 0.6; //https://www.acoustic.ua/st/web_absorption_data_eng.pdf

                const float stepSize = 0.005f;
                const int maxstep = 1024;    
                float t = 0;
                bool hasVolume;
                for (int i = 0; i < maxstep; ++i)
                {
                    if (volumeDepth > opaqueDepth)
                        break;

                    float3 p = ro + rd * t;
                    float d = map(p);

                        if (t >= s)
                        {
                            return ret;
                        }
                        if (d < 0.0)
                        {
                            hasVolume = true;
                            float previousOpaqueVisiblity = opaqueVis;
                            opaqueVis *= BeerLambert(ABSORPTION_COEFFICIENT, stepSize);
                            float absorptionFromMarch = previousOpaqueVisiblity - opaqueVis;

                            //if (absorptionFromMarch <= 100.0) { break;  }

                            float lightDistance = length(_WorldSpaceLightPos0 - p);
                            float3 lightColor = float3(1.0, 1.0, 1.0) * (1 / (lightDistance * lightDistance));
                            volumetricColor += absorptionFromMarch * fixed4(surf_albedo * lightColor, 1.0);
                            if (absorptionFromMarch >= 1.0)
                                return ret; 

                        }

                    t += stepSize;
                }
                if (hasVolume) {
                    volumetricColor.w *= 1;
                    ret = volumetricColor;
                }
                return ret;
            }

            fixed4 raymarch_VN(float3 ro, float3 rd, float s)
            {
                fixed3 surf_albedo = fixed3(1.0, 0.0, 1.0);
                fixed4 volumetricColor = fixed4(0.0, 0.0, 0.0, 0.0);
                fixed4 ret = fixed4(0.0, 0.0, 0.0, 0.0);
                float opaqueVis = 1.0f;
                float volumeDepth = 0.0;
                float opaqueDepth = 1.0;
                //close to water absorbtio coefficient
                float ABSORPTION_COEFFICIENT = 0.1; //https://www.acoustic.ua/st/web_absorption_data_eng.pdf

                const float stepSize = 0.01f;
                const int maxstep = 512;
                float t = 0;
                bool hasVolume; 
                for (int i = 0; i < maxstep; ++i)
                {
                    if (volumeDepth > opaqueDepth)
                        break;

                    float3 p = ro + rd * t;
                    float d = map(p * (fbm(p, 0.5)));

                    if (t >= s)
                    {
                        return ret;
                    }



                        if (d < 0.0)
                        {
                            hasVolume = true; 
                            float previousOpaqueVisiblity = opaqueVis;
                            opaqueVis *= BeerLambert(ABSORPTION_COEFFICIENT, stepSize);
                            float absorptionFromMarch = previousOpaqueVisiblity - opaqueVis;

                            float lightDistance = length(_WorldSpaceLightPos0 - p);
                            float3 lightColor = float3(1.0, 1.0, 1.0) * (1 / (lightDistance * lightDistance));
                            volumetricColor += absorptionFromMarch * fixed4(surf_albedo * lightColor, 1.0);

                        }
                  

                    t += stepSize;
                }
                if (hasVolume) {
                    volumetricColor.w *= 10;
                    ret = volumetricColor;
                }
                return ret;
            }

            v2f vert (appdata v)
            {
                v2f o;
                
                half index = v.vertex.z; 
                v.vertex.z = 0.1; 

                o.pos = UnityObjectToClipPos(v.vertex); 
                o.uv = v.uv.xy; 

                #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                    o.uv.y = 1 - o.uv.y; 
                #endif

                o.ray = _FrustumCornersES[(int)index].xyz; 
                o.ray /= abs(o.ray.z); 

                o.ray = mul(_CameraInvViewMatrix, o.ray); 
                return o; 
            }
            sampler2D _CameraDepthTexture;

            fixed4 frag(v2f i) : SV_Target
            {
                float3 rd = normalize(i.ray.xyz); 
                float3 ro = _CameraWS; 

                float2 duv = i.uv; 
                #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                    duv.y = 1 - duv.y;
                #endif

                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, duv).r);        
                depth *= length(i.ray.xyz);

                fixed3 col = tex2D(_MainTex, i.uv); 
                //fixed4 add = raymarch(ro, rd, depth);
                //fixed4 add = raymarch_V(ro, rd, depth);
                //fixed4 add = raymarch_N(ro, rd, depth);
                fixed4 add = raymarch_VN(ro, rd, depth);

                return fixed4(col * (1.0 - add.w) + add.xyz * add.w, 1.0);
            }
            ENDCG
        }
    }
}
