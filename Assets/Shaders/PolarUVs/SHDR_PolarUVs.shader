Shader "02/SHDR_PolarUVs"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ST ("Tiling and Offset", Vector) = (1, 1, 0, 0)
        _PanningX ("Panning X", Range(-10, 10)) = 0
        _PanningY ("Panning Y", Range(-10, 10)) = 0
        _SpinSpeed ("Spin Speed", Range(-5, 5)) = 0
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
            #define TAU 6.283185

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

            float2 CartessianToPolar(float2 cartessian)
            {
                float distance = length(cartessian);
                float angle = atan2(cartessian.y, cartessian.x);
                return float2(angle / TAU, distance);
            }

            float2 PolarToCartessian(float2 polar)
            {
                float2 cartessian;
                sincos(polar.x * TAU, cartessian.y, cartessian.x);
                return cartessian * polar.y;
            }

            sampler2D _MainTex;
            float4 _ST;
            fixed _PanningX, _PanningY, _SpinSpeed;

            v2f vert (appdata v)
            {
                v2f o; // Output
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = v.uv;
                o.uv = v.uv * _ST.xy + _ST.zw;
                o.uv += float2(_PanningX, _PanningY) * frac(_Time.y);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Base setup
                float2 uv = i.uv;
                uv -= 0.5;
                uv *= 2.0;

                // To Polar Coords
                uv = CartessianToPolar(uv);
                
                // Modifications
                uv.x += _Time.y * _SpinSpeed;
                uv.x += uv.y;

                // To Cartessian Coords
                uv = PolarToCartessian(uv);

                // Correction and return
                uv = frac(uv);
                return tex2D(_MainTex, uv);
                //return fixed4(uv, 0, 1);
            }
            ENDCG
        }
    }
}
