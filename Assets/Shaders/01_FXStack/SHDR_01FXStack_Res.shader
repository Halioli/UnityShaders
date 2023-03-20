Shader "Unlit/SHDR_01FXStack_Res"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _MainTexB("Main Tex B", 2D) = "white"{}
        _PanningX("Panning X", Range(-10,10)) = 0
        _PanningY("Panning Y", Range(-10,10)) = 0
 
        _Amplitude ("Wave Size", Range(0,1)) = 0.4
_Frequency ("Wave Freqency", Range(1, 8)) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #define PI2 6.283185307179586476924
 
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
 
            sampler2D _MainTex, _MainTexB;
            float4 _MainTex_ST, _MainTexB_ST;
            fixed _PanningX, _PanningY;
 
            float2 CenterUVs(float2 uvs)
            {
                uvs -= 0.5f;
                uvs *= 2;
                return uvs;
            }
 
            float2 CartessianToPolar(float2 cartesian)
            {
	            float distance = length(cartesian);
	            float angle = atan2(cartesian.y, cartesian.x);
	            return float2(angle / PI2, distance);
            }
 
            float2 PolarToCartessian(float2 polar)
            {
                float2 cartesian;
                sincos(polar.x * PI2, cartesian.y, cartesian.x);
                return cartesian * polar.y;
            }
 
            v2f vert (appdata v)
            {
                /*float4 modifiedPos = data.vertex;
                modifiedPos.y += sin(data.vertex.x * _Frequency) * _Amplitude;
                data.vertex = modifiedPos;*/

                v2f o;
                o.vertex = mul(UNITY_MATRIX_M, v.vertex); //Model to world
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //World to view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //View to projection
                o.uv = CenterUVs(v.uv);
                //o.uv = (CenterUVs(v.uv) + _ST.zw) * _ST.xy; this should be after transformation to polar
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
                //uv of main tex
                float2 uvB = TRANSFORM_TEX(i.uv, _MainTexB);
                uvB += fixed2(_PanningX, _PanningY) * _Time.y;
                uvB = frac(uvB);
 
                //uv of vortex 
                float2 uv = i.uv;
                uv = frac(uv);
                uv -= 0.5;
 
                //mask
                float mask = 1-saturate(distance(float2(0,0),uv));
 
                mask += 0.2;
 
                mask = saturate(pow(mask,10));

                //Transform to Polar uvs
                uv = CartessianToPolar(uv);
 
                //ST uvs or vortex
                uv = TRANSFORM_TEX(uv, _MainTex);
 
                //Apply Pannings
                uv += fixed2(_PanningX, _PanningY) * _Time.z;
 
                //Apply additional effects
                uv.x += 1-(uv.y);

                //Return to Cartessian
                uv = PolarToCartessian(uv);
 
                uv = frac(uv);
 
                //samplers
                fixed4 vortexcol = tex2D(_MainTex, uv);
                fixed4 basecol = tex2D(_MainTexB, uvB);
 
                return lerp(basecol, vortexcol, mask);
 
                return vortexcol;
                //return fixed4(uv,0,1);
            }
            ENDCG
        }
    }
}