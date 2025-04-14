// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/toonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutLineColor("Outline color", Color) = (0.5, 0.5, 0.5)
       // _ShadowPartitions("range of shadow values", Int) = 2
        _OuterEdgeWidth("width of outer outline", Range(0,1)) = 0.01
        _InnerEdgeWidth("width of inner outline", Range(0,1)) = 0.35 
        //DARKEST SHADOW
        _ShadowStep1Stength("how dark do you wanna make the shadow",Range(0,1)) = 0.5
        _ShadowStep1Trigger("at what percentage of reflection from normal do we want to trigger this?", Range(0,1)) = 0.5
        //MIDTONE SHADOW
        _ShadowStep2Stength("how dark do you wanna make the shadow",Range(0,1)) = 0.75
        _ShadowStep2Trigger("at what percentage of reflection from normal do we want to trigger this?", Range(0,1)) = 0.75
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


            
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 norm : TEXCOORD1;  //world normal
                float3 wvd : TEXCOORD2;
            };
            float _OuterEdgeWidth;
            v2f vert (appdata v)
            {
                v2f o;
                o.norm = normalize(UnityObjectToWorldNormal(v.normal));
                o.vertex = UnityObjectToClipPos(v.vertex) + float4(o.norm * -1 *_OuterEdgeWidth,0);
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.wvd = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }
            half4 _OutLineColor; 
            fixed4 frag(v2f i) : SV_Target
            {
                return _OutLineColor;
            }

            ENDCG
        }

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
            float _InnerEdgeWidth; 
            float _ShadowStep1Stength; 
            float _ShadowStep1Trigger;
            float _ShadowStep2Stength; 
            float _ShadowStep2Trigger;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.norm = normalize(UnityObjectToWorldNormal(v.normal));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.wvd = normalize(WorldSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //BASE COLOR 
                fixed4 col = tex2D(_MainTex, i.uv);



                float nl = max(dot(i.norm, _WorldSpaceLightPos0), 0.0); //https://docs.unity3d.com/560/Documentation/Manual/SL-VertexFragmentShaderExamples.html

                float lightAmt = 1.0;
                if(nl < _ShadowStep1Trigger){
                    lightAmt *= _ShadowStep1Stength;
                }
                else if(nl < _ShadowStep2Trigger){
                    lightAmt *= _ShadowStep2Stength;
                }

                //https://roystan.net/articles/toon-shader.html
                float rimDot = 1-dot(i.wvd, i.norm);
                //float rimDot = 1-dot(float3(0,0,1),i.norm);
                float rimIntensity = smoothstep(_InnerEdgeWidth - 0.01, _InnerEdgeWidth + 0.01, rimDot);
                if(rimIntensity != 1){
                    col *= (lightAmt);
                }

                return col;
            }
            ENDCG
        }  
    }
}
