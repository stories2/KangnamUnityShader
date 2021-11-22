﻿Shader "Custom/CRTDisplay"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _crt_curv_scale ("CRT Curv scale", Range(0, 5)) = 0.5
        _crt_curv_scale2 ("CRT Curv scale2", Range(0, 10)) = 4
        _crt_curv_scale3 ("CRT Curv scale3", Range(0, 5)) = 1.3
        _crt_curv_scale4 ("CRT Curv scale4", Range(0, 5)) = 1.13
        _crt_curv_scale5 ("CRT Curv scale5", Range(-5, 5)) = 0.5
        _crt_curv_scale6 ("CRT Curv scale6", Range(0, 2)) = 1

        _crt_curv_horizontal ("CRT Curv Horizontal", Range(1, 5)) = 2
        _crt_size ("CRT Size", Range(0, 5)) = 1.1
        _crt_pow ("CRT POW", Range(-10, 10)) = 1
        _RoundedCornerTex ("Rounded coner", 2D) = "white" {}
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
        sampler2D _RoundedCornerTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_RoundedCornerTex;
            float3 viewDir;
        };

        float _crt_curv_scale;
        float _crt_curv_scale2;
        float _crt_curv_scale3;
        float _crt_curv_scale4;
        float _crt_curv_scale5;
        float _crt_curv_scale6;
        float _crt_curv_horizontal;
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
                    return tan(x * _crt_curv_scale4) * _crt_curv_scale;
                case 2:
                    return -tan(x * _crt_curv_scale4) * _crt_curv_scale;
                case 3:
                    return tan(x * _crt_curv_scale4) * _crt_curv_scale;
                case 4:
                    return -tan(x * _crt_curv_scale4) * _crt_curv_scale;
            }
        }

        float convertCurvedPosX2 (int quadrant, float y) {
            switch(quadrant) {
                case 1:
                    return tan(y * _crt_curv_scale4) * _crt_curv_scale;
                case 2:
                    return -tan(y * _crt_curv_scale4) * _crt_curv_scale;
                case 3:
                    return -tan(y * _crt_curv_scale4) * _crt_curv_scale;
                case 4:
                    return tan(y * _crt_curv_scale4) * _crt_curv_scale;
            }
        }

        float2 crtCurveDisplay4 (float2 uv) {
            float2 alignCenter = float2(uv.x * 2 - 1, uv.y * 2 - 1);
            float quadrant = 1;
            if (alignCenter.x > 0 && alignCenter.y > 0) {
                quadrant = 1;
                float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
                return float2(pow(abs(pos.x), _crt_pow) / _crt_curv_horizontal + 0.5, pow(abs(pos.y), _crt_pow) / _crt_curv_horizontal + 0.5);
            } else if (alignCenter.x < 0 && alignCenter.y > 0) {
                quadrant = 2;
                float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
                return float2(1 - (pow(abs(pos.x), _crt_pow) / _crt_curv_horizontal + 0.5), pow(abs(pos.y), _crt_pow) / _crt_curv_horizontal + 0.5);
            } else if (alignCenter.x < 0 && alignCenter.y < 0) {
                quadrant = 3;
                float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
                return float2(1 - (pow(abs(pos.x), _crt_pow) / _crt_curv_horizontal + 0.5), 1 - (pow(abs(pos.y), _crt_pow) / _crt_curv_horizontal + 0.5));
            } else {
                quadrant = 4;
                float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
                return float2(pow(abs(pos.x), _crt_pow) / _crt_curv_horizontal + 0.5, 1 - (pow(abs(pos.y), _crt_pow) / _crt_curv_horizontal + 0.5));
            }
            float2 pos = float2(convertCurvedPosX2(quadrant, alignCenter.x), convertCurvedPosY2(quadrant, alignCenter.y));
            return float2(pow(abs(pos.x), _crt_pow) / _crt_curv_horizontal + 0.5, pow(abs(pos.y), _crt_pow) / _crt_curv_horizontal + 0.5);
        }

        float converter (float x) {
            return pow(1 - cos((x * _crt_curv_scale5 - 0) * 0.25) * 1, _crt_pow) ;
        }

        float convertCurvedPosY3 (int quadrant, float x) {
            switch(quadrant) {
                case 1:
                    return -converter(x);
                case 2:
                    return -converter(x);
                case 3:
                    return converter(x);
                case 4:
                    return converter(x);
            }
        }

        float convertCurvedPosX3 (int quadrant, float y) {
            switch(quadrant) {
                case 1:
                    return -converter(y);
                case 2:
                    return converter(y);
                case 3:
                    return converter(y);
                case 4:
                    return -converter(y);
            }
        }

        float2 crtCurveDisplay5 (float2 uv) {
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
            return float2(
                    (alignCenter.x - convertCurvedPosX3(quadrant, alignCenter.y) + 1) * 0.5, 
                    (alignCenter.y - convertCurvedPosY3(quadrant, alignCenter.x) + 1) * 0.5
                );
        }

        float converter2 (float x) {
            return tan(x * 1.4) * _crt_curv_scale6;
        }

        float convertCurvedPosY4 (int quadrant, float x) {
            switch(quadrant) {
                case 1:
                    return converter2(x);
                case 2:
                    return -converter2(x);
                case 3:
                    return converter2(x);
                case 4:
                    return -converter2(x);
            }
        }

        float convertCurvedPosX4 (int quadrant, float y) {
            switch(quadrant) {
                case 1:
                    return converter2(y);
                case 2:
                    return -converter2(y);
                case 3:
                    return converter2(y);
                case 4:
                    return -converter2(y);
            }
        }

        float2 crtCurveDisplay6 (float2 uv) {
            float2 alignCenter = float2(uv.x * 2 - 1, uv.y * 2 - 1);
            float quadrant = 1;
            if (alignCenter.x > 0 && alignCenter.y > 0) {
                quadrant = 1;
            return float2(
                    (1 + convertCurvedPosY4(quadrant, alignCenter.x)) / 2, 
                    (1 + convertCurvedPosX4(quadrant, alignCenter.y)) / 2
                );
            } else if (alignCenter.x < 0 && alignCenter.y > 0) {
                quadrant = 2;
            return float2(
                    (1 - convertCurvedPosY4(quadrant, alignCenter.x)) / 2, 
                    (1 - convertCurvedPosX4(quadrant, alignCenter.y)) / 2
                );
            } else if (alignCenter.x < 0 && alignCenter.y < 0) {
                quadrant = 3;
            return float2(
                    (1 + convertCurvedPosY4(quadrant, alignCenter.x)) / 2, 
                    (1 + convertCurvedPosX4(quadrant, alignCenter.y)) / 2
                );
            } else {
                quadrant = 4;
            return float2(
                    (1 - convertCurvedPosY4(quadrant, alignCenter.x)) / 2, 
                    (1 - convertCurvedPosX4(quadrant, alignCenter.y)) / 2
                );
            }
            return float2(
                    (1 + convertCurvedPosY4(quadrant, alignCenter.x)) / 2, 
                    (1 + convertCurvedPosX4(quadrant, alignCenter.y)) / 2
                );
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
            fixed4 c = tex2D (_MainTex, crtCurveDisplay5(crtCurveDisplay6(IN.uv_MainTex))) ; //crtCurveDisplay(IN.uv_MainTex)
            fixed4 roundedConer = tex2D (_RoundedCornerTex, IN.uv_RoundedCornerTex);
            o.Albedo = c.rgb * roundedConer.a;
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