Shader "Custom/DiffuseWarping"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NormalTex ("Normal", 2D) = "white" {}
        _RampTex ("Ramp", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Warp noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalTex;
        sampler2D _RampTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalTex;
            float2 uv_RampTex;
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

        float4 LightingWarp (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten) {
            float nDotL = dot(s.Normal, lightDir) * .5 + .5;

            float3 halfVec = normalize(lightDir + viewDir);
            float specular = saturate(dot(s.Normal, halfVec));

            // float4 ramp = tex2D (_RampTex, float2(nDotL, specular));

            float rim = abs(dot(s.Normal, viewDir));
            // rim = rim > 0.3 ? 1 : 0;
            float4 ramp = tex2D (_RampTex, float2(nDotL, rim));

            float4 final;
            final.rgb = s.Albedo.rgb * ramp.rgb * rim + ramp.rgb * 0.2;
            final.a = s.Alpha;

            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
