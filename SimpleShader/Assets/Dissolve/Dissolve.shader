Shader "BanMing/Dissolve"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" { }
        // 渐变参数
        _DissolveAmount ("Dissolve Amount", Range(0.0, 1.0)) = 0.0
        // 渐变宽度
        _GradualAmount ("Gradual Amount", Range(0.0, 0.2)) = 0.0
        _FirstColor ("First Color", Color) = (1, 1, 1, 1)
        _SecondColor ("Second Color", Color) = (1, 1, 1, 1)

        _NoiseMap ("NoiseMap", 2D) = "white" { }

        /* UI Mask*/
        [PerRendererData]_StencilComp ("Stencil Comparison", Float) = 8
        [PerRendererData]_Stencil ("Stencil ID", Float) = 0
        [PerRendererData]_StencilOp ("Stencil Operation", Float) = 0
        [PerRendererData]_StencilWriteMask ("Stencil Write Mask", Float) = 255
        [PerRendererData]_StencilReadMask ("Stencil Read Mask", Float) = 255
        [PerRendererData]_ColorMask ("Color Mask", Float) = 15
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Cull off
        Lighting off
        ZWrite off
        Blend One OneMinusSrcAlpha

        /* UI Mask*/
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        ColorMask[_ColorMask]

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseMap;
            float4 _NoiseMap_ST;
            fixed _DissolveAmount;
            fixed _GradualAmount;
            fixed4 _FirstColor;
            fixed4 _SecondColor;

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                fixed4 color: COLOR;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
                float2 noiseMap: TEXCOORD1;
                fixed4 color: COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.noiseMap = TRANSFORM_TEX(v.uv, _NoiseMap);
                o.uv = v.uv;
                o.color = v.color;
                return o;
            }


            fixed4 frag(v2f i): SV_Target
            {
                fixed3 noise = tex2D(_NoiseMap, i.noiseMap).rgb;
                // 计算裁剪
                clip(noise.r - _DissolveAmount);


                fixed4 col = tex2D(_MainTex, i.uv);
                fixed t = 1 - smoothstep(0.0, _GradualAmount, noise.r - _DissolveAmount);
                // 计算渐变颜色
                // fixed3 graduaCol = lerp(_FirstColor * col.a, _SecondColor * col.a, t);
                // fixed4 finalCol = lerp(col, fixed4(graduaCol, col.a), t * step(0.0001, _GradualAmount));
                // 计算渐变溶解
                fixed4 graduaCol = lerp(col, col / 9, t);
                fixed4 finalCol = lerp(col, pow(graduaCol, 5), t * step(0.0001, _GradualAmount));
                return finalCol * i.color;
            }
            ENDCG
            
        }
    }
}
