Shader "Custom/Cubemap"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Cube ("Cube map", Cube) = "" {}
        _NormalTex ("Normal", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        samplerCUBE _Cube;
        sampler2D _NormalTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldRefl;
            float2 uv_NormalTex;
            float3 worldNormal;
            INTERNAL_DATA
            //vertex normal data -> pixel normal data 변환 행렬 
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

            o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
            
            float4 re = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal));
            // worldRef1 반사 벡터 , uv 가 반환됨

            o.Albedo = c.rgb;
            // Albedo 조명 영향 받는 색깔 
            o.Emission = re.rgb;
            // Emission 순수 색깔
            // o.Emission = o.Normal;
            // Normal map 시각화
            float3 pixelNormal = WorldNormalVector(IN, o.Normal);
            // Normal vec 를 반환함, INTERNAL_DATA 를 써야 픽셀 노말이 반환 
            o.Emission = pixelNormal;

            o.Albedo = c.rgb * .5;
            o.Emission = re.rgb * .5;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
