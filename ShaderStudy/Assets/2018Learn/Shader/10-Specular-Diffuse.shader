
Shader "BanMing/Specular-Diffuse" {
	Properties{
		_DiffuseColor("Diffuse Color",Color)=(1,1,1,1)
		_SpecularColor("Specular Color",Color)=(1,1,1,1)
		_Glass("Glass",Range(10,200))=20
	}
	SubShader{

		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			half _Glass;
			float4 _DiffuseColor;
			float4 _SpecularColor;

			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag

			struct a2v{
				float4 vertex:POSITION;
				fixed3 normal:NORMAL;
			};

			struct v2f{
				float4 position :SV_POSITION;
				float3 normalDir:TEXCOORD0;
				float3 viewDir:TEXCOORD1;
			};

			v2f vert(a2v v){
				v2f f;
				f.position=UnityObjectToClipPos(v.vertex);
				f.normalDir=normalize(UnityObjectToWorldDir((float3)v.normal));
				f.viewDir=normalize(_WorldSpaceCameraPos.xyz-v.vertex);
				return f;
			}

			fixed4 frag(v2f f):SV_TARGET{
				fixed3 lightDir=normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse =_LightColor0.rgb*(dot(f.normalDir,lightDir)*0.5+0.5);
				fixed3 reflectDir=normalize(reflect(-lightDir,f.normalDir));
				fixed3 halfDir=normalize(f.viewDir+reflectDir);
				fixed3 specular=_LightColor0.rgb*pow(max(dot(reflectDir,halfDir),0),_Glass);
				fixed3 tempColor=diffuse*_DiffuseColor.rgb+specular*_SpecularColor.rgb+UNITY_LIGHTMODEL_AMBIENT.rgb;
				return fixed4(tempColor,1);
			}

			ENDCG
		}
		
	}
	Fallback "Specular"
}
