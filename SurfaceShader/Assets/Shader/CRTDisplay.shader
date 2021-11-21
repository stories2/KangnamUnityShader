Shader "Custom/CRTDisplay"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _crt_curv_scale ("CRT Curv scale", Range(0, 1)) = 0.5
        _crt_curv_scale2 ("CRT Curv scale2", Range(0, 10)) = 4
        _crt_curv_scale3 ("CRT Curv scale3", Range(0, 5)) = 1.3
        _crt_size ("CRT Size", Range(0, 5)) = 1.1
        _crt_pow ("CRT POW", Range(1, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Test fullforwardshadows noambient alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };

        float _crt_curv_scale;
        float _crt_curv_scale2;
        float _crt_curv_scale3;
        float _crt_size;   
        float _crt_pow;     

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        float convertCurvedPosY (int quadrant, float x) {
            switch(quadrant) {
                case 1:
                    return (_crt_curv_scale / (x * _crt_curv_scale3 - _crt_curv_scale2)) + _crt_size;
                case 2:
                    return -(_crt_curv_scale / (x * _crt_curv_scale3 + _crt_curv_scale2)) + _crt_size;
                case 3:
                    return (_crt_curv_scale / (x * _crt_curv_scale3 + _crt_curv_scale2)) - _crt_size;
                case 4:
                    return -(_crt_curv_scale / (x * _crt_curv_scale3 - _crt_curv_scale2)) - _crt_size;
            }
        }

        float convertCurvedPosX (int quadrant, float y) {
            switch(quadrant) {
                case 1:
                    return (_crt_curv_scale / (y * _crt_curv_scale3 - _crt_curv_scale2)) + _crt_size;
                case 2:
                    return -(_crt_curv_scale / (y * _crt_curv_scale3 - _crt_curv_scale2)) - _crt_size;
                case 3:
                    return (_crt_curv_scale / (y * _crt_curv_scale3 + _crt_curv_scale2)) - _crt_size;
                case 4:
                    return -(_crt_curv_scale / (y * _crt_curv_scale3 + _crt_curv_scale2)) + _crt_size;
            }
        }

        float2 crtCurveDisplay (float2 uv) {
            float2 alignCenter = float2(uv.x * 2 - 1, uv.y * 2 - 1);
            float quadrant = 1;
            if (alignCenter.x > 0 && alignCenter.y > 0) {
                quadrant = 1;
            } else if (alignCenter.x < 0 && alignCenter.y > 0) {
                quadrant = 2;
            } else if (alignCenter.x < 0 && alignCenter.y < 0) {
                quadrant = 3;
            } else {
                quadrant = 4;
            }
            float2 pos = float2(convertCurvedPosX(quadrant, alignCenter.y), convertCurvedPosY(quadrant, alignCenter.x));
            pos = pow(pos, 2);
            return float2((abs(pos.x) / 2 + 0.5) * uv.x, (abs(pos.y) / 2 + 0.5) * uv.y);
        }

        float2 crtCurveDisplay2 (float2 uv) {
            return pow(abs(uv * 2 - 1) / 1, 2) + uv;
        }

        float2 crtCurveDisplay3 (float uv) {
            return uv * 3.1415;
        }

        float convertCurvedPosY2 (int quadrant, float x) {
            switch(quadrant) {
                case 1:
                    return tan(x) * _crt_curv_scale;
                case 2:
                    return -tan(x) * _crt_curv_scale;
                case 3:
                    return tan(x) * _crt_curv_scale;
                case 4:
                    return -tan(x) * _crt_curv_scale;
            }
        }

        float convertCurvedPosX2 (int quadrant, float y) {
            switch(quadrant) {
                case 1:
                    return tan(y) * _crt_curv_scale;
                case 2:
                    return -tan(y) * _crt_curv_scale;
                case 3:
                    return -tan(y) * _crt_curv_scale;
                case 4:
                    return tan(y) * _crt_curv_scale;
            }
        }

        float2 crtCurveDisplay4 (float2 uv) {
            float2 alignCenter = float2(uv.x * 2 - 1, uv.y * 2 - 1);
            float quadrant = 1;
            if (alignCenter.x > 0 && alignCenter.y > 0) {
                quadrant = 1;
                float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
                return float2(pow(abs(pos.x), _crt_pow) / 2 + 0.5, pow(abs(pos.y), _crt_pow) / 2 + 0.5);
            } else if (alignCenter.x < 0 && alignCenter.y > 0) {
                quadrant = 2;
                float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
                return float2(1 - (pow(abs(pos.x), _crt_pow) / 2 + 0.5), pow(abs(pos.y), _crt_pow) / 2 + 0.5);
            } else if (alignCenter.x < 0 && alignCenter.y < 0) {
                quadrant = 3;
                float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
                return float2(1 - (pow(abs(pos.x), _crt_pow) / 2 + 0.5), 1 - (pow(abs(pos.y), _crt_pow) / 2 + 0.5));
            } else {
                quadrant = 4;
                float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
                return float2(pow(abs(pos.x), _crt_pow) / 2 + 0.5, 1 - (pow(abs(pos.y), _crt_pow) / 2 + 0.5));
            }
            float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
            return float2(pow(abs(pos.x), _crt_pow) / 2 + 0.5, pow(abs(pos.y), _crt_pow) / 2 + 0.5);
        }

        float2 testDisplay (float2 uv) {
            float2 alignCenter = float2(uv.x * 2 - 1, uv.y * 2 - 1);
            float quadrant = 1;
            if (alignCenter.x > 0 && alignCenter.y > 0) {
                quadrant = 1;
            } else if (alignCenter.x < 0 && alignCenter.y > 0) {
                quadrant = 2;
            } else if (alignCenter.x < 0 && alignCenter.y < 0) {
                quadrant = 3;
            } else {
                quadrant = 4;
            }
            return float2((convertCurvedPosX(quadrant, alignCenter.y) / 2 + 0.5) * uv.x, uv.y);
        }
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, crtCurveDisplay4(IN.uv_MainTex)) ; //crtCurveDisplay(IN.uv_MainTex)
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }

        float4 LightingTest (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten) {
            float4 final;
            final.rgb = s.Albedo * _LightColor0.rgb * atten;
            // _LightColor0 조명의 강도, 색상
            // atten 조명과 본 사물간 거리가 멀면 조명이 약할것이고 가까우면 강할 것
            final.a = s.Alpha;
            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
