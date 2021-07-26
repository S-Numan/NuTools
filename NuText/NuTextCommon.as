//How to create fonts for this mod.
//Go to ../Base/GUI/Fonts
//Open IrrFontTool.exe
//I reccomend going to the Top left and changing 256 pixels wide to 1024 pixels wide pixels. 
//After that, I also reccomend setting the font size to 48. Neither of these are required though.
//Pick the font you want in the middle.
//Click the square button on the left that says "create bitmap font and copy to clipboard"
//Paste in image program, crop if needed.
//Save inside a mod, and you are done. See NuTextExample.as for how to add the png as a font into kag.




//TODO
//Color per character.
//Better angles.
//Remove first 32 values of each array and handle it manually for performace and stuff,
//Get everything to work via NuStateImage


#include "NuLib.as";
#include "NuHub.as";


class NuFont
{
    NuFont(string font_name, string font_path, string font_positions_path)
    {
        print("");//KAG will instantly crash if I don't print this.
        
        CHARACTER_SPACE = 32;

        Setup(font_name, font_path, font_positions_path);
    }

    u32 CHARACTER_SPACE;

    //What each parameter means
    //1: Name for when you call the font. Interact with it, set it, remove it, etc.
    //2: File path for the font png
    //3: File path for the details of where each letter are and extra stuff.

    void Setup(string font_name, string font_path, string font_positions_path)
    {
        print("");//KAG will instantly crash if I don't print this.

        if(Texture::exists(font_name))
        {
            Texture::destroy(font_name);
        }


        @basefont = @Nu::NuImage();
        ImageData@ basefontdata = @basefont.CreateImage(font_name, font_path);
        
        basefont.auto_frame_points = false;

        basefont.setZ(2.0f);

        u32 _image_size = basefontdata.width() * basefontdata.height();
        Vec2f _image_size_vec = Vec2f(basefontdata.width(), basefontdata.height());
        

        if(_image_size < 3)
        {
            Nu::Error("Image provided to NuFont was too small."); return;
        }


        u32 i;
        
        ConfigFile@ cfg = ConfigFile();
        if (!cfg.loadFile(font_positions_path))//Load the file, and if it doesn't exist.
        {
            Nu::Error("Failed to load parameter font_positions_path"); return;
        }

        if(!cfg.exists("size")) { Nu::Error("size in cfg was not found. Was the cfg properly made?"); return; }
        default_character_size = Nu::f32ToVec2f(cfg.read_f32("size"));

        u32 character_count = 0;

        while(true)//Keep going until told to stop
        {
            string key_name = "kc" + (character_count + CHARACTER_SPACE) + "_advance";//Name of the key we are looking for
            if(!cfg.exists(key_name)){ break; }//Stop if the advance does not exist

            f32 _advance = cfg.read_f32(key_name);//It exists, so get it.

            character_count++;//Extra character found.
        }

        if(character_count == 0)
        {
            Nu::Error("No characters found in the font_positions_path file. Is it setup wrong?"); return;
        }

        array<array<Vec2f>> uv_per_frame(character_count + CHARACTER_SPACE);//Create the array that points to where every frame is. The amount of characters(character_count) + the starting character.
        for(i = 0; i < CHARACTER_SPACE; i++)//Set each value from 0 to CHARACTER_SPACE to Vec2f 0,0 to prevent issues.
        {
            uv_per_frame[i] = array<Vec2f>(4, Vec2f(0,0));
        }


        character_sizes = array<Vec2f>(uv_per_frame.size(), Vec2f(0,0));

        uv_per_frame[CHARACTER_SPACE] = array<Vec2f>(4, Vec2f(0,0));
        character_sizes[CHARACTER_SPACE] = default_character_size * 0.25f;

        for(i = CHARACTER_SPACE + 1; i < uv_per_frame.size(); i++)//Per character, starting one after space.
        {
            Vec2f _TopLeft;//Temp character on image top left,
            Vec2f _BottomRight;//Temp character on image bottom right.

            string key_name = "kc" + i + "_";//First part of the name of the key we're looking for

            //Get the bounds
            if(!cfg.exists(key_name + "bound_top") || !cfg.exists(key_name + "bound_left") || !cfg.exists(key_name + "bound_bottom") || !cfg.exists(key_name + "bound_right"))//If a bound does not exist
            {
                Nu::Error("A bound did not exist on key_name " + key_name); return;//Caesars cheesecake factory is pretty good.
            }
                
            _TopLeft = Vec2f(Maths::Floor(cfg.read_f32(key_name + "bound_left")), Maths::Floor(cfg.read_f32(key_name + "bound_top")));//Get the topleft
            _BottomRight = Vec2f(Maths::Floor(cfg.read_f32(key_name + "bound_right")), Maths::Floor(cfg.read_f32(key_name + "bound_bottom")));//Get the bottomright


            //Set uv for each frame
            uv_per_frame[i] = Nu::getUVFrame(basefont.getImageSize(), _TopLeft, _BottomRight);

            //Set character size for each frame
            character_sizes[i] = _BottomRight - _TopLeft;

            if(character_sizes[i].x > max_character_size.x)//If the size of this character's x size is larger than the max character's x size
            {
                max_character_size.x = character_sizes[i].x;//Set this as the max character size x size
            }
            if(character_sizes[i].y > max_character_size.y)//If the size of this character's y size is larger than the max character's y size
            {
                max_character_size.y = character_sizes[i].y;//Set this as the max character's y size
            }
        }


        SColor bgColor = SColor(0, 255, 255, 255);
        SColor fgColor = SColor(255, 255, 255, 255);
        //Setup the image
        for(i = 0; i < _image_size; i++)//For every character in this image.
        {
            SColor msd = basefontdata[i];
            float sd = Nu::Median(msd.getRed(), msd.getGreen(), msd.getBlue());

            float sd_one = sd / 255.0f;

            float opacity = Maths::Clamp(sd_one, 0.0, 1.0);
            
            msd = Nu::Mix(bgColor, fgColor, opacity);
            //msd.setAlpha(sd);
            basefontdata[i] = msd;

            /*SColor msd = basefontdata[i];
            float sd = Nu::Median(msd.getRed(), msd.getGreen(), msd.getBlue());
            if(sd <= 255.0f / 2.0f)
            {
                basefontdata[i].setAlpha(0);
            }*/
        
        }

        if(!Texture::update(font_name, basefontdata)){ error("WAT?"); return;}//Update the texture without that.

        basefont.uv_per_frame = uv_per_frame;
    }


    array<Vec2f> get_opIndex(int idx)
    {
        if(idx >= basefont.uv_per_frame.size())
        {
            error("Tried to get a character past the max character amount");
        }
        if(idx < CHARACTER_SPACE)
        {
            error("Tried to get a character below space. No characters are below space.");
        }

        return basefont.uv_per_frame[idx];
    }


    Nu::NuImage@ basefont;

    array<Vec2f> character_sizes;//Sizes for every character in the character png.

    Vec2f default_character_size;
    Vec2f max_character_size;
}


//TODO, move things that can only be done from the basefont in NuFont to NuText.
//Kerning. (same distance between every character) ((get max character width and height in NuFont for this? or just use space? I dunno))
class NuText
{
    NuText()
    {
        Setup();
        setFont("Lato-Regular");
        setString("");
    }
    NuText(string font_name, string text = ""
    , string texty = "")//This default parameter must be included or kag instantly crashes. Just ignore it.
    {
        Setup();
        setFont(font_name);
        setString(text);
    }
    
    void Setup()
    {
        //is_world_pos = false;

        scale = Vec2f(1,1);

        width_cap = 99999.0f;

        angle = 0.0f;

        text_color = SColor(255, 255, 255, 255);

        min_distance = Vec2f(0.0f, 0.0f);

        max_distance = Vec2f(99999.0f, 99999.0f);

        default_char_offset = Vec2f(0.0f, 0.0f);
    }

    //
    //Font
    //

    private NuFont@ font;
    void setFont(NuFont@ _font)
    {
        if(_font == @null){ Nu::Error("setFont(NuFont@): Font was null."); return; }
        @font = @_font;

        refreshSizesAndPositions();
    }
    void setFont(string font_name)
    {
        NuHub@ hub;
        if(!getHub(@hub)) { return; }
        NuFont@ _font = hub.getFont(font_name);
        if(_font == @null){ Nu::StackAndMessage("Font not found. Try creating a font with the name \"" + font_name + "\" via the hub with addFont(string font_name);"); return; }

        setFont(_font);
    }
    NuFont@ getFont()
    {
        return @font;
    }

    //
    //Font
    //

    //
    //Settings
    //

    /*private bool is_world_pos;
    bool isWorldPos()
    {
        return is_world_pos;
    }
    void setIsWorldPos(bool value)
    {
        is_world_pos = value;
    }*/

    SColor text_color;
    SColor getColor()
    {
        if(font == @null) { Nu::Error("Font was null."); return SColor(255, 255, 255, 0); }
        
        return text_color;
    }
    void setColor(SColor value)
    {
        if(font == @null) { Nu::Error("Font was null."); return; }
        
        text_color = value;
    }

    float angle;

    float getAngle()
    {
        if(font == @null) { Nu::Error("Font was null."); return 0.0f; }

        return angle;
    }
    void setAngle(float value)
    {
        if(font == @null) { Nu::Error("Font was null."); return; }

        angle = value;
        refreshSizesAndPositions();
    }

    //
    //Settings
    //

    //
    //Rendering
    //


    void Render(Vec2f _pos = Vec2f(0,0), u16 state = 0)
    {
        if(font.basefont.would_crash) { return; }
        
        /*if(!isWorldPos())
        {
            Render::SetTransformScreenspace();
        }
        else//World pos
        {
            Render::SetTransformWorldspace();
        }*/

        //if(state >= font.basefont.frame_on.size() || state >= font.basefont.color_on.size())
        //{
        //    Nu::Error("Input state above state size."); font.basefont.would_crash = true; return;
        //}
        
        font.basefont.setScale(scale);//Set the scale.

        font.basefont.setAngle(angle);//Set the angle. For those weird people.

        font.basefont.setColor(text_color);//Set the color.

        for(u16 i = 0; i < render_string.size(); i++)//For every character in this string.
        {
            font.basefont.setFrameSize(font.character_sizes[render_string[i]], false);//Set the frame size of the character in the texture, and DO NOT recalculate the uv that was so hard worked for.

            font.basefont.setDefaultPoints();//Set the points for how large this character is rendered.

            font.basefont.setFrame(render_string[i]);//With this frame. (character)

            font.basefont.Render(_pos + char_positions[i]);//Render at the _pos plus the character position.
        }
    }

    private string render_string;
    void setString(string value)
    {
        for(u16 i = 0; i < value.size(); i++)//For each character
        {
            if(value[i] >= font.character_sizes.size())//If the character desired goes beyond the max character of the font.
            {
                Nu::Error("Tried to access character beyond the scope of the font. character " + value[i] + " font max character " + font.character_sizes.size()); return;
            }
        }

        render_string = value;

        refreshSizesAndPositions();
    }
    
    string getString()
    {
        return render_string;
    }

    //
    //Rendering
    //

    //
    //Positions and scales
    //

    private Vec2f scale;
    Vec2f getScale()
    {
        return scale;
    }
    void setScale(Vec2f value)
    {
        scale = value;
        refreshSizesAndPositions();
    }
    void setScale(float value)
    {
        setScale(Vec2f(value, value));
    }

    private Vec2f min_distance;//Min distance text can be from each other
    Vec2f getMinDistance()
    {
        return min_distance;
    }
    void setMinDistance(Vec2f value)
    {
        min_distance = value;
        refreshSizesAndPositions();
    }
    void setMinDistance(float value)//Only the x value
    {
        setMinDistance(Vec2f(value, 0.0f));
    }
    
    private Vec2f max_distance;//Max distance text can be from each other
    Vec2f getMaxDistance()
    {
        return max_distance;
    }
    void setMaxDistance(Vec2f value)
    {
        max_distance = value;
        refreshSizesAndPositions();
    }
    void setMaxDistance(float value)//Only the x value
    {
        setMaxDistance(Vec2f(value, 99999.0f));
    }

    private Vec2f default_char_offset;//Adds to how far each character is away from each other. Min and Max distance will still apply.
    Vec2f getCharOffset()
    {
        return default_char_offset;
    }
    void setCharOffset(Vec2f value)
    {
        default_char_offset = value;
        refreshSizesAndPositions();
    }
    void setCharOffset(float value)//Only the x value
    {
        setCharOffset(Vec2f(value, 0.0f));
    }


    array<Vec2f> string_sizes;//Sizes for each character in the drawn string.
    
    Vec2f string_size_total;//Size for the entire drawn string.

    array<Vec2f> char_positions;//What position each character should be in to not overlap.

    u16 next_lines;
    float next_line_distance;

    //Optional cap parameter puts a cap on how far the string can go right. It will halve where a space is, and if not possible it will cut a word in half.//TODO, cap the max x position. 
    
    //Refreshs the size each character is, and where the characters should be positioned.
    void refreshSizesAndPositions()
    {
        if(font == @null)
        {
            Nu::Error("Font is null."); return;
        }
        
        string_sizes = array<Vec2f>(render_string.size());
        string_size_total = Vec2f(0,0);
        char_positions = array<Vec2f>(render_string.size());

        next_line_distance = font.default_character_size.y * scale.y;
        next_lines = 0;

        for(u16 i = 0; i < render_string.size(); i++)//For every character
        {
            u16 char_num = render_string[i];//Get the number associated with this character.

            string_sizes[i] = Nu::MultVec(font.character_sizes[char_num], scale);//Set the size of this character in the string, multiplied by the scale.


            Vec2f char_pos = Vec2f_zero;//Position this character adds.

            char_pos.y = next_line_distance - string_sizes[i].y;//Make the character on lowest point possible rather than being on the highest point possible.

            char_pos = Align(char_pos, i);

            char_pos = NextLine(char_pos, i);

            char_pos = CapWidth(char_pos, i, i);

            char_positions[i] = char_pos;//Add it to this character.

            if(string_size_total.x < char_pos.x)//Set as string_size_total.x if larger
            {
                string_size_total.x = char_pos.x;
            }
            if(string_size_total.y < char_pos.y)//Set as string_size_total.y if larger
            {
                string_size_total.y = char_pos.y;
            }
                
        }
    }

    //Aligns text next to each other. Without this text would be all in the same place.
    private Vec2f Align(Vec2f char_pos, u16 i)
    {
        if(i > 0)//Past the first character
        {
            char_pos.x = char_positions[i - 1].x;//Take the previous x position, and set it

            char_pos += Vec2f(0.0f, next_line_distance * next_lines);//Next line to text to get where it needs to go (not controlled by min/max values)

            Vec2f to_add = Vec2f(0.0f, 0.0f);//Create a Vec2f that will add to char_pos later

            to_add.x = string_sizes[i - 1].x;//Add the size of the previous character to it

            to_add += default_char_offset;//Add the offset.

            if(to_add.x < min_distance.x)//If what's being added is less than min_distance.x
            {
                to_add.x = min_distance.x;//Set to_add.x to min_distance.x.
            }
            else if(to_add.x > max_distance.x)//If what's being added is more than max_distance.x
            {
                to_add.x = max_distance.x;//Set to_add.x to max_distance.x.
            }
            
            if(to_add.y < min_distance.y)//If what's being added is less than min_distance.y
            {
                to_add.y = min_distance.y;//Set to_add.y to min_distance.y.
            }
            else if(to_add.y > max_distance.y)//If what's being added is more than max_distance.y
            {
                to_add.y = max_distance.y;//Set to_add.y to max_distance.y.
            }

            char_pos += to_add;//Add to_add to this character
        }
        else//First character.
        {
            //char_pos = Vec2f(0.0f, next_line_distance - string_sizes[i].y);
        }

        return char_pos;
    }

    //Tells text to render on the next line after a \n is found.
    private Vec2f NextLine(Vec2f char_pos, u16 i)
    {
        if(i < render_string.size() - 1//Provided there is one space forward.
            && render_string[i] == "\n"[0])//And this a next line character.
        {
            char_pos.y += next_line_distance;//Next line.
            char_pos.x = 0.0f;//Next line.
            next_lines++;//Next lined
        }

        return char_pos;
    }

    private float width_cap;
    float getWidthCap()
    {
        return width_cap;
    }
    void setWidthCap(float value)
    {
        width_cap = value;
        refreshSizesAndPositions();
    }

    //Will next line text if the character passes the specified width.
    private Vec2f CapWidth(Vec2f char_pos, u16 i, u16 &out out_i)
    {
        if(char_pos.x > width_cap//If the character position has gone past the width cap.
        && i < render_string.size() - 1)//And there is a next character.
        {
            u16 q;
            //Find the spacebar below this position
            for(q = i; q > 0; q--)//Count down from this position
            {
                if(char_positions[q].y != char_pos.y)//If it has switched a line.
                {
                    q = 0;//Tell q we failed.
                    break;//Failure, stop.
                }
                if(render_string[q] == " "[0])//If this character is equal to space bar.
                {
                    break;//Success, stop. q is now the spacebar character.
                }
            }

            if(q != 0)//Spacebar was found.
            {
                i = q + 1;//i equals one character past the space bar.   
            }
            //else//If a spacebar on the same line was not found.
            
            char_pos.y += next_line_distance;//Next line.
            char_pos.x = 0.0f;//Next line.
            next_lines++;//Next lined.
        }
        
        out_i = i;
        
        return char_pos;
    }

    //
    //Positions and scales
    //
}