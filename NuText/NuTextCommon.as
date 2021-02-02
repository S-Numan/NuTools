//How to create fonts for this mod.
//Go to ../Base/GUI/Fonts
//Open IrrFontTool.exe
//Top left 1024 pixels width.
//On the right, set the font size to 48.\
//Pick the font you want in the middle.
//Click the square button on the right that says "create bitmap font and copy to clipboard"
//Paste in image program, crop if needed.
//Save inside a mod, and you are done. Call that font from wherever elsewhere.

#include "NumanLib.as";
#include "CHub";

u32 CHARACTER_SPACE = 32;
class NuFont
{
    /*NuFont(string font_png)
    {
        Setup(font_png);
        setString("Hello World!");
    }
    
    void Setup(string font_png)
    {
        string_sizes = array<Vec2f>();
        character_sizes = array<Vec2f>();
        string_size_total = Vec2f(0,0);




        @basefont = @Nu::NuImage();
        ImageData@ basefontdata = @basefont.CreateImage(font_png, font_png);
        
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


        if(!Texture::update(font_png, basefontdata)){ error("WAT?"); return;}//Update the texture without that.


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

        character_sizes = array<Vec2f>(start_count + CHARACTER_SPACE + 1);


        //
        u32 character_count = CHARACTER_SPACE;

        u32 q;

        u32 last_end_pos;
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

        if(character_count - CHARACTER_SPACE != start_count)
        {
            error("NuFont: Something went wrong.\ncharacter_count = " + character_count + "\nstart_count = " + start_count + "\nend_count = " + end_count);
        }

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

    array<Vec2f> character_sizes;//Sizes for every character in the character png.*/
}

class NuText
{
    /*NuText()
    {
        font = @null;

        is_world_pos = false;
    }

    bool is_world_pos;
    bool isWorldPos()
    {
        return is_world_pos;
    }
    void setWorldPos(bool value)
    {
        is_world_pos = value;
    }
    private NuFont@ font;
    void setFont(NuFont@ _font)
    {
        font = _font;
    }
    void setFont(string font_name)
    {
        array<NuFont@> fonts 
        getRules().get("font_array", fonts);
    }
    NuFont@ getFont()
    {
        return @font;
    }


    void Render(Vec2f _pos = Vec2f(0,0), u16 state = 0)
    {
        Vec2f character_pos = Vec2f(0,0);
        for(u16 i = 0; i < render_string.size(); i++)
        {
            basefont.setFrameSize(character_sizes[render_string[i]], false);
            
            basefont.setDefaultPoints();

            basefont.Render(render_string[i],
                _pos + character_pos,
                state
            );

            
            character_pos.x += character_sizes[render_string[i]].x;//Store an array of where each character should be rendered. Don't recalculate it every render call. TODO
        }
    }

    array<Vec2f> string_sizes;//Sizes for each character in the drawn string.
    
    Vec2f string_size_total;//Size for the entire drawn string.

    private string render_string;
    void setString(string value)
    {
        render_string = value;
        
        string_sizes = array<Vec2f>(render_string.size());
        string_size_total = Vec2f(0,0);

        for(u16 i = CHARACTER_SPACE; i < render_string.size(); i++)
        {
            string_sizes[i].x = character_sizes[i].x;
            string_sizes[i].y = character_sizes[i].y;
            
            string_size_total.x += string_sizes[i].x;
            string_size_total.y += string_sizes[i].y;
        }
    }
    string getString()
    {
        return render_string;
    }*/
}