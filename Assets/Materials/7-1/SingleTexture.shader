Shader "Custom/SingleTexture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0,256)) = 20
    }
    SubShader
    {
       pass{
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;//高光颜色
            float _Gloss;

            struct a2v{
                float4 vertex :POSITION;
                float3 normal:NORMAL;
                float4 texcoord :TEXCOORD0;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv :TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //o.uv = TRANSFORM_TEX(v.texcoord,_MainTex); 
                return o;
            } 

            float4 frag(v2f i) : SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //反射率 = 纹素值 * 颜色属性
                fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
                //环境光结果
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                //漫反射结果
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
                //观察方向
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                //BlinnPhong高光    (不受反射率影响)
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(halfDir,worldNormal)),_Gloss);

                return fixed4(ambient + diffuse + specular,1.0);
            }
            ENDCG
       }
    }
    FallBack "Specular"
}
