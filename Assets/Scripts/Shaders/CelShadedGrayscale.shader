Shader "Custom/Cel Shaded Grayscale"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Hatch("Hatch Texture", 2D) = "white" {}
        _HatchIntensity("Hatch Intensity", Range(0, 1)) = 0.5
        _Intensity("Intensity", Range(0,1)) = 0.3
        _Strength("Strength", Range(0,1)) = 0.5
        _Steps("Steps", Range(0,1)) = 0.3
        _Grayscale("Grayscale", Range(0, 1)) = 0.0
    }

    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uvHatch : TEXCOORD1;
                float4 vertex : SV_POSITION;
                half3 worldNormal: NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Hatch;
            float4 _Hatch_ST;
            float2 _Hatch_uv;

            float _HatchIntensity;
            float _Intensity;
            float _Strength;
            float _Steps;
            float _Grayscale;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uvHatch = TRANSFORM_TEX(v.uv, _Hatch);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 mainCol = tex2D(_MainTex, i.uv);

                float NdotL = max(0.0, dot(normalize(i.worldNormal), normalize(_WorldSpaceLightPos0.xyz)));             // Cel Shading
                mainCol *= floor(NdotL / (1 - _Steps)) * _Strength + _Intensity;
                mainCol.rgb = lerp(mainCol.rgb, dot(mainCol.rgb, float3(0.3, 0.59, 0.11)), _Grayscale);                 // Grayscale

                fixed4 hatchCol = lerp(tex2D(_Hatch, i.uvHatch), mainCol, floor(NdotL / ( 1 - _Steps)) * _Strength + (1 - _HatchIntensity));


                return mainCol * hatchCol;
            }
            ENDCG
        }
    }
}