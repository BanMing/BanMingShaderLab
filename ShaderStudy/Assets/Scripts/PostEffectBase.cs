using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{

    // Use this for initialization
    void Start()
    {
        CheckResoures();
    }
    //在最开始调用
    protected void CheckResoures()
    {
        var isSupported = CheckSupport();
        if (!isSupported)
        {
            NoSupport();
        }
    }
    //检查是否支持
    protected bool CheckSupport()
    {
        if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        {
            Debug.LogWarning("此平台不支持图片效果后处理");
            return false;
        }
        return true;
    }

    //取消该脚本效果
    protected void NoSupport()
    {
        enabled = false;
    }

	//检查shader是否存在并创建该shader的材质
	protected Material CheckShaderAndCreateMaterial(Shader shader,Material material){
		if (shader==null)
		{
			return null;
		}
		if (shader.isSupported&&material&&material.shader==shader)
		{
			return material;
		}
		if (!shader.isSupported)
		{
			return null;
		}else
		{
			material=new Material(shader);
			material.hideFlags=HideFlags.DontSave;
			if (material)
			{
				return material;
			}else
			{
				return null;
			}
		}
	}
}
