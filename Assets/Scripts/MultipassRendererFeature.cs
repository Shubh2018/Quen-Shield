using System.Collections.Generic;
using UnityEngine.Rendering.Universal;

public class MultipassRendererFeature : ScriptableRendererFeature
{
    public List<string> rendertags = new List<string>();
    private MultipassRenderer outlinePass;
    
    public override void Create()
    {
        outlinePass = new MultipassRenderer(rendertags);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(outlinePass);
    }
}
