Shader "Custom/CRTDisplay2"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RoundedCornerTex ("Rounded coner", 2D) = "white" {}
        _CurvTex ("Curved texure", 2D) = "white" {}
        _crt_term ("CRT term", Range(1, 10000000)) = 1000000
        _crt_term2 ("CRT term2", Range(1, 1000)) = 100

        _color_R ("color red strong", Range(0, 1)) = 1
        _color_G ("color green strong", Range(0, 1)) = 1
        _color_B ("color blue strong", Range(0, 1)) = 1
        _color_backlight ("color backlight strong", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient nolight

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _RoundedCornerTex;
        sampler2D _CurvTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_RoundedCornerTex;
            float2 uv_CurvTex;
        };

        float _crt_term;
        float _crt_term2;
        float _color_R;
        float _color_G;
        float _color_B;
        float _color_backlight;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float converter2 (float x) {
            return tan(x * 1.4) * 0.5;
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

        // https://www.shadertoy.com/view/XtlSD7
        float2 CRTCurveUV( float2 uv )
        {
            uv = uv * 2.0 - 1;
            float2 offset = abs( uv.yx ) / float2( 5, 2 );
            uv = uv + uv * offset * offset;
            uv = uv * 0.5 + 0.5;
            return uv;
        }
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            float2 uv = crtCurveDisplay6(CRTCurveUV(IN.uv_MainTex));
            float4 c = tex2D (_MainTex, uv) ; //crtCurveDisplay(IN.uv_MainTex)
            fixed4 roundedConer = tex2D(_RoundedCornerTex, IN.uv_RoundedCornerTex);
            fixed4 curvTex = tex2D(_CurvTex, IN.uv_CurvTex);
            
            float color = sin(IN.uv_MainTex.x * _crt_term);
            // Albedo comes from a texture tinted by color

            // if (-1 < color && color <= -0.9) {
            //     o.Emission = float3(c.r, 0, 0);
            // } else if (-0.5 < color && color <= 0) {
            //     o.Emission = float3(0, c.g, 0);
            // } else if (0 < color && color <= 0.5) {
            //     o.Emission = float3(0, 0, c.b);
            // } else {
            //     o.Emission = float3(0, 0, 0);
            // }

            float pixelX = floor(uv.x * _crt_term2);
            float pixelY = floor(uv.y * _crt_term2);
            pixelX = (uv.x * 10 + 10) / 10;
            pixelX = floor(pixelX * _crt_term2);
            pixelY = (uv.y * 10 + 10) / 10;
            pixelY = floor(pixelY * _crt_term2);

            float timeTan = tan(_Time.y * 0.5) * 0.5;
            float noiseY = timeTan;
            float noiseGap = 0.05;
            
            if (noiseY - noiseGap < IN.uv_MainTex.y 
                && IN.uv_MainTex.y <= noiseY + noiseGap
                ) {
                // pixelX = pixelX * (sin(_Time.y) * 0.5 + 0.5);
                // pixelX = uv.x * tan(_Time.y) * _Time.z;
                c = tex2D (_MainTex, float2(abs(uv.x + cos(_Time.y)) / 2, uv.y)) ;
                // fixed4 noise = tex2D (_MainTex, float2(x, IN.uv_MainTex.y));
                // o.Emission = noise.rgb * o.Emission;
                // o.Alpha = 0.7;
            }

            o.Emission = float3(pixelX % 4 == 0 ? c.r * _color_R : 0,
                                pixelX % 4 == 1 ? c.g * _color_G : 0,
                                pixelX % 4 == 2 ? c.b * _color_B : 0);
                                
            o.Albedo = float3(pixelY % 4 == 0 ? c.r * _color_R : 0,
                                pixelY % 4 == 1 ? c.g * _color_G : 0,
                                pixelY % 4 == 2 ? c.b * _color_B : 0);

            o.Emission = o.Albedo * o.Emission * roundedConer.rgb * curvTex.rgb + float3(1, 1, 1) * _color_backlight;
            o.Alpha = 1;
        }

        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(0, 0, 0, s.Alpha);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
