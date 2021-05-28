#include "NumanLib.as";
#include "NuHub.as";

NuHub@ o_hub = @null;//Outer hub

namespace NuRender
{
    bool init = false;//Has initialized yet?
    NuHub@ i_hub = @null;//Inner hub

    void onInit(CRules@ rules)
    {
        if(!isClient())
        {
            return;
        }
        
        if(!InitHub(rules, @i_hub)) { return; }

        init = true;//Initialized
    }

    void onTick(CRules@ rules)
    {
        if(!isClient())
        {
            return;
        }

        if(i_hub == @null)
        {
            error("hub was null"); return;
        }

        i_hub.FRAME_TIME = 0.0f;

        i_hub.RenderClear();
    }

    void onRender(CRules@ rules)
    {
        i_hub.FRAME_TIME += getRenderDeltaTime() * getTicksASecond();
    }

    void ImageRender(NuHub@ hub, Render::ScriptLayer layer)
    {
        Render::SetAlphaBlend(true);
        
        u16 image_count = hub.render_details[layer].size();

        for(u16 i = 0; i < image_count; i++)
        {
            RenderDetails@ details = @hub.render_details[layer][i];
            if(details == @null)
            {
                error("Image was somehow null in rendering. This should not happen."); continue;
            }
            RENDER_CALLBACK@ func = details.getFunc();
            if(func != @null)//Has a function?
            {
                func();//Call it.
            }
            else//No function?
            {
                if(details.image != @null)//Has an image?
                {
                    if(!details.world_pos)//Not world pos?
                    {
                        Render::SetTransformScreenspace();//Screen space
                    }
                    else//World pos
                    {
                        Render::SetTransformWorldspace();///World space
                    }

                    Vec2f pos = details.pos;

                    if(pos != details.old_pos)//If we can interpolate
                    {
                        pos = Vec2f_lerp(details.old_pos, pos, i_hub.FRAME_TIME);//Interpolate
                    }
                    details.image.Render(pos, details.frame);//Render it.
                }
                else//Neither.
                {
                    Nu::Error("No function or image found when rendering.");
                }
            }
        }

        Render::SetTransformWorldspace();//Have to do this or kag gets cranky as it doesn't do it itself.
    }
}



bool HubInit()
{
    if(o_hub == @null)//If we don't have o_hub
    {
        if(!InitHub(getRules(), @o_hub)) { return false; }//Try and get it
    }
    return true;//We got it if it got here
}

void MenusPostHud(int id)
{
    if(!HubInit()) { return; }

    NuRender::ImageRender(o_hub, Render::layer_posthud);
}

void MenusPreHud(int id)
{
    if(!HubInit()) { return; }
    
    NuRender::ImageRender(o_hub, Render::layer_prehud);
}

void MenusPostWorld(int id)
{
    if(!HubInit()) { return; }
    
    NuRender::ImageRender(o_hub, Render::layer_postworld);
}

void MenusObjects(int id)
{
    if(!HubInit()) { return; }
    
    NuRender::ImageRender(o_hub, Render::layer_objects);
}

void MenusTiles(int id)
{
    if(!HubInit()) { return; }
    
    NuRender::ImageRender(o_hub, Render::layer_tiles);
}

void MenusBackground(int id)
{
    if(!HubInit()) { return; }
    
    NuRender::ImageRender(o_hub, Render::layer_background);
}