Shader "Unlit/SHDR_Triplanar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RightTex ("Right Texture", 2D) = "white" {}
        _ForwardTex ("Forward Texture", 2D) = "white" {}
        _FallOff ("Fall Off", Range(0, 5)) = 0.25
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

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
                float3 wPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _FallOff;
            sampler2D _RightTex;
            sampler2D _ForwardTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // Calculate world position and assign it to o.wPos
                o.wPos = mul((float3x3)unity_ObjectToWorld, v.vertex);

                // Calculate world space normal
                o.normal = UnityObjectToWorldNormal(v.normal);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Calculate uv top (xz)
                float2 uv_top = abs(i.wPos.xz);
                // Calculate uv right (yz)
                float2 uv_right = abs(i.wPos.yz);
                // Calculate uv forward (xy)
                float2 uv_forward = abs(i.wPos.xy);

                // tex2D (_MainTex, uv_top)
                fixed4 col_top = tex2D(_MainTex, uv_top);
                fixed4 col_right = tex2D(_RightTex, uv_right);
                fixed4 col_forward = tex2D(_ForwardTex, uv_forward);

                half3 weights;
                // Sampled col top * abs(normal.y)
                weights.y = pow(abs(i.normal.y), _FallOff);
                weights.x = pow(abs(i.normal.x), _FallOff);
                weights.z = pow(abs(i.normal.z), _FallOff);

                weights = weights / (weights.x + weights.y + weights.z);

                col_top *= weights.y;
                col_right *= weights.x;
                col_forward *= weights.z;

                fixed4 col = col_top + col_forward + col_right;
                return col;
            }
            ENDCG
        }
    }
}
