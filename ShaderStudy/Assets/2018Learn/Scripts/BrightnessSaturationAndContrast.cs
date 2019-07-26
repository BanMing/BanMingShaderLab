
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class BrightnessSaturationAndContrast : PostEffectBase
{
    public Shader briSatConShader;
    private Material briSatConMaterial;
    [Range(0, 3)]
    public float brightness = 1.0f;

    [Range(0, 3)]
    public float saturation = 1.0f;

    [Range(0, 3)]
    public float contrast = 1.0f;
    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }
    /// <summary>
    /// OnRenderImage is called after all rendering is complete to render image.
    /// </summary>
    /// <param name="src">The source RenderTexture.</param>
    /// <param name="dest">The destination RenderTexture.</param>
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material!=null)
        {
            material.SetFloat("_Brightness",brightness);
            material.SetFloat("_Saturation",saturation);
            material.SetFloat("_Contrast",contrast);

            Graphics.Blit(src,dest,material);
        }else
        {
            // Debug.Log("@@@@@@@@2");
            Graphics.Blit(src,dest);
        }
    }
}