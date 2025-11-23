using System.Collections.Generic;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RendererUtils;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

[System.Serializable]
public class OutlineRenderPass : ScriptableRenderPass
{
    private List<ShaderTagId> m_Tags;
    
    public OutlineRenderPass(List<string> tags)
    {
        m_Tags = new List<ShaderTagId>();

        foreach (var tag in tags)
        {
            m_Tags.Add(new ShaderTagId(tag));
        }
        
        renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }
    
    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        var cameraData = frameData.Get<UniversalCameraData>();
        var renderingData = frameData.Get<UniversalRenderingData>();
        var resourceData = frameData.Get<UniversalResourceData>();

        var cameraColor = resourceData.cameraColor;
        var cameraDepth = resourceData.cameraDepth;
        
        foreach(ShaderTagId tag in m_Tags)
        {
            string passName = $"Outline {tag}";

            using (var builder = renderGraph.AddRasterRenderPass(passName, out PassData passData))
            {
                builder.SetRenderAttachment(cameraColor, 0);
                builder.SetRenderAttachmentDepth(cameraDepth, AccessFlags.ReadWrite);
                
                RendererListDesc desc = CreateRendererListDesc(tag, cameraData, renderingData);
                passData.rendererList = renderGraph.CreateRendererList(desc);
                
                builder.UseRendererList(passData.rendererList);
                
                builder.SetRenderFunc((PassData passData, RasterGraphContext context) =>
                {
                    context.cmd.DrawRendererList(passData.rendererList);
                });
            }
        }
    }

    private class PassData
    {
        public RendererListHandle rendererList;
    }

    private RendererListDesc CreateRendererListDesc(ShaderTagId passID, UniversalCameraData cameraData,
        UniversalRenderingData renderingData)
    {
        RendererListDesc rendererListDesc = new RendererListDesc(passID, renderingData.cullResults, cameraData.camera)
        {
            sortingCriteria = SortingCriteria.CommonOpaque,
            rendererConfiguration = PerObjectData.None,
            renderQueueRange = RenderQueueRange.all,
            layerMask = cameraData.camera.cullingMask,
        };
        
        return rendererListDesc;
    }
}
