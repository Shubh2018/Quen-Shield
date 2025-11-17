Shader "Unlit/DepthIntersection"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _FadeLength("FadeLength", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Back

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
                float fragZ = i.screenPosition.a;

                float diff = depth - fragZ;
                float intersect = 0;
                
                if (diff > 0)
                    intersect = saturate(diff / _FadeLength);
                
                return lerp(half4(0, 0, 0, 1), _Color, pow(intersect, 4));
            }
            ENDCG
        }
    }
}
