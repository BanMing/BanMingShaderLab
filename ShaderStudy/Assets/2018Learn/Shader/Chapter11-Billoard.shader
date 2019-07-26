// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BanMing/Chapter11-Billoard"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_VerticalBillboarding("Vertical Restraints", Range(0, 1)) = 1
	}
	SubShader
	{
		//需要关闭批处理因为有顶点动画
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "False"}
		
		Pass
		{
			
			Tags {"LightMode" = "ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
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
			fixed4 _Color; 
			fixed _VerticalBillboarding; 
			
			v2f vert(appdata v)
			{
				v2f o; 
				
				// o.vertex = UnityObjectToClipPos(v.vertex); 
				o.uv = TRANSFORM_TEX(v.uv, _MainTex); 
				//选择模型空间的原点设为锚点
				float3 center = float3(0,0,0);
				float3 viewer=mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
				//计算法线方向 _VerticalBillboarding控制垂直方向的约束度
				float3 normalDir=viewer-center;
				normalDir.y=normalDir.y*_VerticalBillboarding;
				normalDir=normalize(normalDir);

				//计算出向上的方向与向右的方向
				float3 upDir=abs(normalDir.y)>0.999?float3(0,0,1):float3(0,1,0);
				float3 rightDir=normalize(cross(upDir,normalDir));
				upDir=normalize(cross(normalDir,rightDir));

				float3 centerOffs=v.vertex.xyz-center;
				float3 loaclPos=center+rightDir*centerOffs.x+upDir*centerOffs.y+normalDir*centerOffs.z;
				o.vertex=UnityObjectToClipPos(float4(loaclPos,1));
				return o; 
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv); 
				return col*_Color; 
			}
			ENDCG
		}
	}
}
