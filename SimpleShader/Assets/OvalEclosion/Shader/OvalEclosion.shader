Shader "Unlit/Oval Eclosion"
{
	Properties
	{
		[PerRendererData]_MainTex ("Texture", 2D) = "white" {}
		_EclosionScale("Eclosion Scale",Range(0.0000001,5))=0//羽化的大小
		_PointX("Point X",Range(0,1))=0.5//x坐标
		_PointY("Point Y",Range(0,1))=0.5//y坐标
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
			float _EclosionScale;
			fixed _PointY;
			fixed _PointX;

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
				//计算点到圆心的距离
				float dx=i.uv.x-_PointX;
				float dy=i.uv.y-_PointY;
				float dstSq=pow(dx,2.0)+pow(dy,2.0);
				float v=(dstSq/_EclosionScale);
				col *= saturate(1-v);
				return col;				
			}
			ENDCG
		}
	}
}
