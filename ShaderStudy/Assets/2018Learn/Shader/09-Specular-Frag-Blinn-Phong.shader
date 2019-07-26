
Shader "BanMing/Specular-Frag-Blinn-Phong" {
	Properties{
		_Diffuse("Diffuse Color",Color)=(1,1,1,1)
		_Glass("Glass",Range(8,200))=10
		_SpecularColor("Specular Color",Color)=(1,1,1,1)
	}

	SubShader
	{
		Pass
		{
		Tags{"LightMode"="ForwardBase"}//光照标签
		CGPROGRAM
		float4 _Diffuse;//在Properties中定义了，要在CGPROGAM中使用就需要再次定义
		float4 _SpecularColor;
		half _Glass;
//引入光照文件
#include "Lighting.cginc"

#pragma vertex vert
#pragma fragment frag

		struct a2v {
			float4 vertex:POSITION;
			fixed3 normal :NORMAL;
		};

		struct v2f{
			float4 position :SV_POSITION;
			float3 color:COLOR;
			float3 normalDir:TEXCOORD0;
			float3 viewDir:TEXCOORD1;
		};

		v2f vert(a2v v){
			v2f f;			
			f.position=UnityObjectToClipPos(v.vertex);
			f.normalDir=normalize(UnityObjectToWorldDir((float3)v.normal));
			f.viewDir=UnityObjectToWorldNormal(_WorldSpaceCameraPos.xyz-v.vertex);		
			return f;
		}

		fixed4 frag (v2f f):SV_TARGET{
			fixed3 ambient= UNITY_LIGHTMODEL_AMBIENT.rgb;
			fixed3 lightDir=normalize(_WorldSpaceLightPos0.xyz);
			fixed3 reflectDir=normalize(reflect(-lightDir,f.normalDir));
			fixed3 halfDir=normalize(f.viewDir+reflectDir);	//求两个方向的平分线是像个向量相加		
			fixed3 specular=_LightColor0.rgb*pow(max(dot(reflectDir,halfDir),0),_Glass)*_SpecularColor.rgb;
			fixed3 diffuse =_LightColor0.rgb*max(dot(f.normalDir,lightDir),0);
			fixed3 res =diffuse*_Diffuse.rgb+ambient+specular;
			return fixed4(res,1);
		}
		ENDCG
		}
	}
		FallBack "Diffuse"
}
