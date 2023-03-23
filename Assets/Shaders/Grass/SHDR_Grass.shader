Shader "Unlit/SHDR_Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorOffset ("Color Offset", Range(-1, 1)) = 0
        _ColorContrast ("Color Constrast", Range(0, 10)) = 1
        _BaseColor ("Base Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _HighColor ("Highlight Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType" = "TransparentCutout" 
               "Queue" = "AlphaTest" }
        
        Blend One OneMinusSrcAlpha
        ZWrite Off
        Cull Off
        
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; 
            float _ColorOffset, _ColorContrast;
            fixed4 _BaseColor, _HighColor;

            v2f vert (appdata v)
            {
                v2f o;
                
                v.vertex.xy += sin(_Time.y) * v.uv.y;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float interpolation = i.uv.y;

                // Add interpolation offset and apply contrast
                interpolation = saturate(interpolation + _ColorOffset);
                interpolation = saturate(pow(interpolation, _ColorContrast));

                // Apply color interpolation via lerp
                col.rgb = lerp(_BaseColor, _HighColor, interpolation);
                col.rgb *= col.a;
                return col;
            }
            ENDCG
        }
    }
}
