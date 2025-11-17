Shader "Custom/RampLighting"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        
        _LevelCount("LevelCount", Float) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        fixed4 _Color;
        
        struct Input
        {
            float2 uv_MainTex;
        };

        float _LevelCount;

        half4 LightingRamp(SurfaceOutput s, half3 lightDir, half atten)
        {
            half NdotL = max(0, dot(s.Normal, lightDir));
            half3 ramp = floor(NdotL * _LevelCount) / _LevelCount;

            half4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * (ramp * atten);
            c.a = s.Alpha;
            return c;
        }
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
