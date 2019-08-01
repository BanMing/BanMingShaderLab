//////////////////////////////////////////////////////////////////////////////////////////
//// StencilLookTest.shader
//// time:2019/8/1 下午10:22:02
//// author:BanMing
//// des: 遮罩查看器
////////////////////////////////////////////////////////////////////////////////////////////

Shader "Tutorial/StencilLookTest"
{
    SubShader
    {
        
        // 关闭深度测试
        ZTest Off
        ZWrite Off
        
        ColorMask 0
        Stencil
        {
            Ref 1
            Comp Always
            Pass Replace
        }
        
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
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };
            
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                return fixed4(1, 1, 1, 1);
            }
            ENDCG
            
        }
    }
}