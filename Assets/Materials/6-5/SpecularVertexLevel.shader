Shader "Custom/SpecularVertexLevel"
{
    Properties
    {
        _Diffuse ("Diffuse",Color)=(1,1,1,1)
        _Specular ("Specular",Color)=(1,1,1,1)
        _Gloss ("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        Pass{
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed3 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert(a2v v){
                v2f o;
                //获得顶点世界坐标
                o.pos = UnityObjectToClipPos(v.vertex);
                //获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //获得世界坐标法线
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                //世界坐标系中的光源方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));
                //reflect(入射方向,法线方向):反射方向
                fixed3 reflectDir = normalize (reflect(-worldLightDir,worldNormal));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-UnityObjectToWorldDir(v.vertex));

                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);

                o.color = ambient +specular;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                return fixed4 (i.color,1.0);
            }

            ENDCG

        }
    }
    FallBack "Specular"
}
