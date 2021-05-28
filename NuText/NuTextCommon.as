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


#include "NumanLib.as";
#include "NuHub.as";


class NuFont
{
    NuFont(string font_name, string font_path, bool _alpha = true)
    {
        print("");//KAG will instantly crash if I don't print this.
        
        CHARACTER_SPACE = 32;

        has_alpha = _alpha;

        Setup(font_name, font_path);
    }

    u32 CHARACTER_SPACE;

    private bool has_alpha;
    bool hasAlpha()
    {
        return has_alpha;
    }
    
    void Setup(string font_name, string font_path)
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
        

        if(_image_size < 3)//To prevent problems when setting start/end/null colors.
        {
            error("Image provided to NuFont was too small.");
            return;
        }

        SColor start_color = basefontdata[0];//Get the start color.
        SColor end_color = basefontdata[1];//Get the end color.
        SColor null_color = basefontdata[2];//Get null color. (usually black)

        basefontdata[1] = null_color;//Remove this one.


        u32 i;

        //Check if the file has an equal amount of starts and ends.
        u32 start_count = 0;
        u32 end_count = 0;
        for(i = 0; i < _image_size; i++)
        {
            if(basefontdata[i] == start_color)
            {
                start_count++;
            }   
            if(basefontdata[i] == end_color)
            {
                end_count++;
            }
        }
        if(start_count != end_count)
        {
            error("start count is not equal to end count, is this font file corrupted?");
        }
        if(start_count == 0)
        {
            error("no characters in this font file?");
        }

        array<array<Vec2f>> uv_per_frame(start_count + CHARACTER_SPACE + 1);//Create the array that points to where every frame is. The amount of characters(start_count) + the starting character, + 1.
        for(i = 0; i < 32; i++)//Set each value from 0 through 31 to Vec2f 0,0 to prevent issues.
        {
            uv_per_frame[i] = array<Vec2f>(4, Vec2f(0,0));
        }


        character_sizes = array<Vec2f>(start_count + CHARACTER_SPACE + 1, Vec2f(0,0));


        //
        u32 character_count = CHARACTER_SPACE;

        u32 q;

        u32 last_end_pos = 0;
        for(i = 0; i < _image_size; i++)//Find start point
        {
            //Look for start positions.
            if(basefontdata[i] == start_color)//Is this the start position.
            {
                //This is the start position.
                for(q = last_end_pos; q < _image_size; q++)//Look for start positions AFTER the last end position.
                {
                    if(basefontdata[q] == end_color)//Found the end point
                    {
                        Vec2f _frame_start = Vec2f(i % _image_size_vec.x, i / int(_image_size_vec.x));

                        Vec2f _frame_end = Vec2f(q % _image_size_vec.x, q / int(_image_size_vec.x));

                        character_sizes[character_count] = _frame_end - _frame_start;

                        uv_per_frame[character_count] = Nu::getUVFrame(basefont.getImageSize(), _frame_start, _frame_end);
                        
                        character_count++;
                        
                        last_end_pos = q + 1;
                        
                        break;
                    }
                    
                }
            }
        }

        if(character_count - CHARACTER_SPACE != start_count)//If the character count and the start count are different.
        {
            Nu::Error("Something went wrong.\ncharacter_count = " + character_count + "\nstart_count = " + start_count + "\nend_count = " + end_count + "\nimage_size = " + _image_size + "\nlast_end_pos = " + last_end_pos);
        }


        for(i = 0; i < _image_size; i++)
        {
            if(basefontdata[i] == null_color || basefontdata[i] == start_color || basefontdata[i] == end_color)//If the color is one of 3 main colors.
            {
                basefontdata[i] = SColor(0, 0, 0, 0);//Wipe it.
            }
            else if(basefontdata[i].getRed() != 255 || basefontdata[i].getGreen() != 255 || basefontdata[i].getBlue() != 255)//If the color of a pixel is not completely white
            {
                u8 red = basefontdata[i].getRed();
                u8 green = basefontdata[i].getGreen();
                u8 blue = basefontdata[i].getBlue();

                u16 total_color = red + green + blue;

                float total = total_color / 3.0f;

                if(has_alpha)
                {
                    basefontdata[i] = SColor(total, 255, 255, 255);                    
                }
                else
                {
                    total = Maths::Lerp(total, 255, 0.75);
                    basefontdata[i] = SColor(255, total, total, total);
                }
            }
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
}


//TODO, move things that can only be done from the basefont in NuFont to NuText.
//Kerning. (same distance between every character) ((get max character width and height in NuFont for this? or just use space? I dunno))
class NuText
{
    NuText()
    {
        Setup();
        setFont("Arial");
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
        if(!getRules().get("NuHub", @hub)) { error("Failed to get NuHub. Make sure NuHubLogic is before anything else that tries to use it."); return; }
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

        font.basefont.setDefaultColor(text_color);//Set the color.

        for(u16 i = 0; i < render_string.size(); i++)//For every character in this string.
        {
            font.basefont.setFrameSize(font.character_sizes[render_string[i]], false);//Set the frame size of the character in the texture.

            font.basefont.setDefaultPoints();//Set the points for how large this character is rendered.

            font.basefont.Render(_pos + char_positions[i],//At the _pos plus the character position.
                render_string[i]//With this frame. (character)
            );
        }
    }

    private string render_string;
    void setString(string value, Vec2f _scale = Vec2f(0,0))
    {
        render_string = value;

        if(_scale != Vec2f(0,0))//Default parameter set?
        {
            scale = _scale;//Set the scale
        }

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

    array<Vec2f> string_sizes;//Sizes for each character in the drawn string.
    
    Vec2f string_size_total;//Size for the entire drawn string.

    array<Vec2f> char_positions;//What position each character should be in to not overlap.

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

        float next_line_distance = font.character_sizes[font.CHARACTER_SPACE].y * scale.y;

        for(u16 i = 0; i < render_string.size(); i++)//For every character
        {
            u16 char_num = render_string[i];//Get the number associated with this character.

            string_sizes[i] = Nu::MultVec(font.character_sizes[char_num], scale);//Set the size of this character in the string, multiplied by the scale.


            Vec2f char_pos;//Position this character adds.

            char_pos = Align(char_pos, i);

            char_pos = NextLine(char_pos, i, next_line_distance);

            char_pos = CapWidth(char_pos, i, i, next_line_distance);

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

    private Vec2f Align(Vec2f char_pos, u16 i)
    {
        if(i > 0)//Past the first character
        {
            char_pos = char_positions[i - 1];//Take the previous position.
            char_pos.x += string_sizes[i - 1].x;//Add the new position to it
        }
        else//First character.
        {
            char_pos = Vec2f(0,0);
        }

        return char_pos;
    }

    private Vec2f NextLine(Vec2f char_pos, u16 i, float next_line_distance)
    {
        if(i < render_string.size() - 1//Provided there is one space forward.
            && render_string[i] == "\n"[0])//And this a next line character.
        {
            char_pos.y += next_line_distance;//Next line.
            char_pos.x = 0.0f;//Next line.
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

    private Vec2f CapWidth(Vec2f char_pos, u16 i, u16 &out out_i, float next_line_distance)
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
        }
        
        out_i = i;
        
        return char_pos;
    }

    //
    //Positions and scales
    //
}