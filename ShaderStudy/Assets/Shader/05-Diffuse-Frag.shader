
Shader "BanMing/DiffuseFrag" {
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
			float4 vertex:POSITION;
			fixed3 normal :NORMAL;
		};

		struct v2f{
			float4 position :SV_POSITION;
			float3 worldNormalDir:COLOR;
		};

		v2f vert(a2v v){
			v2f f;			
			f.position=UnityObjectToClipPos(v.vertex);

			f.worldNormalDir=UnityObjectToWorldDir((float3)v.normal);
		
			return f;
		}

		fixed4 frag (v2f f):SV_TARGET{
			fixed3 normalDir= normalize(f.worldNormalDir);
			fixed3 ambient= UNITY_LIGHTMODEL_AMBIENT.rgb;
			//光照的位置，因为光是平行光所以也是方向
			fixed3 lightDir=normalize(_WorldSpaceLightPos0.xyz);
			//_LightColor0是光照的颜色
			fixed3 diffuse =_LightColor0.rgb*max(dot(normalDir,lightDir),0);
			fixed3 tempColor =diffuse*_Diffuse.rgb+ambient;
			return fixed4(tempColor,1);
		}

		ENDCG
		}
	}
		FallBack "Diffuse"
}
