#include "NuMenuCommon.as";
#include "NuTextCommon.as";

class NuHub
{
    NuHub()
    {
        SetupArrays();
        
        SetupGlobalVars();
    }
    
    void SetupArrays()
    {
        menus = array<NuMenu::IMenu@>();
        buttons = array<NuMenu::MenuButton@>();
        fonts = array<NuFont@>();
    }


    int posthudid;
    int prehudid;
    int postworldid;
    int objectsid;
    int tilesid;
    int backgroundid;
    void SetupRendering()
    {

        posthudid = Render::addScript(Render::layer_posthud, "NuMenuCommon.as", "MenusPostHud", 0.0f);
        prehudid = Render::addScript(Render::layer_prehud, "NuMenuCommon.as", "MenusPreHud", 0.0f);
        postworldid = Render::addScript(Render::layer_postworld, "NuMenuCommon.as", "MenusPostWorld", 0.0f);
        objectsid = Render::addScript(Render::layer_objects, "NuMenuCommon.as", "MenusObjects", 0.0f);
        tilesid = Render::addScript(Render::layer_tiles, "NuMenuCommon.as", "MenusTiles", 0.0f);
        backgroundid = Render::addScript(Render::layer_background, "NuMenuCommon.as", "MenusBackground", 0.0f);
    }


    f32 FRAME_TIME; // last frame time
    float MARGIN;//How many pixels away will things stop drawing from outside the screen.
    void SetupGlobalVars()
    {
        FRAME_TIME = 0.0f;
        MARGIN = 255.0f;
    }

    //
    //Fonts
    //

        
    private array<NuFont@> fonts;
    array<NuFont@> getFonts()
    {
        return fonts;
    }
    
    void addFont(NuFont@ _font)
    {
        if(_font == @null){ error("addFont(NuFont@): attempted to add null font."); return;}
        
        if(getFont(_font.basefont.name) != @null) { warning("addFont(NuFont@): Font attempted to add already existed."); return; }
        
        fonts.push_back(@_font);
    }
    void addFont(string font_name, string font_file, bool has_alpha = true)
    {
        if(getFont(font_name) != @null) { warning("addFont(string): Font attempted to add already existed."); return; }

        NuFont@ font = NuFont(font_name, font_file, has_alpha);

        if(font == @null)
        {
            Nu::Error("Font was still null after creation. Somehow.");
        }

        fonts.push_back(@font);
    }
    
    NuFont@ getFont(string font_name)
    {
        for(u16 i = 0; i < fonts.size(); i++)
        {
            if(fonts[i].basefont.name == font_name)
            {
                return @fonts[i];
            }
        }
        return @null;
    }

    bool FontExists(string font_name)
    {
        if(getFont(font_name) != @null)
        {
            return true;
        }

        return false;
    }

    
    //getFont()//

    //
    //Fonts
    //






    bool addMenuToList(NuMenu::IMenu@ _menu)
    {
        if(_menu == @null) { Nu::Error("Menu to be added was null"); return false; }
        menus.push_back(_menu);
        buttons.push_back(@null);
        
        //NuMenu::MenuButton@ button = cast<NuMenu::MenuButton@>(_menu);
        //if(button != @null) { print("WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWaWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"); }
        //buttons.push_back(button);

        return true;
    }

    bool addMenuToList(NuMenu::MenuButton@ _menu)
    {
        if(_menu == @null) { Nu::Error("Menu to be added was null"); return false; }

        menus.push_back(_menu);
        buttons.push_back(_menu);

        return true;
    }

    bool removeMenuFromList(u16 i)
    {
        if(i >= menus.size())
        {
            error("Tried to remove menu equal to or above the menu size."); return false;
        }

        menus.removeAt(i);
        buttons.removeAt(i);

        return true;
    }
    
    bool removeMenuFromList(string _name)
    {
        int _namehash = _name.getHash();
        for(u16 i = 0; i < menus.size(); i++)
        {
            if(menus[i].getNameHash() == _namehash)
            {
                menus.removeAt(i);
                buttons.removeAt(i);
                i--;
            }
        }

        return true;
    }


    //Returns an array of all the positions of menus with _name in the menu array. 
    array<u16> getMenuPositions(string _name)
    {   
        array<u16> _menu_positions();
        
        int _namehash = _name.getHash();
        for(u16 i = 0; i < menus.size(); i++)
        {
            if(menus[i].getNameHash() == _namehash)
            {
                _menu_positions.push_back(i);
            }
        }

        return _menu_positions;
    }

    u16 getMenuListSize()
    {
        return menus.size();
    }

    //False being returned means the code tried to get past the max menu size.
    bool getMenuFromList(u16 i, NuMenu::IMenu@ &out imenu)
    {
        if(i >= menus.size()) { error("Tried to get menu equal to or above the menu size."); @imenu = @null; return false; }

        @imenu = @menus[i];

        return true;
    }

    //Get the first IMenu from the menus array with _name.
    //False being returned means no menus were found.
    bool getMenuFromList(string _name, NuMenu::IMenu@ &out imenu)
    {
        array<u16> _menus();
        _menus = getMenuPositions(_name);
        if(_menus.size() > 0)
        {
            @imenu = @menus[_menus[0]];
            return true;
        }
        else
        {
            return false;
        }
    }

    void ClearMenuList()
    {
        menus.clear();
        buttons.clear();
    }

    //Return IMenu at the position.
    NuMenu::IMenu@ get_opIndex(int idx) const
    {
        if(idx >= menus.size()) { error("Tried to get menu out of bounds."); return @null; }
        return @menus[idx];
    }
    

    array<NuMenu::IMenu@> menus;

    array<NuMenu::MenuButton@> buttons;//Since casting is very broken, this is a way to sidestep the issue.
}
//Don't let more of one of this exist at once.