Shader "Unlit/Circles"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Radius("Radius", Float) = 0.3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            float _Radius;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 position : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex;
                o.uv = v.texcoord;
                return o;
            }

            float circle(float2 pt, float2 center, float radius)
            {
                float2 p = pt - center;
                return 1.0 - step(radius, length(p));
            }

            float circle(float2 pt, float2 center, float radius, bool soften)
            {
                float2 p = pt - center;
                float edge = (soften) ? radius * 0.2f : 0.0;
                return 1.0 - smoothstep(radius - edge, radius + edge, length(p));
            }

            float circle(float2 pt, float2 center, float radius, float line_width)
            {
                float2 p = pt - center;
                float len = length(p);
                float halfLineWidth = len / 10.0f;
                return step(radius - halfLineWidth, len) - step(radius + halfLineWidth, len);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 pos = i.position;
                fixed3 color = _Color * circle(pos, float2(0,0), _Radius, _Radius);
                
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
