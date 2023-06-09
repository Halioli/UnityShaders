Shader "Unlit/SHDR_Fresnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FresnelCol ("Fresnel Color", Color) = (1, 1, 1, 1)
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
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 normal : NORMAL;
                half3 viewDir : TEXCOORD1;
                half4 screenPosition : TEXCOORD2;
                float3 vPos: TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _FresnelCol;

            v2f vert (appdata v)
            {
                v2f o;
                o.normal = v.normal;

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.normal = UnityObjectToWorldNormal(v.normal);
                
                o.vPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(o.vPos - _WorldSpaceCameraPos);
                
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenSpaceUV = i.screenPosition.xy / i.screenPosition.w;
                float ratio = _ScreenParams.x / _ScreenParams.y;
                screenSpaceUV.x *= ratio;

                float4 col = tex2D(_MainTex, screenSpaceUV);

                fixed fresnel = dot(i.viewDir * -1, i.normal);
                fixed4 fresnelCol = lerp(_FresnelCol, col, fresnel);

                return fresnelCol;
            }
            ENDCG
        }
    }
}
