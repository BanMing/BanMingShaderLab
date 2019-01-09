Shader "BanMing/GrabPassTest"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
    
    //捕捉屏幕色块测试
    SubShader
    {
        
        Tags {"Queue" = "Transparent"}

        //这里不填参数捕捉到的色块导入的贴图名字默认叫_GrabTexture
        //这里也可以填上自定义名字
        // GrabPass{"_BackgroundTexture"}
        GrabPass {}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
                #pragma fragment frag
                
            #include "UnityCG.cginc"
                
            
            struct v2f
            {
                float4 grabPos : TEXCOORD0; 
                float4 vertex : SV_POSITION; 
            }; 
            
            v2f vert(appdata_base v)
            {
                v2f o; 
                o.vertex = UnityObjectToClipPos(v.vertex); 
                // 使用ComputeGrabScreenPos方法在UnityCG.cginc
                //去获得正确的坐标
                o.grabPos = ComputeGrabScreenPos(o.vertex); 
                return o; 
            }
            
            sampler2D _GrabTexture; 
            
            fixed4 frag(v2f i) : SV_Target
            {
                half4 bgColor=tex2Dproj(_GrabTexture,i.grabPos);
                // 反差色
                return 1-bgColor; 
            }
            ENDCG
        }
    }
}
