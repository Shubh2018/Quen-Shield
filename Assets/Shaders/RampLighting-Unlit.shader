Shader "Unlit/RampLighting 1"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        
        _LevelCount("LevelCount", Float) = 3
        
        
        _OutlineWidth("Outline Width", Range(0, 10)) = 1
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        
        _OutlineWidth2("Outline Width2", Range(0, 10)) = 1
        _OutlineColor2("Outline Color2", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
        }
        LOD 100
        
        Pass
        {
            Tags {"LightMode"="UniversalForward"}
            Name "Ramp"
            
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

        Pass
        {
            Tags {"LightMode"="Outline"}
            Name "Outline"
            
            Cull Front
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };
            
            float _OutlineWidth;
            float4 _OutlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.normal = TransformObjectToWorldNormal(v.normal);

                v.vertex.xyz += o.normal * _OutlineWidth;
                o.vertex = TransformObjectToHClip(v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = _OutlineColor;
                return col;
            }
            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode"="Outline Two"}
            Name "Outline2"
            
            Cull Front
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };
            
            float _OutlineWidth2;
            float4 _OutlineColor2;

            v2f vert (appdata v)
            {
                v2f o;
                o.normal = TransformObjectToWorldNormal(v.normal);

                v.vertex.xyz += o.normal * _OutlineWidth2;
                o.vertex = TransformObjectToHClip(v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = _OutlineColor2;
                return col;
            }
            ENDHLSL
        }
    }
}
