using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class Bloom : PostEffectBase
{
    public Shader bloomShader;
    private Material bloomMaterial;

    private Material material
    {
        get
        {
            bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            return bloomMaterial;
        }
    }
    [Range(0, 4)]
    public int iterations = 3;
    [Range(0.2f, 3.0f)]
    public float blurrSpread = 0.6f;
    [Range(1, 8)]
    public int downSample = 2;
    [Range(0.0f, 4.0f)]
    public float luminaceThreshold = 0.6f;

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_LuminaceThreshold", luminaceThreshold);

            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            //执行获得亮度 存储亮度到buffer0
            Graphics.Blit(src,buffer0,material,0);

            //模糊亮度
            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", blurrSpread * i * 1.0f);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //执行垂直方向模糊 
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //执行横向模糊
                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            
            material.SetTexture("_Bloom", buffer0);
            Graphics.Blit(src,dest,material,3);
            
            RenderTexture.ReleaseTemporary(buffer0);

        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}