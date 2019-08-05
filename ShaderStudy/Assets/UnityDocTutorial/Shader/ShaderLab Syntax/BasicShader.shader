//////////////////////////////////////////////////////////////////////////////////////////
//// sasda.cs
//// time:2019/7/26 上午11:42:07			
//// author:BanMing   
//// des:基础shader，返回红色
////////////////////////////////////////////////////////////////////////////////////////////
Shader "Tutorial/Basic"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 0.5, 0.5, 1)
    }
    SubShader
    {
        Pass
        {
            Material
            {
                Diffuse[_Color]
            }
            Lighting On
        }
    }
}