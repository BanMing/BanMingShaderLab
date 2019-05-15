Shader "BanMing/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        
        
        CGINCLUDE
        #include "UnityCG.cginc"
        //这段是作为一个外部引用来使用
        //跟上面的#include "UnityCG.cginc"一个道理
        //作为通用方法来使用
        sampler2D _MainTex;
        sampler2D _MainTex_ST;
        half4 _MainTex_TexelSize;
        float _BlurSize;
        
        struct v2f
        {
            float4 pos: SV_POSITION;
            half2 uv[5]: TEXCOORD0;
        };
        
        
        
        
        fixed4 fragBulur(v2f i): SV_Target
        {
            float weight[3] = {
                0.4026, 0.2442, 0.0545
            };
            
            
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
            
            for (int it = 1; it < 3; it ++)
            {
                sum += tex2D(_MainTex, i.uv[it]).rgb * weight[it];
                sum += tex2D(_MainTex, i.uv[2 * it]).rgb * weight[it];
            }
            
            return fixed4(sum, 1.0);
        }
        
        ENDCG
        
        ZTest Always Cull Off ZWrite Off
        
        Pass
        {
            NAME "Vertical_Blur"
            CGPROGRAM
            
            #pragma vertex vertBlurVertical
            #pragma fragment fragBulur
            
            v2f vertBlurVertical(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                half2 uv = v.texcoord;
                
                o.uv[0] = uv;
                o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[3] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
                o.uv[2] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
                o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
                
                return o;
            }
            ENDCG
            
        }
        Pass
        {
            NAME "Horizontal_Blur"
            CGPROGRAM
            
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBulur
            
            v2f vertBlurHorizontal(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                half2 uv = v.texcoord;
                
                o.uv[0] = uv;
                o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
                o.uv[3] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
                o.uv[2] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
                o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
                
                return o;
            }
            ENDCG
            
        }
    }
    Fallback Off
}
