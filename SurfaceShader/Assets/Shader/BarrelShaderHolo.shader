Shader "Custom/BarrelShaderHolo"
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
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient alpha:fade
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
            float3 worldPos;
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
            // o.Emission = _RimColor.rgb;
            o.Emission = _RimColor.rgb; 
            // IN.worldPos.g * 3 소숫점 반복 주기를 더 짧게 만듦
            // pow(, 30) 더 극적인 변화를 이용해 얇은 라인을 만듦
            // o.Albedo = c.rgb;
            // o.Alpha = rim * abs(sin(_Time.y * 3));
            o.Alpha = rim + pow(frac(IN.worldPos.g * 3 - _Time.y), 30);
            // 정리하면 빛 영향을 받지 않는 칼라 값은 _RimColor.rgb 로 결정이 되어 모두 칠해 지지만
            // 알파 값이 적용되어지는 부분이 사용자가 바라보는 방향에 따라서 밝음이 계산 될 것이고, 
            // 그 부분을 반전 시켜 엣지만 밝게 하였기 때문에 알파값이 적용된 가장자리만 색깔이 칠해질 것
            // 그 중에 worldPos, _Time.y 를 이용해 좌표와 시간을 이용해 색의 가중치를 결정한 후 반복 패턴을 위해 frac을 사용했고,
            // 줄 효과로 극적인 변화를 이용해 30제곱 으로 구현
        }
        ENDCG
    }
    FallBack "Diffuse"
}
