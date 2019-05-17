Shader "BanMing/RoleEffect"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" { }
        _NoiseTex ("Distortion Texture", 2D) = "grey" { }
        _DistMask ("Distortion Mask", 2D) = "black" { }
        _NoiseSpeedX ("Noise Speed X", Float) = 0
        _NoiseSpeedY ("Noise Speed Y", Float) = 0
        _NoiseAmount ("Noise Amount", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Cull off
        Lighting off
        ZWrite off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _DistMask;
            float _NoiseSpeedX;
            float _NoiseSpeedY;
            float _NoiseAmount;

            float4 _NoiseTex_ST;
            float4 _DistMask_ST;
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float2 noiseTex: TEXCOORD1;
                float2 maskTex: TEXCOORD2;
                float4 vertex: SV_POSITION;
            };

            // 对噪声图做采样
            fixed2 SamplerFormNoise(float2 uv)
            {
                float2 newUV = uv * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                // 将颜色信息从（0，1）转换到坐标偏移（-1，-1）后缩放一下，来适配对应uv单位
                fixed4 noiseColor = tex2D(_NoiseTex, newUV);//( * 2 - 1) * 0.005;
                return pow(noiseColor.xy, _NoiseAmount);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.noiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
                o.maskTex = TRANSFORM_TEX(v.uv, _DistMask);
                o.uv = v.uv;
                return o;
            }

            
            fixed4 frag(v2f i): SV_Target
            {
                //获得时间随机数
                float2 timer = float2(_Time.x, _Time.x);
                fixed2 offset = SamplerFormNoise(i.noiseTex + timer * float2(_NoiseSpeedX, _NoiseSpeedY));
                // 读取遮罩图
                fixed distMask = tex2D(_DistMask, i.maskTex).a;

                fixed4 col = tex2D(_MainTex, i.uv + offset * distMask);
                
                return col;
                // return fixed4(distMask,1,1,1);
            }
            
            ENDCG
            
        }
    }
}
