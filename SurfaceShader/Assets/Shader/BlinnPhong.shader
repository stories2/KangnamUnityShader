Shader "Custom/BlinnPhong"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NormalTex ("Normal", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Test

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalTex;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            float4 n = tex2D (_NormalTex, IN.uv_NormalTex);
            o.Normal = UnpackNormal(n);
            o.Albedo = c.rgb;
            o.Gloss = n.a;
            // Metallic and smoothness come from slider variables
            // o.Metallic = _Metallic;
            // o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }

        float4 LightingTest (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten) {
            // float nDotL = dot(s.Normal, lightDir);
            // 기본 내적 결과 1 ~ -1
            // float nDotL = dot(s.Normal, lightDir) * .5f + .5f;
            // 내적 결과에 Half-Lambert equation 1 ~ 0
            // 하지만 너무 완화 되어서 물리적 효과랑은 거리감이 있는 빛의 형태가 나옴
            float nDotL = pow(dot(s.Normal, lightDir) * .5f + .5f, 2);
            // 제곱을 하면 어두운건 자연스럽게 어두워지고 밝은건 자연스럽게 밝아짐

            float3 halfVec = normalize(lightDir + viewDir);
            float3 specular = saturate(dot(halfVec, s.Normal));
            return float4(pow(specular, 100) * s.Gloss, 1);

            float4 final;
            final.rgb = nDotL * s.Albedo * _LightColor0.rgb * atten;
            // _LightColor0 조명의 강도, 색상
            // atten 조명과 본 사물간 거리가 멀면 조명이 약할것이고 가까우면 강할 것
            final.a = s.Alpha;
            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
