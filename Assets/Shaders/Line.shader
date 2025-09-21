Shader "Unlit/Line"
{
    Properties
    {
        _Color("Color", Color) = (1.0,1.0,1.0,1.0)
        _LineWidth("Line Width", Float) = 0.01
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

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 position: TEXCOORD1;
                float4 screenPos: TEXCOORD2;
            };
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex;
                o.uv = v.texcoord;
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
           
            fixed4 _Color;
            float _LineWidth;
            
            float getDelta( float x ){
            	return (sin(x) + 1.0)/2.0;
            }

            float onLine(float a, float b, float lineWidth, float edgethickness)
            {
                float halfLineWidth = lineWidth * 0.5f;
                return smoothstep(a - halfLineWidth - edgethickness, a - halfLineWidth, b) - smoothstep(a + halfLineWidth, a + halfLineWidth + edgethickness, b);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
            	float2 pos = i.position.xy * 2;
                float2 uv = i.uv;
                
                fixed3 color = _Color * onLine(uv.y, lerp(0.3, 0.7, getDelta(uv.x * 2 * UNITY_PI)), 0.05, 0.002); 
                
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}