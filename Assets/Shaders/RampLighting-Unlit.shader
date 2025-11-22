Shader "Unlit/RampLighting 1"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        
        _LevelCount("LevelCount", Float) = 3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 Normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 Normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color;
            float _LevelCount;

            half4 LightingRamp(float3 normal)
            {
                Light main = GetMainLight();
                float NdotL = dot(normal, main.direction);

                float diff = pow(NdotL * 0.5 + 0.5, 2);
                float ramp = floor(diff * _LevelCount) / _LevelCount;

                half4 col;
                col.rgb = _Color * main.color * ramp;
                col.a = 1;

                return col;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.Normal = TransformObjectToWorldNormal(v.Normal);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return LightingRamp(i.Normal);
            }
            ENDHLSL
        }
    }
}
