Shader "BanMing/BrightnessSaturationAndContrast"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		
		_Brightness("Brightness", Float) = 1
		_Saturation("Staturation", Float) = 1
		_Contrast("Contrast", Float) = 1
	}
	SubShader
	{
		Tags {"RenderType" = "Opaque"}
		LOD 100
		
		Pass
		{
			ZTest Always Cull Off ZWrite Off
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
			half _Brightness; 
			half _Contrast; 
			half _Saturation; 
			
			v2f vert(appdata v)
			{
				v2f o; 
				o.vertex = UnityObjectToClipPos(v.vertex); 
				o.uv = TRANSFORM_TEX(v.uv, _MainTex); 
				return o; 
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 renderTex = tex2D(_MainTex, i.uv); 
				
				//调整亮度
				fixed3 finalCol = renderTex.rgb * _Brightness; 
				
				//饱和度
				fixed luminance = 0.2125 * renderTex.r + 0.7254 * renderTex.g + 0.0721 * renderTex.b; 
				fixed3 luminaceColor = fixed3(luminance, luminance, luminance); 
				finalCol == lerp(luminaceColor, finalCol, _Saturation); 
				
				//对比度
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5); 
				finalCol = lerp(avgColor,finalCol,_Contrast); 
				return fixed4(finalCol,renderTex.a); 
			}
			ENDCG
		}
	}
	Fallback Off
	
}
