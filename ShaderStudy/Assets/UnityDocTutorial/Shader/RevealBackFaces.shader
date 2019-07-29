//////////////////////////////////////////////////////////////////////////////////////////
//// RevealBackFaces.shader
//// time:2019/7/29 下午4:35:58
//// author:BanMing
//// des: https://docs.unity3d.com/Manual/SL-CullAndDepth.html
////////////////////////////////////////////////////////////////////////////////////////////

Shader "Reveal Backfaces"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" { }
    }
    SubShader
    {
        // Render the front-facing parts of the object.
        // We use a simple white material, and apply the main texture.
        Pass
        {
            Material
            {
                Diffuse(1, 1, 1, 1)
            }
            Lighting On
            SetTexture [_MainTex]
            {
                Combine Primary * Texture
                // Combine  Texture
            }
        }
        
        // Now we render the back-facing triangles in the most
        // irritating color in the world: BRIGHT PINK!
        Pass
        {
            Color(1, 0, 1, 1)
            Cull Front
        }
    }
}