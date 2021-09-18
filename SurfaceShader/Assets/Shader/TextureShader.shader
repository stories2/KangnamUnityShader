Shader "Custom/TextureShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainTex2 ("Albedo2 (RGB)", 2D) = "white" {}
        _LerpRange ("Lerp range", Range(0, 1)) = 0
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
        sampler2D _MainTex2;

        float _LerpRange;

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
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 c2 = tex2D (_MainTex2, IN.uv_MainTex2);
            // o.Albedo = (c.r + c.g + c.b) / 3;
            // o.Albedo = c.rgb;
            o.Albedo = lerp(c2.rgb, c.rgb, c2.a); // c2의 투명도가 없는 부분만 c 텍스쳐 정보를 사용
            // o.Albedo = lerp(c2.rgb, c.rgb, 1 - c2.a); 이 경우는 1이 c 를 가리킬텐데 1 - c2.a 하면 c2.a 가 0일땐 기존 c 텍스쳐가 보이고 c2.a 가 1일땐 0 이 되어버리므로 c2 가 보임 
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
