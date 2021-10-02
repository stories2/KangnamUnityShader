Shader "Custom/NormalMap"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _Occlusion ("Occlusion", 2D) = "white" {}
        _Specular ("Specular", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _Occlusion;
        sampler2D _Specular;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float2 uv_Occlusion;
            float2 uv_Specular;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            float4 ao = tex2D (_Occlusion, IN.uv_Occlusion);
            float3 n = UnpackNormal(tex2D (_NormalMap, IN.uv_NormalMap));
            float4 s = tex2D(_Specular, IN.uv_Specular);
            o.Albedo = c.rgb;
            o.Normal = float3(n.x * 2, n.y * 2, n.z);
            o.Metallic = s * 3;
            o.Occlusion = ao;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
