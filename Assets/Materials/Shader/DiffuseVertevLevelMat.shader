//漫反射模型
Shader "Custom/Diffuse Vertev-Level"
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
                    fixed3 color :COLOR;
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
                    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                    //saturate:取值钳制在0~1
                    fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLight));
                    o.color = ambient + diffuse;
                    return o;
                }

                fixed4 frag(v2f i):SV_TARGET{
                    return fixed4(i.color,1.0);
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
