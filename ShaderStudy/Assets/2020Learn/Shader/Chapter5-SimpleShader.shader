// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader"
{
    Properties
    {
        // 声明一个Color类型属性
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            // 在CG代码中，我们需要定义一个与属性名称和类型都匹配的变量
            fixed4 _Color;

            // 使用一个结构体来定义顶点着色器的输入
            struct a2v
            {
                // POSITION语义告诉Unity，用模型空间的顶点坐标填充vertex变量
                float4 vertex: POSITION;
                // NORMAL语义告诉Unity，用模型空间的法线方向填充normal变量
                float3 normal: NORMAL;
                // TEXCOORD0语义告诉Unity，用模型的第一套纹理填充texcoord变量
                float4 texcoord: TEXCOORD0;
            };

            // 使用一个结构体来定义顶点着色器的输出
            struct v2f
            {
                // SV_POSITION语义告诉Unity，pos里包含了顶点在裁剪空间中的位置信息
                float4 pos: SV_POSITION;
                // COLOR0语义可以用于存储颜色信息
                fixed3 color: COLOR0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // v.normal包含了顶点的法线方向，其分量范围在[-1,1]
                // 下面代码把分量范围映射到[0,1]
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            fixed4 frag(v2f i): SV_TARGET
            {
                return fixed4(i.color * _Color.rgb, 1);
            }
            ENDCG
            
        }
    }
}