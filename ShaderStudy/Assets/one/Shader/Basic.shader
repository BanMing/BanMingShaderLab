Shader "Tutorial/Basic" {
	Properties {
		
		//下拉菜单
		[KeywordEnum(None, Add, Multiply)] _Overlay ("Overlay mode", Float) = 0
		
		//选择
		[Toggle] _Invert ("Invert color?", Float) = 0
		
		[Toggle(ENABLE_FANCY)] _Fancy ("Fancy?", Float) = 0
		
		[Enum(MyEnum)] _Blend ("Blend mode", Float) = 1
		
		[Enum(One,1,SrcAlpha,5] _Blend2 ("Blend mode subset", Float) = 1
		
		[HideInInspector]
        _Color ("Main Color", Color) = (1,0.5,0.5,1)
		  _WaveScale ("Wave scale", Range (0.02,0.15)) = 0.07 // sliders
		  
		  }
    SubShader {
        Pass {
            Material {
                Diffuse [_Color]
            }
            Lighting On
			
	    }
    }
}
