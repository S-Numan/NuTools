//This file handles misc rendering.

#include "NuLib.as";
#include "NuRend.as";

namespace NuRender
{
    bool init = false;//Has initialized yet?
    NuRend@ i_rend = @null;//Inner rend

    void onInit(CRules@ rules, NuRend@ _rend)
    {
        if(!isClient())
        {
            return;
        }
        
        @i_rend = @_rend;

        init = true;//Initialized
    }

    void onTick(CRules@ rules)
    {
        if(!isClient())
        {
            return;
        }

        if(i_rend == @null)
        {
            error("rend was null"); return;
        }

        i_rend.FRAME_TIME = 0.0f;

        i_rend.RenderClear();
    }

    void onRender(CRules@ rules)
    {
        i_rend.FRAME_TIME += getRenderDeltaTime() * getTicksASecond();
    }

    void ImageRender(NuRend@ rend, Render::ScriptLayer layer)
    {
        u16 i;

        Render::SetAlphaBlend(true);
        
        u16 image_count = rend.RenderDetailFilledOn(layer);

        array<RenderDetails@> detail_screen = array<RenderDetails@>(image_count);
        array<RenderDetails@> detail_world = array<RenderDetails@>(image_count);
        u16 detail_screen_count = 0;
        u16 detail_world_count = 0;

        for(i = 0; i < image_count; i++)
        {
            RenderDetails@ details = @rend.RenderDetailAt(layer, i);
            if(details == @null)
            {
                error("Image was somehow null in rendering. This should not happen."); continue;
            }

            if(details.getFunc() != @null || details.image != @null)//Has a function or image?
            {
                if(!details.world_pos)//Not world pos?
                {
                    @detail_screen[detail_screen_count] = @details;

                    detail_screen_count++;
                }
                else//World pos
                {
                    @detail_world[detail_world_count] = @details;

                    detail_world_count++;
                }
            }
            else//No function?
            {
                Nu::Error("No function or image found when rendering.");
            }
        }
        
        Render::SetTransformScreenspace();//Screen space
        for(i = 0; i < detail_screen_count; i++)
        {
            RENDER_CALLBACK@ func = detail_screen[i].getFunc();
            if(func != @null)//Has a function?
            {
                func();//Call it.
            }
            else//No function?
            {
                Vec2f pos = detail_screen[i].pos;

                if(detail_screen[i].interpolate && pos != detail_screen[i].old_pos)//If we can interpolate
                {
                    pos = Vec2f_lerp(detail_screen[i].old_pos, pos, i_rend.FRAME_TIME);//Interpolate
                }
                detail_screen[i].image.Render(pos);//Render it.
            }
        }

        Render::SetTransformWorldspace();//World space
        for(i = 0; i < detail_world_count; i++)
        {
            RENDER_CALLBACK@ func = detail_world[i].getFunc();
            if(func != @null)//Has a function?
            {
                func();//Call it.
            }
            else//No function?
            {
                Vec2f pos = detail_world[i].pos;

                if(detail_world[i].interpolate && pos != detail_world[i].old_pos)//If we can interpolate
                {
                    pos = Vec2f_lerp(detail_world[i].old_pos, pos, i_rend.FRAME_TIME);//Interpolate
                }
                detail_world[i].image.Render(pos);//Render it.
            }
        }


        Render::SetTransformWorldspace();//Have to do this or kag gets cranky as it doesn't do it itself.
    }
}