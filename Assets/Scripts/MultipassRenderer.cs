using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class MultipassRenderer : ScriptableRenderPass
{
    private List<ShaderTagId> m_Tags;
    private Camera m_Camera;
    
    public MultipassRenderer(List<string> tags)
    {
        m_Tags = new List<ShaderTagId>();

        foreach (var tag in tags)
        {
            m_Tags.Add(new ShaderTagId(tag));
        }
        
        this.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
        m_Camera = Camera.main;
    }
    
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        FilteringSettings filteringSettings = FilteringSettings.defaultValue;

        foreach (ShaderTagId tag in m_Tags)
        {
            DrawingSettings drawingSettings = CreateDrawingSettings(tag, ref renderingData, SortingCriteria.CommonOpaque);

            CommandBuffer cmd = CommandBufferPool.Get();
            
            RendererListParams rendererListParams = new RendererListParams(renderingData.cullResults, drawingSettings, filteringSettings);
            RendererList renderers = context.CreateRendererList(ref rendererListParams);
            
            cmd.DrawRendererList(renderers);
            context.ExecuteCommandBuffer(cmd);
            cmd.Release();
        }
        
        context.Submit();
    }
}
