Shader "Custom/Simple Shader"{
    Properties{
        _Color ("Color Tint",Color) = (1.0,1.0,1.0,1.0)
    }

    SubShader{
        pass{
            CGPROGRAM
            #include "UnityCg.cginc"
            //定义顶点着色器
            #pragma vertex vert
            //定义片元着色器
            #pragma fragment frag
            #pragma enable_d3d11_debug_symbols
            fixed4 _Color;

            //application to vertex
            struct a2v {
                //顶点坐标填入vertex
                float4 vertex :POSITION;
                //法线坐标填入normal
                float3 normal :NORMAL;
                //用模型的第一套纹理填入texcoord
                float4 texcoord :TEXCOORD0;
            };

            //vertex to fragD:\Other\Projects\GitHub_Sourcetree\Shader\Assets\Materials\Shader\FalseColor.shader
            struct v2f {
                float4 pos:SV_POSITION;
                fixed3 color :COLOR0;
            };

            //模型顶点->裁剪顶点
            v2f vert (a2v v){
                v2f o;
                o.pos =UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 +fixed3(0.5,0.5,0.5);
                return o;
            }

            //渲染目标
            fixed4 frag(v2f i):SV_TARGET{
                fixed3 c =i.color;
                c *= _Color.rgb;
                return fixed4(c,1.0);
            }

            ENDCG
        }
    }
}