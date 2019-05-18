Shader "BanMing/RoleEffect"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" { }
        _NoiseTex ("Distortion Texture", 2D) = "grey" { }
        // 扰动遮罩
        _DistMask ("Distortion Mask", 2D) = "black" { }
        // 扰动方向速度
        _NoiseSpeedX ("Noise Speed X", Float) = 0
        _NoiseSpeedY ("Noise Speed Y", Float) = 0
        _NoiseAmount ("Noise Amount", Float) = 0


        _EffectsLayer1Tex ("_EffectsLayer1Tex", 2D) = "black" { }
        _EffectsLayer1Color ("_EffectsLayer1Color", Color) = (1, 1, 1, 1)
        _EffectsLayer1Motion ("_EffectsLayer1Motion", 2D) = "black" { }
        _EffectsLayer1MotionSpeed ("_EffectsLayer1MotionSpeed", float) = 0
        _EffectsLayer1Rotation ("_EffectsLayer1Rotation", float) = 0
        _EffectsLayer1PivotScale ("_EffectsLayer1PivotScale", Vector) = (0.5, 0.5, 1, 1)
        _EffectsLayer1Translation ("_EffectsLayer1Translation", Vector) = (0, 0, 0, 0)
        _EffectsLayer1Foreground ("_EffectsLayer1Foreground", float) = 0
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

            float _EffectsLayer1Rotation;
            sampler2D _EffectsLayer1Tex;
            float4 _EffectsLayer1Tex_ST;
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float2 noiseTex: TEXCOORD1;
                float4 vertex: SV_POSITION;
            };
            // 旋转贴图
            fixed2 RotateTex(float2 uv, float rotationSpeed)
            {
                float degrees = _Time.x * rotationSpeed;
                fixed2 poivt = fixed2(0.5, 0.5);
                fixed cs = cos(degrees);
                fixed sn = sin(degrees);
                return mul(float2x2(cs, -sn, sn, cs), uv - poivt) + poivt;
            }
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
                o.uv = v.uv;
                return o;
            }

            
            fixed4 frag(v2f i): SV_Target
            {
                //获得时间随机数
                float2 timer = float2(_Time.x, _Time.x);
                fixed2 offset = SamplerFormNoise(i.uv + timer * float2(_NoiseSpeedX, _NoiseSpeedY));
                // 读取遮罩图
                fixed distMask = tex2D(_DistMask, i.uv).a;
                // 旋转测试
                // fixed4 rotateCol = tex2D(_EffectsLayer1Tex, RotateTex(i.uv, _EffectsLayer1Rotation));
                fixed4 col = tex2D(_MainTex, i.uv + offset * distMask);// + rotateCol;
                
                return col;
                // return fixed4(distMask,1,1,1);
            }
            
            ENDCG
            
        }
    }
}
