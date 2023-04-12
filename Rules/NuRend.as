//This file contains a class called NuRend, which has the purpose of TODO

#include "NuLibCore.as";
#include "NuLibRendering.as";


funcdef bool RENDER_CALLBACK();

shared class RenderDetails
{
    RenderDetails(RENDER_CALLBACK@ _func, bool _world_pos)
    {
        @func = @_func;   

        @image = @null;

        pos = Vec2f(0,0);
        old_pos = pos;
        
        world_pos = _world_pos;
        
        interpolate = true;
    }

    RenderDetails(Nu::NuImage@ _image, Vec2f _pos, bool _world_pos = false, bool _interpolate = true, Vec2f _old_pos = Vec2f(-1.0f, -1.0f))
    {
        @func = @null;

        @image = @_image;
        pos = _pos;
        
        if(_old_pos == Vec2f(-1.0f, -1.0f))//Old pos not set?
        {
            old_pos = _pos;//Set it to _pos
        }
        else//Old pos is set
        {
            old_pos = _old_pos;//Set it
        }
        
        world_pos = _world_pos;
        interpolate = _interpolate;
    }
    private RENDER_CALLBACK@ func;
    RENDER_CALLBACK@ getFunc()
    {
        return @func;
    }

    Nu::NuImage@ image;
    /*u16 getFrame()
    {
        return image.getFrame();
    }
    void setFrame(u16 _frame)
    {
        image.setFrame(_frame);
    }*///This truly needed?
    
    Vec2f old_pos;
    Vec2f pos;
    bool world_pos;
    bool interpolate;
}

shared bool getRend(NuRend@ &out _rend, bool print_error = true)
{
    if(!getRules().get("NuRend", @_rend))
    {
        if(print_error) { Nu::Error("Failed to get NuRend. Make sure NuToolsLogic.as is before anything in gamemode.cfg else that tries to use it. If it isn't in gamemode.cfg, add it there."); }
        return false;
    }
    return true;
}

shared void RenderImage(Render::ScriptLayer layer, RENDER_CALLBACK@ _func, bool is_world_pos)
{
    if(!isClient()) { Nu::Error("This should not be run serverside"); return; }

    NuRend@ rend;
    if(!getRend(@rend)) { return; }
    rend.RenderImage(layer, _func, is_world_pos);
}
shared void RenderImage(Render::ScriptLayer layer, Nu::NuImage@ _image, Vec2f _pos, bool is_world_pos = false, bool _interpolate = true)
{
    if(!isClient()) { Nu::Error("This should not be run serverside"); return; }

    NuRend@ rend;
    if(!getRend(@rend)) { return; }
    rend.RenderImage(layer, _image, _pos, is_world_pos, _interpolate);
}

shared void RenderTestImage(Vec2f _pos, bool is_world_pos = false)
{
    if(!isClient()) { Nu::Error("This should not be run serverside"); return; }
    
    NuRend@ rend;
    if(!getRend(@rend)) { return; }
    
    Nu::NuImage@ test_image = @Nu::NuImage();
    test_image.CreateImage("RenderExample.png");
    test_image.setColor(SColor(255, 255, 0, 0));
    //test_image.setScale(0.5f);

    rend.RenderImage(Render::layer_posthud, test_image, _pos, is_world_pos, false);
}

shared class NuRend
{
    NuRend()
    {
        SetupArrays();
        
        SetupGlobalVars();
    }
    
    void SetupArrays()
    {
        render_filled_spots = array<u16>(Render::layer_count, 0);
        render_details = array<array<RenderDetails@>>(Render::layer_count);

        for(u16 i = 0; i < render_details.size(); i++)
        {
            render_details[i] = array<RenderDetails@>();
        }
    }


    //
    //Rendering
    //
    s32 posthudid;
    s32 prehudid;
    s32 postworldid;
    s32 objectsid;
    s32 tilesid;
    s32 backgroundid;
    void SetupRendering()
    {
        if(!isClient()) { Nu::Error("This should not be run serverside"); return; }
        
        posthudid = Nu::s32_max();
        prehudid = Nu::s32_max();
        postworldid = Nu::s32_max();
        objectsid = Nu::s32_max();
        tilesid = Nu::s32_max();
        backgroundid = Nu::s32_max();
    }


    f32 FRAME_TIME; // last frame time
    float MARGIN;//How many pixels away will things stop drawing from outside the screen.
    Random@ rnd;
    void SetupGlobalVars()
    {
        FRAME_TIME = 0.0f;
        MARGIN = 255.0f;

        @rnd = @Random(getGameTime() * 404 + 1337 - Time_Local());
    }


    private array<u16> render_filled_spots;
    private array<array<RenderDetails@>> render_details;
    u16 RenderDetailFilledOn(Render::ScriptLayer layer)
    {
        if(!isClient()) { Nu::Error("This should not be run serverside"); return 0; }

        if(layer > render_filled_spots.size()) { Nu::Error("Layer beyond max layer"); return 0; }
        return render_filled_spots[layer];
    }
    RenderDetails@ RenderDetailAt(Render::ScriptLayer layer, u16 _pos)
    {
        if(!isClient()) { Nu::Error("This should not be run serverside"); return @null; }

        if(layer > render_details.size()) { Nu::Error("Layer beyond max layer"); return @null; }
        if(_pos >= render_filled_spots[layer]){ Nu::Error("Tried to get past render detail count in the render_details array. Attempted to get position " + _pos); }
        return @render_details[layer][_pos];
    }


    void RenderImage(Render::ScriptLayer layer, RENDER_CALLBACK@ _func, bool is_world_pos)
    {
        if(!isClient()) { Nu::Error("This should not be run serverside"); return; }

        if(layer > render_details.size()) { Nu::Error("Layer beyond max layer"); return; }

        if(render_details[layer].size() == render_filled_spots[layer])//render_details not large enough?
        {
            render_details[layer].push_back(@RenderDetails(_func, is_world_pos));//Make more space and put it in
        }
        else//Render details is large enough?
        {
            @render_details[layer][render_filled_spots[layer]] = @RenderDetails(_func, is_world_pos);//Put it in at the next open space
        }

        render_filled_spots[layer]++;
    }
    void RenderImage(Render::ScriptLayer layer, Nu::NuImage@ _image, Vec2f _pos, bool is_world_pos = false, bool _interpolate = true)
    {
        if(!isClient()) { Nu::Error("This should not be run serverside"); return; }

        if(layer > render_details.size()) { Nu::Error("Layer beyond max layer"); return; }

        _image.Tick();

        if(render_details[layer].size() == render_filled_spots[layer])//render_details not large enough?
        {
            render_details[layer].push_back(@RenderDetails(_image, _pos, is_world_pos, _interpolate));//Make more space and put it in
        }
        else//Render details is large enough?
        {
            @render_details[layer][render_filled_spots[layer]] = @RenderDetails(_image, _pos, is_world_pos, _interpolate);//Put it in at the next open space
        }        
    
        render_filled_spots[layer]++;
    }
    void RenderClear()
    {
        if(!isClient()) { Nu::Error("This should not be run serverside"); return; }

        for(u8 i = 0; i < render_details.size(); i++)
        {
            if(render_filled_spots.size() > 0)
            {
                //Create render script on layer. (this is here to only add a render script if something is being rendered. If it's there and nothing is using it, it's a performance drain.)
                switch(i)
                {
                    case Render::layer_posthud:
                        if(posthudid == Nu::s32_max())
                        {
                            posthudid = Render::addScript(Render::layer_posthud, "NuToolsLogic.as", "MenusPostHud", 0.0f);
                        }
                    break;
                    case Render::layer_prehud:
                        if(prehudid == Nu::s32_max())
                        {
                            prehudid = Render::addScript(Render::layer_prehud, "NuToolsLogic.as", "MenusPreHud", 0.0f);
                        }
                    break;
                    case Render::layer_postworld:
                        if(postworldid == Nu::s32_max())
                        {
                            postworldid = Render::addScript(Render::layer_postworld, "NuToolsLogic.as", "MenusPostWorld", 0.0f);
                        }
                    break;
                    case Render::layer_objects:
                        if(objectsid == Nu::s32_max())
                        {
                            objectsid = Render::addScript(Render::layer_objects, "NuToolsLogic.as", "MenusObjects", 0.0f);
                        }
                    break;
                    case Render::layer_tiles:
                        if(tilesid == Nu::s32_max())
                        {
                            tilesid = Render::addScript(Render::layer_tiles, "NuToolsLogic.as", "MenusTiles", 0.0f);
                        }
                    break;
                    case Render::layer_background:            
                        if(backgroundid == Nu::s32_max())
                        {
                            backgroundid = Render::addScript(Render::layer_background, "NuToolsLogic.as", "MenusBackground", 0.0f);
                        }
                    break;
                }

                render_filled_spots[i] = 0;
                for(u16 q = 0; q < render_details[i].size(); q++)
                {
                    @render_details[i][q] = @null;
                }
            }
        }
    }

    //
    //Rendering
    //
}
//Don't let more of one of this exist at once.