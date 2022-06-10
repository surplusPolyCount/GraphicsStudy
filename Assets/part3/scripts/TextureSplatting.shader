// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/TextureSplatting"
{
	Properties{
		//splat map
		_MainTex("Texture", 2D) = "white" {}
			
		//two textures that we will be combining will inherit scaling and offset from splat map
		//and therefore not need to have their own ST properties
		[NoScaleOffset] _Texture1("Texture 1", 2D) = "white" {}
		[NoScaleOffset] _Texture2("Texture 2", 2D) = "white" {}
		[NoScaleOffset] _Texture3("Texture 3", 2D) = "white" {}
		[NoScaleOffset] _Texture4("Texture 4", 2D) = "white" {}
	}
	SubShader{
		Pass {
			CGPROGRAM 

			//declare which functions are vertex and fragment programs (aka functions)
			#pragma vertex MyVertexProgram 
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc" 

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _Texture1, _Texture2, _Texture3, _Texture4;

			//create a data type that holds all data to be passed into fragment shader
			struct Interpolators {
				float4 position : SV_POSITION; 
				float2 uv : TEXCOORD0;
				float2 uvSplat : TEXCOORD1;
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

				//to sample splat map, we have to pass unmodified uv from vertex program into frag prgm
				i.uvSplat = v.uv;
				return i;
			}
			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				float4 splat = tex2D(_MainTex, i.uvSplat);
				return
					tex2D(_Texture1, i.uv) * splat.r +
					tex2D(_Texture2, i.uv) * splat.g +
					tex2D(_Texture3, i.uv) * splat.b +
					tex2D(_Texture4, i.uv) * (1 - splat.r - splat.g - splat.b);
			}
			ENDCG
		}
	}
}
