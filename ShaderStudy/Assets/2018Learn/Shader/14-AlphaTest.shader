
Shader "BanMing/Alpha Test" {
	Properties{
		_Color("Color",Color)=(1,1,1,1)
		//声明贴图
		_MainTex("Main Texure",2D)="white"{}
		//bump是在没有设置法线贴图的时候就使用自带的法线
		_NormalTex("Normal Texure",2D)="bump"{}
		//设置法线效果
		_BumpScale("BumpScale",Range(0,10))=1
		//设置阀值
		_Cutoff("Alpha Cutoff",Range(0,1))=0.5
	}
	SubShader{
		Tags{"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			float4 _Color;
			sampler2D _MainTex;
			//固定写法 设置偏移和大小
			float4  _MainTex_ST;
			sampler2D _NormalTex;
			float4 _NormalTex_ST;
			float _BumpScale;
			fixed _Cutoff;
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag

			struct a2v{
				float4 vertex:POSITION;
				//切线空间的确定是通过（存储在模型中的）法线与切线确定的
				fixed3 normal:NORMAL;
				//tangent.w是来确定切线空间坐标轴的方向
				float4 tangent:TANGENT;
				float4 texVertex:TEXCOORD0;
			};

			struct v2f{
				float4 position :SV_POSITION;
				float3 lightDir:TEXCOORD0;//切线空间下 平行光的方向
				float4 uv:TEXCOORD2;//xy用来存储主要的的贴图纹理坐标 zw用来存储法线贴图的纹理坐标
			};

			v2f vert(a2v v){
				v2f f;
				f.position=UnityObjectToClipPos(v.vertex);
				f.uv.xy=v.texVertex.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				f.uv.zw=v.texVertex.xy*_NormalTex_ST.xy+_NormalTex_ST.zw;
				TANGENT_SPACE_ROTATION;//这里会得到一个 rotation 是用来把模型空间转化成切线空间
				f.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex));
				return f;
			}
			//跟法线方向有关的运算都要放在切线空间下
			//从法线贴图里面去的法线方向是切线空间下的
			fixed4 frag(v2f f):SV_TARGET{
				fixed3 lightDir=normalize(f.lightDir);
				//切线空间的法线 
				fixed4 normalColor= tex2D(_NormalTex,f.uv.zw);
				// 法线值=2*（法线贴图颜色值-0.5）
				//颜色的值的范围是[0,1]，法线是向量是需要方向，这里就把[0,1]分界为[0,0.5]与[0.5,1]
				//跟半兰伯特一样的计算方式
				fixed3 normalDir= normalize(UnpackNormal(normalColor));
				//因为z轴是固定该点的法线，并且由公式x^2+y^2+z^2=1的关系来控制
				normalDir.xy=normalDir.xy*_BumpScale;
				fixed3 diffuse =_LightColor0.rgb*(dot(normalDir,lightDir)*0.5+0.5);
				fixed4 texColor= tex2D(_MainTex,f.uv.xy);
				clip(texColor.a-_Cutoff);
				fixed3 aldedo=texColor.rgb*_Color.rgb;
				fixed3 tempColor=diffuse*aldedo+UNITY_LIGHTMODEL_AMBIENT.rgb*aldedo;
				return fixed4(tempColor,1);
			}

			ENDCG
		}
		
	}
	Fallback "Specular"
}
