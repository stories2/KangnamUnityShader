Shader "Custom/AlphaBlending2pass"
{
    Properties
    {
        _MainTex ("Main text", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        // 실제 화면상엔 렌덩링 하지 않고, z-buffer 에만 렌더링
        zwrite on
        ColorMask 0
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf nolight noambient noforwardadd nolightmap novertexlights noshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        struct Input
        {
            float4 color:COLOR;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
        }

        float4 Lightingnolight (SurfaceOutput s, float3 lightDir, float atten) {
            return float4(0, 0, 0, 0);
        }
        ENDCG

        // 위에서 그린 zbuffer 를 사용하여 렌더링
        // 결과적으론 오버랩이 되어지지 않는 효과
        zwrite off
        CGPROGRAM
        #pragma surface surf Lambert alpha:fade

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };
        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = 0.5;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
