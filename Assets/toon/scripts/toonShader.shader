// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/toonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowPartitions("range of shadow values", Int) = 2
        _EdgeWidth("width of outline", Range(0,1)) = 0.35 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100


        //Shading 
            
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 norm : TEXCOORD1;  //world normal
                float3 wvd : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _ShadowPartitions;
            float _EdgeWidth; 

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.norm = normalize(UnityObjectToWorldNormal(v.normal));
                //o.normal = normalize(mul(v.normal, unity_ObjectToWorld));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.wvd = normalize(WorldSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float lightAmt = 1.0;
                float shadow_step =  float(1.0)/float(_ShadowPartitions);
                float nl = max(dot(i.norm, _WorldSpaceLightPos0), 0.0); //https://docs.unity3d.com/560/Documentation/Manual/SL-VertexFragmentShaderExamples.html


                if (nl == 0.0) {
                    lightAmt = 0.0;
                }
                else {
                    while (lightAmt - shadow_step >= nl) {
                        lightAmt = lightAmt - shadow_step;
                    }
                }

                //https://roystan.net/articles/toon-shader.html
                float rimDot = dot(i.wvd, i.norm);
                float rimIntensity = smoothstep(_EdgeWidth - 0.01, _EdgeWidth + 0.01, rimDot);
                float4 rim = rimIntensity * float4(1.0, 0.0, 0.0, 1.0);

                col *= lightAmt * rimIntensity;

                return col;
            }
            ENDCG
        }
       
    }
}
