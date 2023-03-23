Shader "Unlit/SHDR_ScreenSpace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float4 position : SV_POSITION;
                float4 screenPosition : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);

                // Clip space vertex to transpose coordinates
                o.screenPosition = ComputeScreenPos(o.position);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Divide scrren position xy by screen position w
                float2 screenSpaceUV = i.screenPosition.xy / i.screenPosition.w;
                
                // Divide screen params to get the aspect ratio
                float ratio = _ScreenParams.x / _ScreenParams.y;
                
                // coordinate x * aspect
                screenSpaceUV.x *= ratio;

                float4 col = tex2D(_MainTex, screenSpaceUV);
                return col;
            }
            ENDCG
        }
    }
}
