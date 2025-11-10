Shader "Unlit/Tess"
{
    Properties
    {
        _Tess ("Tesselation", Range(1, 20)) = 2
        _MaxDist("Max Distance", Float) = 50
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex TesselationVertexProgram
            #pragma fragment frag
            #pragma hull hull
            #pragma domain domain 

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normal : NORMAL;
            };

            // Extra vertex struct
            struct ControlPoint
            {
                float4 vertex : INTERNALTESSPOS;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = v.normal;
                return o;
            }

            //pre tesselation vertex program
            ControlPoint TesselationVertexProgram(appdata v)
            {
                ControlPoint p;

                p.vertex = v.vertex;
                p.uv = v.uv;
                p.normal = v.normal;
                p.color = v.color;

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
                DomainCalc(color);
                DomainCalc(normal);

                return vert(v);
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
