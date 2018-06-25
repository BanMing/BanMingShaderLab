Shader "BanMing/Gray Sprite"
{
	Properties
	{
		[PerRendererData]_MainTex ("Texture", 2D) = "white" {}
		// _Color("Test Color",Color)=(1,1,1,1)//可用来控制灰度透明度
		_Power("Power",Range(0,1))=0.5//灰度的亮度
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

			// float4 _Color;
			fixed _Power;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				//计算灰度值
				//也可以使用固定值来计算fixed3(0.299，0.587，0.114)
				fixed gray= dot(col.rgb,fixed3(_Power,_Power,_Power));
				col.rgb*=col.a;
				// col.a*=_Color.a;
				return fixed4(gray,gray,gray,col.a);
			}
			ENDCG
		}
	}
}
