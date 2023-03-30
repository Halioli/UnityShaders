Shader "Unlit/SHDR_Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientCol ("Ambient light color", Color) = (0.25, 0.25, 0.5, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

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
                float3 wPos: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _AmbientCol;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal = UnityObjectToWorldNormal(v.normal);
                
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                half3 viewDir = normalize(i.wPos - _WorldSpaceCameraPos);
                half3 lightDir = _WorldSpaceLightPos0.xyz * (1 - _WorldSpaceLightPos0.w);

                half3 ambient = half3(0, 0, 0);
                half3 diffuse = half3(0, 0, 0);
                half3 specular = half3(0, 0, 0);

                ambient = _AmbientCol;
                diffuse = unity_LightColor0.rgb * max(0, dot(i.normal, lightDir));
                //specular = 

                return col;
            }
            ENDCG
        }
    }
}
