// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/FirstShader"
{
	Properties{
		_Tint("Tint", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_MainTex_ST("Offset and Tilling", Color) = (1,1,0,0)
	}
	SubShader{
		Pass {
			CGPROGRAM 

			//declare which functions are vertex and fragment programs (aka functions)
			#pragma vertex MyVertexProgram 
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc" 

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			//create a data type that holds all data to be passed into fragment shader
			struct Interpolators {
				float4 position : SV_POSITION; 
				float2 uv : TEXCOORD0;
				//float3 localPosition : TEXCOORD0;
			};

			//create a data type that holds all data to be passed into fragment shader
			struct VertexData {
				float4 position : POSITION; 
				float2 uv : TEXCOORD0;
			};

			//returns struct that will be passed into the FragmentShader
			Interpolators MyVertexProgram(VertexData v){
				Interpolators i;
				//i.localPosition = v.position.xyz;
				
				//get the position of mesh into rendered space instead of mesh local space
				i.position = UnityObjectToClipPos(v.position); //in Tut it's: mul(UNITY_MATRIX_MVP, position);
				
				//same as v.uv * _MainTex_ST.xy + _MainTex_ST.zw (xy is Scale zw is Translate hense ScaleTranslate/ST)
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return i;
			}
			float4 MyFragmentProgram(Interpolators i) : SV_TARGET {
				return tex2D(_MainTex, i.uv) * _Tint;
			}
			ENDCG
		}
	}
}
