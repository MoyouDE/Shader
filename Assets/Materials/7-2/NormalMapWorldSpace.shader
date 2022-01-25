Shader "Custom/NormalMapWorldSpace"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}//法线纹理-凹凸贴图
        _BumpScale ("Bump Scale",Float) = 1.0//凹凸程度
        _Specular ("Specular",Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0,256)) = 20
    }
    SubShader
    {
        Pass{
            Tags{ "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;//平铺偏移系数、下同理
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;//凹凸放大系数
            fixed4 _Specular;
            float _Gloss; 
    
            struct a2v{
                float4 vertex :POSITION;
                float3 normal:NORMAL;
                float4 tangent: TANGENT;
                float4 texcoord :TEXCOORD0;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                float4 uv :TEXCOORD0;
                float4 T2W0 : TEXCOORD1;
                float4 T2W1 : TEXCOORD2;
                float4 T2W2 : TEXCOORD3;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //计算贴图坐标
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal,worldTangent)*v.tangent.w;

                o.T2W0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.T2W1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.T2W2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

                return o;
            }

                fixed4 frag(v2f i):SV_Target{
                    float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
                    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                    fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                    bump.xy *= _BumpScale;
                    bump.z = sqrt(1.0 - saturate(dot(bump.xy,bump.xy)));

                    //得到世界空间的法线方向
                    bump = normalize(mul(float3x3(i.T2W0.xyz,i.T2W1.xyz,i.T2W2.xyz), bump));

                    fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                    fixed3 diffuse = _LightColor0.rgb * albedo *saturate(dot(bump,lightDir));

                    fixed3 halfDir = normalize(lightDir + viewDir);
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,bump)),_Gloss);

                    return fixed4(ambient + diffuse + specular,1.0);
                }

            ENDCG
        }
    }
    FallBack "Specular"
}
