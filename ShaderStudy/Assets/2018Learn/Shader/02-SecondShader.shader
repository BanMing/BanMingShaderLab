// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BanMing/SecondShader" {
	Properties {

	}
	SubShader {
		Pass{
				CGPROGRAM
				//顶点函数，这里只是声明顶点函数的函数名
				//从模型空间转换到剪裁空间的转换（从游戏环境转换到视野相机屏幕上）
#pragma vertex vert
				//片元函数，这里只是声明片元函数的函数名
				//返回模型对应在屏幕上的每一个像素的颜色值
#pragma fragment frag

					float4 vert(float4 v :POSITION) :SV_POSITION{
						//通过语义告诉系统，我这个参数是干嘛的，比如POSITION是要告诉系统我要的顶点坐标
						//SV_POSITION这个语义用来解释说明返回值，意思是返回值时剪裁空间下的顶点坐标
						return UnityObjectToClipPos(v);
					}
					
					fixed4 frag() :SV_Target {
						return fixed4(1,1,1,1);
					}
					
				ENDCG
		}
	}
	FallBack "Diffuse"
}
