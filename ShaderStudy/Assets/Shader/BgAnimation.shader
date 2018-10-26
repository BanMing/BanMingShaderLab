Shader "BanMing/BgAnimation"
{
    //一个背景移动的shader
    Properties
    {
        _MainTex("Base Layer (RGB)", 2D) = "white" {}
        _DetailTex("2nd Layer (RGB)", 2D) = "white" {}
        _ScrollX("Base layer Scroll Speed", Float) = 1.0
        _Scroll2X("2nd layer Scroll Speed", Float) = 1.0
        _Multiplier("Layer Multiplier", Float) = 1
    }
    SubShader
    {
       	Tags { 
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		
		Cull off
		Lighting off
		ZWrite off
		Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
                #pragma fragment frag
                // make fog work
            // #pragma multi_compile_fog
            
            #include "UnityCG.cginc"
                
            struct appdata
            {
                float4 vertex : POSITION; 
                float2 uv : TEXCOORD0; 
                
            }; 
            
            struct v2f
            {
                float4 uv : TEXCOORD0; 
                // UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION; 
            }; 
            
            sampler2D _MainTex; 
            sampler2D _DetailTex;
            float4 _MainTex_ST; 
            float4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Multiplier;
            
            v2f vert(appdata v)
            {
                v2f o; 
                o.vertex = UnityObjectToClipPos(v.vertex); 
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) +frac(float2(_ScrollX, 0.0) * _Time.y); 
                o.uv.zw= TRANSFORM_TEX(v.uv, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y); 
                // UNITY_TRANSFER_FOG(o, o.vertex); 
                return o; 
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                
                fixed4 firstLayer = tex2D(_MainTex, i.uv.xy); 
                fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw); 
                fixed4 col =lerp(firstLayer, secondLayer, secondLayer.a); 
                col.rgb *= _Multiplier; 
                return col; 
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col); 
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}
