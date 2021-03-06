Shader "Custom/2WayPass"
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

        cull front
        // 1-pass
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Nolight vertex:vert noshadow noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 color:COLOR;
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
            // fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            // o.Albedo = c.rgb;
            // // Metallic and smoothness come from slider variables
            // o.Alpha = c.a;
            // 외곽선 텍스쳐 추가
        }

        void vert (inout appdata_full v) {
            // TODO: 두께 조절 인터페이스
            // TODO: sin(_Time.y) 이용해 두께던 색깔이던 실시간 변화
            v.vertex.xyz += v.normal.xyz * 0.005;
        }

        float4 LightingNolight(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(0, 0, 0, 1);
        }
        ENDCG

        cull back
        // 2-pass
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Toon noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalTex;
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
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }

        float4 LightingToon (SurfaceOutput s, float3 lightDir, float atten) {
            // half lambert
            float nDotL = dot(s.Normal, lightDir) * 0.5 + 0.5;
            // if (nDotL > 0.7) nDotL = 1.0;
            // else if (nDotL > 0.4) nDotL = 0.3;
            // else nDotL = 0.0;
            nDotL = nDotL * 5;
            nDotL = ceil(nDotL) / 5;

            float4 final;
            final.rgb = s.Albedo * nDotL * _LightColor0.rgb;
            final.a = s.Alpha;
            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
