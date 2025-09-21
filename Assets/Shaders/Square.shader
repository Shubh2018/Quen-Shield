Shader "Unlit/Square"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            v2f vert (appdata_base v)
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
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 pos = i.position.xy;
                float2 size = float2(0.3, 0.3);
                float2 center = float2(-0.2, 0);
                float leftRect = rect(pos, size, center);
                fixed3 leftColor = fixed3(1, 1, 0) * leftRect;

                size = float2(0.4, 0.4);
                center = float2(0.2, 0);
                float rightRect = rect(pos, size, center);
                fixed3 rightColor = fixed3(0, 1, 0) * rightRect;
                
                return fixed4(leftColor + rightColor, 1);
            }
            ENDCG
        }
    }
}