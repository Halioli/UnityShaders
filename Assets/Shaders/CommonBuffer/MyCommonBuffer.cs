using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
using UnityEditor;
using UnityEngine.Serialization;

[ExecuteInEditMode]
public class MyCommonBuffer : MonoBehaviour
{

    [ColorUsageAttribute(true,true)] public Color rimlightColor = Color.white;
    [FormerlySerializedAs("BlurSize")] [Tooltip("Default size = 48")][Range(0.0f,1000.0f)] 
    public float blurSize = 0.05f;
    
    public Shader shader;

    public Renderer[] renderers;
    const string shaderName = "Unlit/SHDR_PostProcess";

    private const int SHADER_PASS_MASK = 0;
    private const int SHADER_PASS_BLUR = 1;

    private int maskBuffer = Shader.PropertyToID("_Mask");
    private int glowBuffer = Shader.PropertyToID("_Glow");

    private int blurSizeID = Shader.PropertyToID("_BlurSize");

    private UnityEngine.Rendering.CommandBuffer commandBuffer;
    
    private Camera cam;

    public CameraEvent camEvent = CameraEvent.BeforeForwardOpaque;
    public Material mat;

    //private int bufferPrePass = Shader.PropertyToID("_PrePass");
    //private int bufferAfterPass = Shader.PropertyToID("_AfterPass");

    

    private Mesh MeshFromRenderer(Renderer renderer)
    { 
        if(renderer is MeshRenderer)
        {
            return renderer.GetComponent<MeshFilter>().sharedMesh;
        }
        return null;
    }


    private void CreateCommandBuffer(Camera cam)
    {
        if(renderers == null || renderers.Length == 0)
            return;

        if(commandBuffer == null)
        {
            commandBuffer = new UnityEngine.Rendering.CommandBuffer();
            commandBuffer.name = "MyCommandBuffer: " + gameObject.name;
        }
        else
        {
            commandBuffer.Clear();
        }

        if(mat == null)
        {
            mat = new Material(shader != null ? shader : Shader.Find(shaderName));
        }

        if(rimlightColor.a <= (1f / 255f) || blurSize <= 0f)
        {
            commandBuffer.Clear();
            return;
        }
        int renderersCount = renderers.Length;
        int[] subMeshCount = new int[renderersCount];

        for (int i = 0; i < renderersCount; i++)
        {
            var mesh = MeshFromRenderer(renderers[i]);

            if(mesh != null)
            {
                if (renderers[i].isPartOfStaticBatch)
                    subMeshCount[i] = 1;
                else
                    subMeshCount[i] = mesh.subMeshCount;
            }
        }

        int msaa = 0;

        int width = cam.scaledPixelWidth;
        int height = cam.scaledPixelHeight;

        RenderTextureDescriptor MaskRTD = new RenderTextureDescriptor()
        {
            dimension = TextureDimension.Tex2D,
            graphicsFormat = GraphicsFormat.A10R10G10B10_XRUNormPack32,

            width = width,
            height = height,

            msaaSamples = msaa,
            depthBufferBits = 0,
            sRGB = false,
            useMipMap = true,
            autoGenerateMips = true
        };

        commandBuffer.GetTemporaryRT(maskBuffer, MaskRTD, FilterMode.Trilinear);

        commandBuffer.SetRenderTarget(maskBuffer);
        commandBuffer.ClearRenderTarget(true, true, Color.clear);

        for(int i = 0; i < renderersCount; i++)
        {
            for(int m = 0; m<subMeshCount[i]; m++)
            {
                commandBuffer.DrawRenderer(renderers[i], mat, m, SHADER_PASS_MASK);
                
            }
        }
        commandBuffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
    }

    private void ApplyCommandBuffer(Camera cam)
    {
        CreateCommandBuffer(cam);
        
        if(commandBuffer == null)
            return;

        this.cam = cam;
        this.cam.AddCommandBuffer(camEvent, commandBuffer);
        
    }
    private void RemoveCommandBuffer(Camera cam)
    {
        if (this.cam != null && commandBuffer != null)
        {
            this.cam.RemoveCommandBuffer(camEvent, commandBuffer);
            this.cam = null;
        }
    }
    void OnEnable()
    {
        Camera.onPreRender += ApplyCommandBuffer;
        Camera.onPostRender += RemoveCommandBuffer;
    }

    void OnDisable()
    {
        Camera.onPreRender -= ApplyCommandBuffer;
        Camera.onPostRender -= RemoveCommandBuffer;
    }

#if UNITY_EDITOR
    void OnValidate()
    {
        if (shader == null)
            shader = Shader.Find(shaderName);
    }

#endif

    
}
