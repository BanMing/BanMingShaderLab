Shader "BanMing/Border Aplha"
{
	Properties
	{
		[PerRendererData]_MainTex ("Texture", 2D) = "white" {}
		_AplhaBorder("Aplha Border",Range(1,10))=2
		_AplhaMask("Aplha Mask",Range(0.01,1))=0.05
	}
	SubShader
	{
        Tags
        { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float _AplhaBorder;
			float _AplhaMask;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				// fixed alphaColor : Color;
				float x :TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.x=o.vertex.x/o.vertex.w;
				// o.x=o.vertex.w;//白色
				// if()
				// if(o.x<-_AplhaBorder)
				// 	o.alphaColor= saturate(_AplhaMask-abs(o.x+_AplhaBorder))/_AplhaMask;
				// if(o.x>_AplhaBorder)
				// 	o.alphaColor= saturate(_AplhaMask-abs(o.x-_AplhaBorder))/_AplhaMask;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				// if(i.vertex.x>-_AplhaBorder)
                // 	col *= saturate(_AplhaMask-abs(i.vertex.x+_AplhaBorder))/_AplhaMask;
                // if(i.vertex.x<_AplhaBorder)
                // 	col *= saturate(_AplhaMask-abs(i.vertex.x-_AplhaBorder))/_AplhaMask;

				// if(i.x<-_AplhaBorder)
                // 	col *= saturate(_AplhaMask-abs(i.x+_AplhaBorder))/_AplhaMask;
                // if(i.x>_AplhaBorder)
                // 	col *= saturate(_AplhaMask-abs(i.x-_AplhaBorder))/_AplhaMask;
				// col*=i.alphaColor;
				// return fixed4(i.vertex.w,i.vertex.w,i.vertex.w,1);//白色
				// return fixed4(i.vertex.x,i.vertex.x,i.vertex.x,1);//白色
				// return fixed4(i.x,i.x,i.x,1);//黑白渐变

				col *=saturate(saturate(_AplhaMask-abs(i.x))/_AplhaMask*_AplhaBorder);
				return col;
			}
			ENDCG
		}
	}
}
