// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/TextureWithDetail"
{
	Properties{
		_Tint("Tint", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_DetailTex("Detail Texture", 2D) = "gray" {}
		//_MainTex_ST("Offset and Tilling", Color) = (1,1,0,0)
	}
	SubShader{
		Pass {
			CGPROGRAM 

			//declare which functions are vertex and fragment programs (aka functions)
			#pragma vertex MyVertexProgram 
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc" 

			sampler2D _MainTex, _DetailTex;
			float4 _MainTex_ST, _DetailTex_ST;

			//create a data type that holds all data to be passed into fragment shader
			struct Interpolators {
				float4 position : SV_POSITION; 
				float2 uv : TEXCOORD0;
				float2 uvDetail : TEXCOORD1;
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
				i.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
				return i;
			}
			float4 MyFragmentProgram(Interpolators i) : SV_TARGET {
				float4 color = tex2D(_MainTex, i.uv);

			//ADD detail to base diffuse texture through tiling gray scale texture 
			//we enable mip map fadeout on the detail texture to make it only render detail near camera (where ratio of pixels/texels is small) 

				//we mulitplied color by texture with 10x larger tile size to layer the texture over itself
				//we multiplied all of that by 2 to brighten the image (blending two textures together makes darker than they are individually)
				//this is because values are centered around 0, making it easy to brighten but harder to darken
				//to darken and lighten, detail textures should be centered around 0.5 (solid grey)
					//doubling grey values gets pure white
					//but anything less than one darkens 
				color *= tex2D(_DetailTex, i.uvDetail) * unity_ColorSpaceDouble;
				//unity_ColorSpaceDouble is used to adjust light & dark for switching between gamma and linear color space
					//NOTE still dont really know the difference: 
					//linear: ?
					//gamma: ?
				return color; 
			}
			ENDCG
		}
	}
}
