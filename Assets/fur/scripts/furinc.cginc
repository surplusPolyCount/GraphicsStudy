// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    //half3 worldRefl : TEXCOORD1;
    float4 vertex : SV_POSITION;
    float3 normal : NORMAL;
    float4 diff : COLOR0;
};

sampler2D _MainTex;
sampler2D _FurTex;
sampler2D _FurRandomHM;
SamplerState sampler_linear_repeat;
SamplerState sampler_MainTex;
float _MaxHairL;
float _GravityAffect;
float4 _HairGravity;





v2f vert(appdata v)
{
    v2f o;
    o.uv = v.uv;
    
    //float3 vGravity = mul(float3(0.0, -1.0, 0.0), unity_WorldToObject);
    float3 vGravity = normalize(_HairGravity.xyz) * _GravityAffect;

    //float s_rand = tex2Dlod(_FurRandomHM, float4(o.uv, 0, 0)).x;
    float s = tex2Dlod(_FurTex, float4(o.uv, 0, 0)).r;
    //use tex2Dlod cause cant sample a texture2d in vertex shader
    
    float  k = pow(CURRENTLAYER, 3);
    //float curveAmt = clamp(pow(CURRENTLAYER, 1.01), 0, 2);
    float3 pos = v.vertex + ((v.normal + vGravity) * _MaxHairL * k * s);
   
    o.vertex = UnityObjectToClipPos(float4(pos, 1.0));
    o.normal = normalize(mul(v.normal, unity_ObjectToWorld));

    float nl = max(dot(o.normal, _WorldSpaceLightPos0), 0.0); //https://docs.unity3d.com/560/Documentation/Manual/SL-VertexFragmentShaderExamples.html
    fixed4 diff = nl * _LightColor0;
    diff.rgb += ShadeSH9(half4(o.normal, 1));
    o.diff = diff;
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    // sample the texture
    fixed4 furMap = tex2Dlod(_FurTex, float4(i.uv, 0, 0));
    fixed4 col = tex2D(_MainTex, i.uv); 
    if (furMap.r <= 0.05) {
        col = fixed4(0.0,0.0,0.0,0.0);
    }
    else if (furMap.a == 0.0) {
        col[3] = 0.0;
    }

    float shadow = lerp(0.0, 1.0, CURRENTLAYER);
    col.rgb *= i.diff;
    col.rgb *= shadow;    
    return col;
}


v2f vertBase(appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    half3 worldNormal = UnityObjectToWorldNormal(v.normal);
    float nl = max(dot(worldNormal, _WorldSpaceLightPos0), 0.0); //https://docs.unity3d.com/560/Documentation/Manual/SL-VertexFragmentShaderExamples.html
    fixed4 diff = nl * _LightColor0;
    diff.rgb += ShadeSH9(half4(worldNormal, 1));
    o.diff = diff; 
    return o;
}


fixed4 fragBase(v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);


    col.rgb *= i.diff;
   // col.rgb += skyColor * 0.01;
    
    return col;
}


/*
* OLD VERSIONS
*/
/*
v2f vert(appdata v)
{
    v2f o;
    float3 pos = v.vertex + v.normal * CURRENTLAYER * _MaxHairL;
    o.vertex = UnityObjectToClipPos(pos);
    o.uv = v.uv;
    //o.uv = TRANSFORM_TEX(v.uv, _FurTex);
    o.normal = v.normal;
    //UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    // sample the texture
    fixed4 col = fixed4(0,0,0,0);

        col = tex2D(_FurTex, i.uv);
        fixed3 lightDir = fixed3(0.1, -1, -0.1);
        fixed3 ld = normalize(lightDir);
        float diff = max(dot(i.normal, ld), 0.25);
        float shadow = lerp(0.3, 1.0, CURRENTLAYER);
        col.rgb *= diff;
        col.rgb *= shadow;

    return col;
}


v2f vertBase(appdata v)
{
    v2f o;
    float3 pos = v.vertex;
    o.vertex = UnityObjectToClipPos(pos);
    o.uv = v.uv;
    //o.uv = TRANSFORM_TEX(v.uv, _FurTex);
    o.normal = v.normal;
    //UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}

fixed4 fragBase(v2f i) : SV_Target
{
    // sample the texture
    fixed4 col = tex2D(_MainTex, i.uv);
    fixed3 ld = normalize(fixed3(0.1, -1, -0.1));
    float diff = max(dot(i.normal, ld), 0.25);
    float shadow = lerp(0.3, 1.0, CURRENTLAYER);
    col.rgb *= diff;

    return col;
}

*/
