// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "BanMing/DiffuseVertex" {
	Properties{
		_Diffuse("Diffuse Color",Color)=(1,1,1,1)
	}

	SubShader
	{
		Pass
		{
		Tags{"LightMode"="ForwardBase"}//光照标签
		CGPROGRAM
		float4 _Diffuse;//在Properties中定义了，要在CGPROGAM中使用就需要再次定义
//引入光照文件
#include "Lighting.cginc"

#pragma vertex vert
#pragma fragment frag

		struct a2v {
			float4 vertex:POSITION;//告诉unity把模型空间下的顶点坐标填充给vertex
			fixed3 normal :NORMAL;
		};

		struct v2f{
			float4 position :SV_POSITION;
			float3 color:COLOR;
		};

		v2f vert(a2v v){
			v2f f;			
			f.position=UnityObjectToClipPos(v.vertex);
			//坐标转换可以使用mul()中间带入参数unity_WorldToObject，同时也可以使用UnityObjectToWorldDir这个方法来调用
			// fixed3 normalDir=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
			//漫反射公式 ：光照颜色*（cos（法线与光照夹角）） 
			//这里求角度使用到了点乘，如果两个向量都是单位向量的话，乘出来就是夹角的cos
			fixed3 normalDir=normalize(UnityObjectToWorldDir((float3)v.normal));
			fixed3 ambient= UNITY_LIGHTMODEL_AMBIENT.rgb;
			//光照的位置，因为光是平行光所以也是方向
			fixed3 lightDir=normalize(_WorldSpaceLightPos0.xyz);
			//_LightColor0是光照的颜色
			fixed3 diffuse =_LightColor0.rgb*max(dot(normalDir,lightDir),0);
			f.color =diffuse*_Diffuse.rgb+ambient;
			return f;
		}

		fixed4 frag (v2f f):SV_TARGET{
			return fixed4(f.color,1);
		}

		ENDCG
		}
	}
		FallBack "Diffuse"
}
