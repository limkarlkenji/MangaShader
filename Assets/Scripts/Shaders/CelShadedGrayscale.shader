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
        _Saturation("Saturation", Range(0, 1)) = 0.0
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineThickness("Outline Thickness", Range(0, 0.5)) = 0.5 
    }

    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase"}

            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

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
            float _Saturation;
            

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
                float step = floor(NdotL / (1 - _Steps)) * _Strength;
                mainCol *= step + (1 -_Intensity);
                mainCol.rgb = lerp(mainCol.rgb, dot(mainCol.rgb, float3(0.3, 0.59, 0.11)), _Saturation);                 // Grayscale

                fixed4 hatchCol = lerp(tex2D(_Hatch, i.uvHatch), mainCol, step + (1 - _HatchIntensity));

                return mainCol * hatchCol;
            }
            ENDCG
        }


        
        Pass 
        {
            Tags { "Queue" = "Transparent" }
        	Name "BASE"
        	Cull Back
        	Blend Zero One
        }

        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always"}
            Cull Front

            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

             float4 _OutlineColor;
             float _OutlineThickness;

            v2f vert(appdata v)
            {
                // just make a copy of incoming vertex data but scaled according to normal direction
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                float2 offset = TransformViewToProjection(norm.xy);

                o.pos.xy += offset * o.pos.z * _OutlineThickness;
                o.color = _OutlineColor;
                return o;
            }
            

            fixed4 frag(v2f i) : COLOR{
                fixed4 col = i.color;
                return col;
            }
            ENDCG
        }
    }
}