//半兰伯特模型-片元着色器
Shader "Custom/Diffuse Pixel-Level"
{
    Properties
    {
        _Diffuse ("Diffuse",Color) =(1,1,1,1)
    }
    SubShader
    {
        pass{
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Lighting.cginc"

                fixed4 _Diffuse;

                struct a2v {
                    float4 vertex:POSITION;
                    float3 normal:NORMAL;
                };

                struct v2f{
                    float4 pos:SV_POSITION;
                    fixed3 worldNormal : TEXCOORD0;
                };

                v2f vert(a2v v){
                    v2f o;
                    //获得顶点世界坐标
                    o.pos = UnityObjectToClipPos(v.vertex);
                    //获得世界坐标法线
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    return o;
                }

                fixed4 frag(v2f i):SV_TARGET{
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                    fixed3 worldNormal = normalize(i.worldNormal);
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                    fixed halfLambert = dot(worldNormal,worldLightDir)*0.5+0.5;
                    fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*halfLambert;
                    fixed3 color = ambient + diffuse;
                    return fixed4(color,1.0);
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
