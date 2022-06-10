// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/FirstLightShader"
{

	Properties{
		_Tint("Tint", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_SpecularTint("Specular", Color) = (0.5, 0.5, 0.5)
		[Gamma] _Metallic("Metallic", Range(0, 1)) = 0
		_Smoothness("Smoothness", Range(0,1)) = 0.5
	}
		SubShader{
			Pass {
				Tags{
					"LightMode" = "ForwardBase"
				}

			CGPROGRAM

			//declare which functions are vertex and fragment programs (aka functions)
			#pragma vertex MyVertexProgram 
			#pragma fragment MyFragmentProgram

			#include "UnityStandardBRDF.cginc"
			#include "UnityStandardUtils.cginc"

			float _Metallic; 
			float4 _SpecularTint; 
			float _Smoothness;
			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;


			//create a data type that holds all data to be passed into vertex shader
			//pulls data from actual mesh
			struct VertexData {
				float4 position : POSITION; 
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			//create a data type that holds all data to be passed into fragment shader
			struct Interpolators {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2; 
			};

			//returns struct that will be passed into the FragmentShader
			Interpolators MyVertexProgram(VertexData v){
				Interpolators i;
				//i.localPosition = v.position.xyz;
				
				//get the position of mesh into rendered space instead of mesh local space
				i.worldPos = mul(unity_ObjectToWorld, v.position);
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.position = UnityObjectToClipPos(v.position); //in Tut it's: mul(UNITY_MATRIX_MVP, position);
				
				i.normal = UnityObjectToWorldNormal(v.normal);
				/*ALTERNATIVE IS TO:
				i.normal = mul(
					transpose((float3x3)unity_WorldToObject), 
					v.normal
				);
				i.normal = normalize(i.normal);*/
				return i;
			}

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET{
				//re normalize because normals will be interpolated resulting in varying magnitudes for vectors
				i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 halfVector = normalize(lightDir + i.normal);
				float3 lightColor = _LightColor0.rgb; 
			

				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
				float3 specularTint;
				float oneMinusReflectivity;
				albedo = DiffuseAndSpecularFromMetallic(
					albedo, _Metallic, specularTint, oneMinusReflectivity
				);				
				float3 diffuse =
					albedo * lightColor * DotClamped(lightDir, i.normal);

				float3 specular = specularTint * lightColor * pow(
					DotClamped(halfVector, i.normal),
					_Smoothness * 100
				);
				return float4(diffuse + specular, 1);
			}
			ENDCG
		}
	}
}
