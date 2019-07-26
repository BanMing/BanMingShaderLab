>**unity官方引导**


[顶点片元官方引导](https://docs.unity3d.com/Manual/ShaderTut2.html)

![Unity Shader执行流程](../Images/PipelineCullDepth.png)

[渲染队列、ZWrite和ZTest](https://blog.csdn.net/lyh916/article/details/45317571)

*需要注意的是，当ZTest取值为Off时，表示的是关闭深度测试，等价于取值为Always，而不是Never！Always指的是直接将当前像素颜色(不是深度)写进颜色缓冲区中；而Never指的是不要将当前像素颜色写进颜色缓冲区中，相当于消失。*



| ZWrite | ZTest | 是否写入深度缓存 | 是否写入颜色缓存 |
| ------ | ----- | ---------------- | ---------------- |
| On     | On    | 写入             | 写入             |
| On     | Off   | 不写入           | 不写入           |
| Off    | On    | 写入             | 不写入           |
| Off    | Off   | 不写入           | 不写入           |