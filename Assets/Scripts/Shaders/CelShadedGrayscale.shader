Shader "Custom/Cel Shaded Grayscale"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Intensity("Intensity", Range(0,1)) = 0.3
        _Strength("Strength", Range(0,1)) = 0.5
        _ShadingDetail("Shading Detail", Range(0,1)) = 0.3
        _Grayscale("Grayscale", Range(0, 1)) = 0.0
    }

    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "TransparentCutout" "LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 worldNormal: NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Intensity;
            float _Strength;
            float _ShadingDetail;
            float _Grayscale;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float NdotL = max(0.0, dot(normalize(i.worldNormal), normalize(_WorldSpaceLightPos0.xyz))); // Cel Shading
                col *= floor(NdotL / _ShadingDetail) * _Strength + _Intensity;
                col.rgb = lerp(col.rgb, dot(col.rgb, float3(0.3, 0.59, 0.11)), _Grayscale);                 // Grayscale

                return col;
            }
            ENDCG
        }
    }
}