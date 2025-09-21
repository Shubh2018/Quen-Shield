Shader "Unlit/Shaders-6"
{
    Properties
    {
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        _ColorB("Color B", Color) = (1, 1, 1, 1)
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

            fixed4 _ColorA;
            fixed4 _ColorB;

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

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 color = i.position * 2;
                color.r = smoothstep(0, 0.01, color.r);
                color.g = smoothstep(0, 0.01, color.g);
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
