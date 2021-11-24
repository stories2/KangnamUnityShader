Shader "Custom/BurningEffect"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex ("Noise tex", 2D) = "white" {}
        _Threshold ("Threshold", Range(0, 1)) = 0.5
        _OutThickness ("Out thickness", Range(1, 1.5)) = 1.15
        [HDR]_BurnColor ("Burn color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NoiseTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
        };

        float _Threshold;
        float _OutThickness;
        float4 _BurnColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 n = tex2D (_NoiseTex, IN.uv_NoiseTex);
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Alpha = n.r >= _Threshold ? 1 : 0;
            float outline = n.r >= _Threshold * _OutThickness ? 0 : 1;
            o.Emission = outline * _BurnColor;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/Cutout/VertexLit"
}
