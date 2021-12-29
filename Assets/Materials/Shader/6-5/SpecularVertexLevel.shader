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
            }

            struct v2f{
                float4 pos:SV_POSITION;
                fixed3 color : COLOR;
            };

            ENDCG

        }
    }
    FallBack "Diffuse"
}
