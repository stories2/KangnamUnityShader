Shader "Custom/BarrelShaderRimLight"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normal map", 2D) = "white" {}
        _RimColor ("Rim color", Color) = (1, 1, 1, 1)
        _RimPower ("Rim power", Range(1, 10)) = 3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient 
        // noambient 기본 환경 값 조명을 사용하지 않고 순수 텍스쳐 컬러로만 표현

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float2 uv_BumpMap;
        };

        float4 _RimColor;
        float _RimPower;

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
            float rim = pow(1 - saturate(dot(o.Normal, IN.viewDir)), _RimPower); // 빛 계산 방향을 반대로 하여 겉 테두리가 밝고 가운데가 어두워지도록
            // 3제곱을 하면 선형 방식보단 극적인 변화가 일어남
            o.Emission = _RimColor.rgb * rim; 
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
