Shader "Unlit/QuenShield"
{
    Properties
    {
        [HDR] _FresnelColor("Fresnel Color", Color) = (1, 1, 1, 1)
        _FresnelPower("Fresnel Power", Range(1, 20)) = 1
        
        _Freq("Frequency", Range(0, 1)) = 0.5
        _Amp("Amplitude", Range(0.01, 0.1)) = 0.05
        _Speed("Speed", Range(0, 100)) = 10
    }
    
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        LOD 100
        
        Blend SrcAlpha OneMinusSrcAlpha
        
        ZWrite On
        
        Cull Back

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _FresnelPower;
            float4 _FresnelColor;

            float _Speed;
            float _Freq;
            float _Amp;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float4 worldPos : TEXCOORD3;
            };
            
            v2f vert (appdata v)
            {
                v2f o;

                //Fresnel
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));

                //VertexDisplacement
                float t = _Speed * _Time;
                float height = _Amp * sin(v.vertex.y * t + _Freq );
                v.vertex += normalize(float4(o.normal, 1)) * height;

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //return half4(1, 1, 1, 1);
                half4 color = _FresnelColor * pow(1 - dot(i.viewDir, i.normal), _FresnelPower * saturate((sin(_Time.y) + 1.5) * 0.5));
                return color;
            }
            ENDCG
        }
    }
}
