Shader "BanMing/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        //混合系数
        _BlurAmount ("Blur Amount", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;
        sampler2D _MainTex_ST;
        fixed _BlurAmount;
        
        struct v2f
        {
            float4 pos: SV_POSITION;
            half2 uv: TEXCOORD0;
        };
        
        
        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            
            return o;
        }
        ENDCG
        
        ZTest Always Cull Off ZWrite Off
        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment fragRGB
            
            fixed4 fragRGB(v2f i): SV_TARGET
            {
                return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
            }
            ENDCG
            
        }
        Pass
        {
            
            Blend One Zero
            ColorMask A
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment fragA
            
            fixed4 fragA(v2f i): SV_TARGET
            {
                return tex2D(_MainTex, i.uv);
            }
            
            
            
            
            
            ENDCG
            
        }
    }
}
