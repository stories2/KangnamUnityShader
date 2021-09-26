Shader "Custom/CheckerMap"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Speed ("Speed", Range(0, 10)) = 1
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
        float _Speed;

        struct Input
        {
            float2 uv_MainTex;
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
            fixed4 c = tex2D (_MainTex, float2(IN.uv_MainTex.x + _Time.y * _Speed, IN.uv_MainTex.y + _Time.y * _Speed));
            o.Emission = IN.uv_MainTex.x;
            o.Emission = float3(IN.uv_MainTex.x, IN.uv_MainTex.y, 0); // RGB Texture 좌표계
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
