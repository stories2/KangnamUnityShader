Shader "Custom/RefractionEffects"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RefStrength ("Ref strength", Range(0, 0.1)) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 200

        zwrite off
        GrabPass {}
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf nolight noambient alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _GrabTexture;

        float _RefStrength;

        struct Input
        {
            float2 uv_MainTex;
            float4 color:COLOR;
            float4 screenPos;
        };

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
            // o.Albedo = c.rgb;
            float3 screenUV = IN.screenPos.rgb / IN.screenPos.a;
            o.Emission = tex2D(_GrabTexture, screenUV.xy + c.x * _RefStrength);
            o.Alpha = c.a;
        }

        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(0, 0, 0, 1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
