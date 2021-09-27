Shader "Custom/FireMat2"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainTex2 ("Albedo (RGB)", 2D) = "black" {}
        _YGap ("Y Gap", Range(0, 1)) = 0.035
        _Noise ("Noise", Range(0, 1)) = 0.59
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" } // Opaque 불투명, Transparent 투명
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:fade

        sampler2D _MainTex;
        sampler2D _MainTex2;
        float _YGap;
        float _Noise;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MainTex2;
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
            fixed4 d = tex2D (_MainTex2, float2(IN.uv_MainTex2.x, IN.uv_MainTex2.y - _Time.y));
            fixed4 c = tex2D (_MainTex, float2(IN.uv_MainTex.x, IN.uv_MainTex.y - _YGap) + d.r * _Noise); // 각 이미지 픽셀 위치 값을 다른 이미지의 red 칼라 크기 만큼 더한 위치로 이동시켜 렌더링
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
