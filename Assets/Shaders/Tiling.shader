Shader "Unlit/Tiling"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Size("Size", Range(0.1, 1)) = 0.1
        _Color("Color", Color) = (1, 1, 1, 1)
        _Anchor("Anchor", Vector) = (0.15, 0.15, 0, 0)
        _TileCount("TileCount", Int) = 6
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 position : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Size;
            float4 _Color;
            float4 _Anchor;

            float _TileCount;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex;
                o.uv = v.texcoord;
                return o;
            }

            float rect(float2 pt, float2 size, float2 center)
            {
                float2 p = pt - center;
                float2 halfSize = size * 0.5;
                float horz = step(-halfSize.x, p.x) - step(halfSize.x, p.x);
                float vert = step(-halfSize.y, p.y) - step(halfSize.y, p.y);
                return horz * vert;
            }

            float rect(float2 pt, float2 anchor, float2 size, float2 center)
            {
                float2 p = pt - center;
                float2 halfSize = size * 0.5;
                float horz = step(-halfSize.x - anchor.x, p.x) - step(halfSize.x - anchor.x, p.x);
                float vert = step(-halfSize.y - anchor.y, p.y) - step(halfSize.y - anchor.y, p.y);
                return horz * vert;
            }

            float2x2 getRotationMatrix(float theta)
            {
                float s = sin(theta);
                float c = cos(theta);

                return float2x2(c, -s, s, c);
            }

            float2x2 getScaleMatrix(float scale)
            {
                return float2x2(scale, 0, 0, scale);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 pos = frac(i.uv * _TileCount);
                float2x2 matr = getRotationMatrix(_Time.y);
                float2x2 mats = getScaleMatrix((sin(_Time.y) + 1) / 3 + 0.5);
                
                float2 size = _Size;
                float2 center = _Anchor.zw;
                float2x2 mat = mul(matr, mats);
                float2 pt = mul(mat, pos - center) + center;
                float leftRect = rect(pt, _Anchor.xy, size, center);
                fixed3 color = leftRect * _Color;

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}