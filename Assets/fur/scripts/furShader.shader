Shader "Unlit/furShader"
{
    Properties
    {
        _MainTex ("Base Texture ~> actual color of fur and skin", 2D) = "white" {}
        _FurTex ("Fur Map ~> Establish where fur exists and it's height", 2D) = "white" {}
        _FurRandomHM("Fur Height Map Randomizer", 2D) = "white" {}
        //_FurHM("Fur Height Map", 2D) = "white" {}
        _MaxHairL("Max Hair Length", Range(0,1)) = 0.5
        _HairGravity("direction hair should go", Vector) = (0,0,0, 1)
        _GravityAffect("Max Pull of Gravity", Range(0,1)) = 0.1
        _HairL("Layer Count", int) = 25
    }
              
    SubShader
    {
        Tags 
        {
            "Queue" = "Transparent" 
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
            "LightMode" = "ForwardBase"
        }

        ZWrite ON
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
      
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBase
            #pragma fragment fragBase
            #define CURRENTLAYER 0.00
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.05
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.1
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.15
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.2
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.25
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.3
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

                Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.35
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.4
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.45
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.5
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.5
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }


            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.55
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.6
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }


            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.65
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }


            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.7
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }


            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.75
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.8
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.85
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.9
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 0.95
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }

            Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #define CURRENTLAYER 1.0
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "furinc.cginc"
            ENDCG
        }
        
    }
}
