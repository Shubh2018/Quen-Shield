Shader "Custom/QuenShieldLit"
{
    Properties
    {
        [HDR] _FresnelColor("FresnelColor", Color) = (1, 1, 1, 1)
        _FresnelPower("Fresnel Power", Range(1, 20)) = 1
    }
    
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 200

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
        
        #pragma target 3.0

        float _FresnelPower;
        float4 _FresnelColor;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float3 worldNormal;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = _FresnelColor;
            //o.Emission = _FresnelColor * pow(1 - saturate(dot(normalize(IN.worldNormal), normalize(IN.viewDir))), _FresnelPower);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
