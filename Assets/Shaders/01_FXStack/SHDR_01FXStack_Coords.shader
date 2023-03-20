Shader "Unlit/SHDR_01FXStack_Coords"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondTex ("Texture", 2D) = "white" {}
        _MainTex_ST ("Tiling and Offset", Vector) = (1, 1, 0, 0)
        _SecondTex_ST ("Tiling and Offset", Vector) = (1, 1, 0, 0)
        _PanningX ("Panning X", Range(-10, 10)) = 0
        _PanningY ("Panning Y", Range(-10, 10)) = 0
        _SpinSpeed ("Spin Speed", Range(-5, 5)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
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

            sampler2D _MainTex, _SecondTex;
            float4 _MainTex_ST, _SecondTex_ST;
            fixed _PanningX, _PanningY, _SpinSpeed;

            v2f vert (appdata v)
            {
                v2f o; // Output
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Base setup
                //panning
                float2 uvB = TRANSFORM_TEX(i.uv, _SecondTex);
                uvB += float2(_PanningX, _PanningY) * frac(_Time.y);
                uvB = frac(uvB);
                //vortex
                float2 uvA = i.uv;
                uvA *= 2;
                uvA = frac(uvA);
                uvA -= 0.5;

                // Mask
                fixed mask = 1 - saturate(distance(fixed2(0, 0), uvA));
                mask += 0.2;
                mask = saturate(pow(mask, 10));

                // To Polar Coords
                uvA = CartessianToPolar(uvA);
                
                // Modifications
                uvA = TRANSFORM_TEX(uvA, _MainTex);
                uvA += fixed2(_PanningX, _PanningY);
                uvA.x += _Time.y * _SpinSpeed;
                uvA.x += uvA.y;

                // To Cartessian Coords
                uvA = PolarToCartessian(uvA);
                uvA = frac(uvA);

                // Sampler both textures
                fixed4 vorexCol = tex2D(_MainTex, uvA);
                fixed4 pannCol = tex2D(_SecondTex, uvB);

                // Return interpolation between two by mask
                return lerp(pannCol, vorexCol, mask);
            }
            ENDCG
        }
    }
}
