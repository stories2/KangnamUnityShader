Shader "Custom/Cobble"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("Normal map", 2D) = "white" {}
        _NormalScale ("Normal scale", Range(0, 10)) = 1.0
        _Occlusion ("Ambiant Occlusion", 2D) = "white" {}
        [Toggle] _OcclusionToggle ("Turn on / off occulsion", Int) = 1
        _Roughtness ("Roughtness", 2D) = "white" {}
        _RoughtnessScale ("Roughtness scale", Range(0, 1)) = 1.0
        [Enum(Base, 0, Base_Normal, 1, Base_Normal_AO, 2, Base_Normal_AO_Roughtness, 3)] _Options("Options", Int) = 0
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
        sampler2D _Roughtness;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float2 uv_Occlusion;
            float2 uv_Roughtness;
        };

        int _Options;
        float _NormalScale;
        int _OcclusionToggle;
        float _RoughtnessScale;

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
            if (_Options >= 1) {
                float3 normal = UnpackNormal(tex2D (_NormalMap, IN.uv_NormalMap));
                o.Normal = float3(normal.x * _NormalScale, normal.y * _NormalScale, normal.z);
            }
            if (_Options >= 2 && _OcclusionToggle) {
                o.Occlusion = tex2D(_Occlusion, IN.uv_Occlusion);
            }
            if (_Options >= 3) {
                o.Smoothness = tex2D(_Roughtness, IN.uv_Roughtness) * _RoughtnessScale;
            }
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
