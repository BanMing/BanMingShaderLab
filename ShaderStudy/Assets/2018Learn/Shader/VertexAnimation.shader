// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BanMing/VertexAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Magnitude ("Distortion Magnitude", Float) = 1
        _Frequency ("Distortion Frequency", Float) = 1
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
        _Speed ("Speed", Float) = 0.5
    }
    SubShader
    {
        //顶点动画需要静止批处理
        Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
        LOD 100
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
            };
            
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Frequency;
            float _InvWaveLength;
            float _Magnitude;
            float _Speed;
            fixed4 _Color;

            v2f vert(appdata v)
            {
                v2f o;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                float4 offset;
                offset.yzw = float3(0.0, 0.0, 0.0);
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
                o.uv += float2(_Time.y * _Speed, 0.0);
                o.vertex = UnityObjectToClipPos(v.vertex + offset);
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col * _Color;
            }
            ENDCG
            
        }
    }
    Fallback "VertexLit"
}
