//////////////////////////////////////////////////////////////////////////////////////////
//// BlendTest.shader
//// time:2019/7/31 下午2:41:57
//// author:BanMing
//// des:
////////////////////////////////////////////////////////////////////////////////////////////

Shader "Tutorial/BlendTest"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        // Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        Cull Off ZWrite Off ZTest Off
        // 标准透明
        // Blend SrcAlpha OneMinusSrcAlpha
        
        // 柔和相加 {Soft Additive}
        // Blend OneMinusDstColor One
        
        // 正片叠底 { Multiply }，即相乘
        // Blend DstColor Zero
        
        // 两倍相乘 { 2x Multiply }
        // Blend DstColor SrcColor

        // 变暗 { Darken }
        // BlendOp Min
        // Blend One One
        
        // 变亮 { Lighten }
        // BlendOp Max
        // Blend One One

        // 滤色 { Screen }
        // Blend OneMinusDstColor One
        // Blend One OneMinusSrcColor

        // 线性减淡 { Liner Dodge }
        // Blend One One

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
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
                fixed4 color: COLOR;
            };
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.uv = v.uv;
                return o;
            }
            
            sampler2D _MainTex;
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                // col.rgb = 1 - col.rgb;
                return col * i.color;
            }
            ENDCG
            
        }
    }
}