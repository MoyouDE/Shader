Shader "Custom/Simple Surface Shader"{
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque"}
        CGPROGRAM
        #pragma surface surf Lambert
        struct Input {
            Float4 color : COLOR;
        };
        void surf (Input IN, inout SurfaceOutput o){
            o.Albedo = 1;
        }
        ENDCG
    }    
    Fallback "Diffuse"
}
