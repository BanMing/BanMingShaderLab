
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial;

    public Material material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }
    //模糊迭代--越大越模糊
    [Range(0, 4)]
    public int iteration = 3;

    //模糊展开
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    //设置越大就越模糊，但是过大会造成像素化

    [Range(1, 8)]
    public int downSample = 2;

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            //设置小的缓冲区
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            //这里使用一个buffer来缓存第一个pass获得的效果˝
            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
            //我们利用缩放对图像进行采样，从而减少需要处理的像素点
            //这个跟我们之前设置Texture质量的选项一样
            buffer.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src,buffer);
            
            for (int i = 0; i < iteration; i++)
            {
                material.SetFloat("_BlurSize",1.0f+i*blurSpread);

                RenderTexture buffer1=RenderTexture.GetTemporary(rtW,rtH,0);

                //渲染垂直pass块
                Graphics.Blit(buffer,buffer1,material,0);

                RenderTexture.ReleaseTemporary(buffer);
                buffer=buffer1;
                buffer1=RenderTexture.GetTemporary(rtW,rtH,0);

                //渲染水平pass块
                Graphics.Blit(buffer,buffer1,material,1);

                RenderTexture.ReleaseTemporary(buffer);
                buffer=buffer1;
            }

            Graphics.Blit(buffer,dest);
            RenderTexture.ReleaseTemporary(buffer);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}