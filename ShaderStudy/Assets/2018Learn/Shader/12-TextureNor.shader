
Shader "BanMing/Texture Nor" {
	Properties{
		// _DiffuseColor("Diffuse Color",Color)=(1,1,1,1)
		_Color("Color",Color)=(1,1,1,1)
		//声明贴图
		_MainTex("Main Texure",2D)="white"{}
		// _SpecularColor("Specular Color",Color)=(1,1,1,1)
		// _Glass("Glass",Range(10,200))=20
	}
	SubShader{

		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			// half _Glass;
			float4 _Color;
			// float4 _DiffuseColor;
			sampler2D _MainTex;
			//固定写法 设置偏移和大小
			float4  _MainTex_ST;
			// float4 _SpecularColor;

			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag

			struct a2v{
				float4 vertex:POSITION;
				fixed3 normal:NORMAL;
				float4 texVertex:TEXCOORD0;
			};

			struct v2f{
				float4 position :SV_POSITION;
				float3 normalDir:TEXCOORD0;
				// float3 viewDir:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f f;
				f.position=UnityObjectToClipPos(v.vertex);
				f.normalDir=normalize(UnityObjectToWorldDir((float3)v.normal));
				// f.viewDir=normalize(_WorldSpaceCameraPos.xyz-v.vertex);
				//获得该点的uv信息并且设置偏移以及大小
				f.uv=v.texVertex.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				return f;
			}

			fixed4 frag(v2f f):SV_TARGET{
				fixed3 lightDir=normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse =_LightColor0.rgb*(dot(f.normalDir,lightDir)*0.5+0.5);
				//根据uv信息找到对应贴图的像素然后融合颜色
				fixed3 texColor= tex2D(_MainTex,f.uv.xy)*_Color.rgb;
				// fixed3 reflectDir=normalize(reflect(-lightDir,f.normalDir));
				// fixed3 halfDir=normalize(f.viewDir+reflectDir);
				// fixed3 specular=_LightColor0.rgb*pow(max(dot(reflectDir,halfDir),0),_Glass);
				//这里需要注意的是要把环境光颜色跟贴图颜色融合，这样才不会受环境光影响
				fixed3 tempColor=diffuse*texColor.rgb+UNITY_LIGHTMODEL_AMBIENT.rgb*texColor;
				return fixed4(tempColor,1);
			}

			ENDCG
		}
		
	}
	Fallback "Specular"
}
