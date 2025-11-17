Shader "Custom/Quen-Tess"
{
    Properties
    {
        [HDR]_FresnelColor ("Color", Color) = (1,1,1,1)
        _FresnelPower("Fresnel Power", Range(1, 20)) = 1
        
        _EdgeLength("Tesselation", Range(2, 400)) = 20
        _Phong("Phong Value", Range(0, 1)) = 0.5
        
        _Speed("Speed", Range(0, 100)) = 1
        _Frequency("Frequency", Range(0, 20)) = 2
        _Amplitude("Amplitude", Range(0, 5)) = 0.05
        
        _FadeLength("Fade Length", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        LOD 200
        ZWrite On

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows nolightmap vertex:disp alpha tessellate:tessEdge tessphong:_Phong
        
        #pragma target 3.0
        #include "Tessellation.cginc"

        sampler2D _MainTex;
        
        struct appdata
        {
            float4 vertex: POSITION;
            float3 normal: NORMAL;
            float2 texcoord: TEXCOORD0;
        };

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 worldNormal;
            float4 screenPos;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float _EdgeLength;
        float _Phong;
        
        float _Speed;
        float _Frequency;
        float _Amplitude;

        float4 _FresnelColor;
        float _FresnelPower;

        float _FadeLength;

        sampler2D _CameraDepthTexture;

        void disp(inout appdata v)
        {
            float t = _Speed * _Time.y;
            float height = _Amplitude * sin(v.vertex.y * t + _Frequency);

            //v.normal = UnityObjectToWorldNormal(v.normal);
            v.vertex.xyz += normalize(v.normal) * height;

            //v.vertex = UnityObjectToClipPos(v.vertex);
        }
        
        float4 tessEdge(appdata v0, appdata v1, appdata v2)
        {
            return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
        }
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos)));
            float surfZ = -mul(UNITY_MATRIX_V, float4(IN.worldPos.xyz, 1)).z;
            float diff = sceneZ - surfZ;
            float intersect = 1 - saturate(diff / _FadeLength);

            half4 fresnel = _FresnelColor * pow(1 - dot(IN.viewDir, IN.worldNormal), _FresnelPower * saturate((sin(_Time.y) + 1.5) * 0.5));
            half4 intersection = _FresnelColor;
            
            o.Emission = lerp(fresnel, intersection, pow(intersect, 4));
            o.Alpha = 0;
        }
        ENDCG
    }

    FallBack "Diffuse"
}
