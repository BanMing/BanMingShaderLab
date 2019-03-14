Shader "UI/UIBlur"
{
    Properties
    {
        _BlurSize ("Blur Size", Range(0, 5)) = 1
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        //因为我们需要记录当前的屏幕所以是需要透明通道
        Tags { "Queue" = "Transparent" }
        // 横向模糊
        GrabPass { }
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_BlurHorizontal
            #pragma fragment frag_Blur
            
            ENDCG
            
        }
        
        // 纵向模糊
        GrabPass { }
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_BlurVertical
            #pragma fragment frag_Blur
            
            ENDCG
            
        }
    }
    CGINCLUDE
    #include "UnityCG.cginc"
    
    sampler2D _GrabTexture;
    half4 _GrabTexture_TexelSize;
    float _BlurSize;
    float _DownSampleNum;
    fixed4 _Color;
    
    //准备高斯模糊权重矩阵参数7x4的矩阵 ||  Gauss Weight
    static const half4 GaussWeight[7] = {
        half4(0.0205, 0.0205, 0.0205, 0),
        half4(0.0855, 0.0855, 0.0855, 0),
        half4(0.232, 0.232, 0.232, 0),
        half4(0.324, 0.324, 0.324, 1),
        half4(0.232, 0.232, 0.232, 0),
        half4(0.0855, 0.0855, 0.0855, 0),
        half4(0.0205, 0.0205, 0.0205, 0)
    };
    
    struct v2f
    {
        float4 vertex: SV_POSITION;
        //一级纹理（纹理坐标）
        half4 uv: TEXCOORD0;
        //二级纹理（偏移量）
        half2 offset: TEXCOORD1;
    };
    
    v2f vert_BlurVertical(appdata_base v)
    {
        v2f o;
        
        o.vertex = UnityObjectToClipPos(v.vertex);
        //获得屏幕填色
        float4 grabPos = ComputeGrabScreenPos(o.vertex);
        o.uv = half4(grabPos.xy, 1, 1);
        // 设置偏移
        o.offset = _GrabTexture_TexelSize.xy * half2(1.0, 0.0) * _BlurSize ;
        return o;
    }
    
    v2f vert_BlurHorizontal(appdata_base v)
    {
        v2f o;
        
        o.vertex = UnityObjectToClipPos(v.vertex);
        //获得屏幕填色
        float4 grabPos = ComputeGrabScreenPos(o.vertex);
        o.uv = half4(grabPos.xy, 1, 1);
        // 设置偏移
        o.offset = _GrabTexture_TexelSize.xy * half2(0.0, 1.0) * _BlurSize;
        return o;
    }
    
    // 公用片面方法
    fixed4 frag_Blur(v2f i): SV_TARGET
    {
        half2 uv = i.uv.xy;
        
        half2 offsetWidth = i.offset;
        
        //从中心点偏移3个间隔，从最左或最上开始加权累加
        half2 uv_withOffset = uv - offsetWidth * 3.0;
        //循环获取加权后的颜色值
        half4 color = 0;
        for (int j = 0; j < 7; j ++)
        {
            //偏移后的像素纹理值
            half4 texCol = tex2D(_GrabTexture, uv_withOffset);
            //待输出颜色值+=偏移后的像素纹理值 x 高斯权重
            color += texCol * GaussWeight[j];
            //移到下一个像素处，准备下一次循环加权
            uv_withOffset += offsetWidth;
        }
        return color * _Color;
    }
    ENDCG
    
    Fallback off
}
