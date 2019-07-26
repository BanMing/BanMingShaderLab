Shader"BanMing/FirstShader"{//这里设置shader在material的选项的位置，这里的名字可以跟文件不同
	Properties{
		//公共属性可调节的
		//属性名（“外部显示属性名”，类型）=初始化值
		_Color("Color",Color)=(1,1,1,1)
		_Vector("Vector",Vector)=(0,0,0,0)
		_Int("Int",Int)=1
		_Float("Float",Float)=1.5
		_Range("Range",Range(1,11))=7
		_Texture("Texture", 2D) = "white" { }
		_Cube("Cube",Cube) = "white" {}//天空盒子
		_3D("3D",3D) = "white" {}

		//下拉菜单
		[KeywordEnum(None, Add, Multiply)] _Overlay("Overlay mode", Float) = 0

			//选择
			[Toggle] _Invert("Invert color?", Float) = 0

			[Toggle(ENABLE_FANCY)] _Fancy("Fancy?", Float) = 0

			[Enum(MyEnum)] _Blend("Blend mode", Float) = 1

			[Enum(One,1,SrcAlpha,5] _Blend2("Blend mode subset", Float) = 1

				[HideInInspector]
			_Color("Main Color", Color) = (1,0.5,0.5,1)
			_WaveScale("Wave scale", Range(0.02,0.15)) = 0.07 // sliders

	}
	//可以很多个，可以在不同的显卡上运行
	SubShader{
		//必须有一个Pass块 其中是编写方法
		Pass{
		//这里必须需要注明使用什么语言编写
		CGPROGRAM

		ENDCG
		}
	}
	//当上面的所有shader效果当前显卡都不支持，就选择下面这个
	fallback "Diffuse"
}