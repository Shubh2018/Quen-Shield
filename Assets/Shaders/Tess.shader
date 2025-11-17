Shader "Unlit/Tess"
{
    Properties
    {
        _Tess ("Tesselation", Range(1, 20)) = 2
        _MaxDist("Max Distance", Float) = 50
        
        [HDR]_FresnelColor ("Color", Color) = (1,1,1,1)
        _FresnelPower("Fresnel Power", Range(1, 20)) = 1
        
        _Speed("Speed", Range(0, 100)) = 1
        _Frequency("Frequency", Range(0, 20)) = 2
        _Amplitude("Amplitude", Range(0, 5)) = 0.05
        
        _FadeLength("Fade Length", Range(0, 2)) = 1
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
        
        Cull Back
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex TesselationVertexProgram
            #pragma fragment frag
            #pragma hull hull
            #pragma domain domain 

            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            // Extra vertex struct
            struct ControlPoint
            {
                float4 vertex : INTERNALTESSPOS;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD2;
                float4 worldPos : TEXCOORD3;
                float3 worldNormal : TEXCOORD4;
            };

            //Tesselation Data
            struct TesselationFactors
            {
                float edge[3] : SV_TessFactor;
                float inside : SV_InsideTessFactor;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Tess;
            float _MaxDist;
            
            float _Speed;
            float _Frequency;
            float _Amplitude;

            float4 _FresnelColor;
            float _FresnelPower;

            float _FadeLength;

            TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);

            v2f vert (appdata v)
            {
                v2f o;

                float t = _Speed * _Time.y;
                float height = _Amplitude * sin(v.vertex.y * t + _Frequency);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(GetWorldSpaceViewDir(o.worldPos));
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                
                o.normal = v.normal;

                v.vertex.xyz += normalize(o.normal) * height;
                
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //pre tesselation vertex program
            ControlPoint TesselationVertexProgram(appdata v)
            {
                ControlPoint p;

                p.vertex = v.vertex;
                p.uv = v.uv;
                p.normal = v.normal;

                return p;
            }

            //Hull
            [UNITY_domain("tri")]
            [UNITY_outputcontrolpoints(3)]
            [UNITY_outputtopology("triangle_cw")]
            [UNITY_partitioning("fractional_odd")]
            [UNITY_patchconstantfunc("patchConstantFunction")]
            ControlPoint hull(InputPatch<ControlPoint, 3> patch, uint id : SV_OutputControlPointID)
            {
                return patch[id];
            }

            //distance based tesselation
            float CalcDistanceTessFactor(float4 vertex, float minDist, float maxDist, float tess)
            {
                float3 worldPosition = mul(unity_ObjectToWorld, vertex).xyz;
                float dist = distance(worldPosition, _WorldSpaceCameraPos);
                float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;

                return f;
            }

            //tesselation
            TesselationFactors patchConstantFunction(InputPatch<ControlPoint, 3> patch)
            {
                //values for distance fading the tesselation
                float minDist = 5.0;
                float maxDist = _MaxDist;
                
                TesselationFactors f;

                float edge0 = CalcDistanceTessFactor(patch[0].vertex, minDist, maxDist, _Tess);
                float edge1 = CalcDistanceTessFactor(patch[1].vertex, minDist, maxDist, _Tess);
                float edge2 = CalcDistanceTessFactor(patch[2].vertex, minDist, maxDist, _Tess);

                f.edge[0] = (edge1 + edge2) / 2;
                f.edge[1] = (edge2 + edge0) / 2;
                f.edge[2] = (edge0 + edge1) / 2;

                f.inside = (edge0 + edge1 + edge2) / 3;

                return f;
            }

            [UNITY_domain("tri")]
            v2f domain(TesselationFactors factors, OutputPatch<ControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
            {
                appdata v;

                #define DomainCalc(fieldName) v.fieldName = \
                    patch[0].fieldName * barycentricCoordinates.x + \
                    patch[1].fieldName * barycentricCoordinates.y + \
                    patch[2].fieldName * barycentricCoordinates.z

                DomainCalc(vertex);
                DomainCalc(uv);
                DomainCalc(normal);

                return vert(v);
            }

            half4 frag (v2f i) : SV_Target
            {
                float screenUV = i.vertex.xy / i.vertex.w;
                float depthValue = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV).r;

                float sceneZ = Linear01Depth(depthValue, _ZBufferParams);
                float surfZ = length(mul(unity_ObjectToWorld, float4(i.vertex.xyz, 1.0)).xyz - _WorldSpaceCameraPos);

                float diff = abs(sceneZ - surfZ);
                float intersect = 1 - saturate(diff / _FadeLength);
                
                half4 fresnel = _FresnelColor * pow(1 - dot(i.viewDir, i.worldNormal), _FresnelPower * saturate((sin(_Time.y) + 1.5) * 0.5));
                half4 intersection = _FresnelColor;
                
                return lerp(fresnel, intersection, pow(intersect, 2));
            }
            ENDHLSL
        }
    }
}
