## 5주차 과제

### 실행 데모 영상

https://user-images.githubusercontent.com/16532326/136010255-a913fd62-1713-47bb-8676-81b27cb7f411.mov

과제 작업 위치

- Scene: `Assets/Scenes/hw1`
- Material: `Assets/Materials/Cobble`
- Shader: `Assets/Shader/Cobble`

### 소스 내용

```
void surf (Input IN, inout SurfaceOutputStandard o)
{
    // _MainTex 기본 텍스쳐 이미지의 픽셀 값을 fixed4 c 에 할당
    fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
    if (_Options >= 1) {
        // _NormalMap 의 rgb 값을 이용한 가짜 굴곡을 주어 폴리곤이 많아 보이게 함
        float3 normal = UnpackNormal(tex2D (_NormalMap, IN.uv_NormalMap));
        o.Normal = float3(normal.x * _NormalScale, normal.y * _NormalScale, normal.z);
    }
    if (_Options >= 2 && _OcclusionToggle) {
        // _Occlusion 어두운 곳의 명암을 더 주어 입체감 있는 효과 추가
        o.Occlusion = tex2D(_Occlusion, IN.uv_Occlusion);
    }
    if (_Options >= 3) {
        // _Roughtness 표면의 거침 / 매끈함을 텍스쳐를 이용해 할당
        o.Smoothness = tex2D(_Roughtness, IN.uv_Roughtness) * _RoughtnessScale;
    }
    o.Albedo = c.rgb;
    o.Alpha = c.a;
}
```
