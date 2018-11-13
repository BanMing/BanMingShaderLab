using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class MotionBlur : PostEffectBase
{
    public Shader motionBlurShader;
    private Material motionBlurMaterial;

    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    /// <summary>
    /// 值越大拖尾越大
    /// </summary>
    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;

    //用于保存之前图像叠加效果
    private RenderTexture accumulationTexture;

    /// <summary>
    /// This function is called when the MonoBehaviour will be destroyed.
    /// </summary>
    void OnDestroy()
    {
        DestroyImmediate(accumulationTexture);
    }

    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            if (accumulationTexture==null||accumulationTexture.width!=src.width||
            accumulationTexture.height!=src.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture=new RenderTexture(src.width,src.height,0);
                accumulationTexture.hideFlags=HideFlags.HideAndDontSave;
                Graphics.Blit(src,accumulationTexture);
            }

            accumulationTexture.MarkRestoreExpected();

            material.SetFloat("_BlurAmount",1.0f-blurAmount);

            Graphics.Blit(src,accumulationTexture,material);
            Graphics.Blit(accumulationTexture,dest);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}