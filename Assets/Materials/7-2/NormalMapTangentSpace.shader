Shader "Custom/NormalMapTangentSpace"
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
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //计算贴图坐标
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                //通过叉乘 配合
                float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
                //计算切空间转换矩阵 切线-副切线-法线=TANGENT_SPACE_ROTATION
                float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
                //计算切线空间下的光线方向、和视角方向
                o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

                fixed4 frag(v2f i):SV_Target{
                    fixed3 tangentLightDir = normalize(i.lightDir);
                    fixed3 tangentViewDir = normalize(i.viewDir);
                    //贴图取样
                    fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
                    fixed3 tangentNormal;
                    
                    // //如果没有设置成法线贴图则不能使用这个方法，因为被优化后rgb不再对应法线方向的xyz
                    // //把颜色(0,1)映射到(-1,1)
                    // tangentNormal.xy = (packedNormal.xy*2 -1)*_BumpScale;
                    // //勾股定理计算z值
                    // tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                    //如果贴图事先设置为了法线贴图则可以使用内置函数进行映射
                    tangentNormal = UnpackNormal(packedNormal);
                    tangentNormal.xy = tangentNormal.xy * _BumpScale;
                    tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                    //让法线归一化 临时处理方案，应该有更好方法 2022-1-12
                    tangentNormal = normalize(tangentNormal);
                    
                    fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                    fixed3 diffuse = _LightColor0.rgb * albedo *saturate(dot(tangentNormal,tangentLightDir));

                    fixed3 halfDir = normalize(tangentLightDir +tangentViewDir);
                    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,tangentNormal)),_Gloss);

                    return fixed4(ambient + diffuse + specular,1.0);
                }

            ENDCG
        }
    }
    FallBack "Specular"
}
