using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
using UnityEditor;

[ExecuteInEditMode]
public class MyCommonBuffer : MonoBehaviour
{
    public CameraEvent camEvent = CameraEvent.AfterForwardOpaque;
    public Material mat;

    private int bufferPrePass = Shader.PropertyToID("_PrePass");
    private int bufferAfterPass = Shader.PropertyToID("_AfterPass");
    private CommandBuffer cb;
    private Camera cam;

    private void OnValidate()
    {
        CreateCommonBuffer();
        Camera.main.AddCommandBuffer(camEvent, cb);
    }

    void CreateCommonBuffer()
    {
        if (cb == null)
        {
            cb = new CommandBuffer();
            cb.name = "MyCommonBuffer";
            cam.AddCommandBuffer(camEvent, cb);
        }
        else
        {
            cb.Clear();
        }
        if (cam == null)
            cam = Camera.main;
        if (mat == null)
            mat = new Material(Shader.Find("Unlit/SHDR_PostProcess"));

        RenderTextureDescriptor rtd = new RenderTextureDescriptor()
        {
            height = 1080,
            width = 1920,
            msaaSamples = 0,
            graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R16G16B16_SFloat,
            dimension = TextureDimension.Tex2D,
            useMipMap = false
        };

        //cb.GetTemporaryRT(bufferPrePass, rtd, FilterMode.Bilinear);

        cb.Blit(bufferPrePass, BuiltinRenderTextureType.CameraTarget, mat);
    }
}
