Shader "Unlit/DepthIntersection"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _FadeLength("FadeLength", Float) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        LOD 100
        Blend One One
        ZWrite Off
        Cull False

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD1;
            };

            float4 _Color;

            sampler2D _CameraDepthTexture;
            float _FadeLength;

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                float2 screenSpaceUVS = i.screenPosition.xy / i.screenPosition.w;

                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenSpaceUVS));
                float fragZ = length(i.screenPosition - _WorldSpaceCameraPos);

                float diff = depth - fragZ;
                float intersect = 0;
                
                if (diff > 0)
                    intersect = saturate(_FadeLength * diff);
                
                return lerp(half4(1, 0, 1, 1), half4(1, 1, 1, 1), pow(intersect, 4));
            }
            ENDCG
        }
    }
}
