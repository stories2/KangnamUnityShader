Shader "Custom/FresnelShader"
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
        #pragma surface surf Toon 

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
            o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        
        float4 LightingToon (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten) {
            float nDotL = dot(s.Normal, lightDir) * .5 + .5;
            nDotL = nDotL * 5;
            nDotL = ceil(nDotL) / 5;
            // 5단계 카툰 음영

            float rim = abs(dot(s.Normal, viewDir));
            rim = rim > 0.3 ? 1 : 0;
            // rim lighting 자기가 바라보는 곳을 빛 대신 계산 하여 엣지 계산

            float4 final;
            final.rgb = s.Albedo * nDotL * _LightColor0.rgb * rim;
            final.a = s.Alpha;

            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
