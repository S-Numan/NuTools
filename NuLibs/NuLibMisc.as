#include "NuLibCore.as";
#include "NuRend.as";

namespace Nu
{

    //1: Min value for random number
    //2: Max value for random number (- 1)
    //This gives you a random integer between the min and max specified values
    shared s32 getRandomInt(s32 min, s32 max, NuRend@ rend = @null)
    {
        if(rend == @null && !getRend(@rend)) { return 0; }

        if (min == max) { return 0; }

        return rend.rnd.NextRanged(max - min) + min;
    }
    shared s32 getRandomInt(s32 max)
    {
        return getRandomInt(0, max);
    }

    //1: Min value for random number
    //2: Max value for random number
    //3. Optional, get the rend previously if you're calling this a lot for performance reasons
    //This gives you a random float between the min and max specified values
    shared f32 getRandomF32(f32 min, f32 max, NuRend@ rend = @null)
    {
        if(rend == @null && !getRend(@rend)) { return 0; }

        if (min == max) { return 0; }

        //return (rend.rnd.NextRanged(max - min) + min) + rend.rnd.NextFloat();
        return min + rend.rnd.NextFloat() * (max - min);
    }
    shared f32 getRandomF32(f32 max, NuRend@ rend = @null)
    {
        return getRandomF32(0.0f, max, rend);
    }

    shared Vec2f getRandomVec2f(Vec2f min, Vec2f max, NuRend@ rend = @null)
    {
        if(rend == @null && !getRend(@rend)) { return Vec2f(0,0); }

        Vec2f output = Vec2f();

        output.x = getRandomF32(min.x, max.x, rend);
        output.y = getRandomF32(min.y, max.y, rend);

        return output;
    }

    //1: Array of floats to pick between.
    //Returns the chance selected.
    //You give a bar of values to this, and this randomly picks a part of that bar. Bigger values have a larger chance for this to randomly land on it and pick it.
    u32 RandomWeightedPicker(array<float> chances)
    {
        if(chances.size() == 0)
        {
            warning("No chances to pick from");
            return 0;
        }
        
        u32 i;//Init i

        float sum = 0.0f;//Sum of all chances

        //Find the sum of all chances
        for(i = 0; i < chances.size(); i++)
        {
            sum += chances[i];
        }

        float random_number = Nu::getRandomF32(0, sum);//Get our random number between 0 and the sum

        float current_pos = 0.0f;//Current pos in the bar

        for(i = 0; i < chances.size(); i++)//For every chance
        {
            if(current_pos + chances[i] > random_number)
            {
                //We got em
                break;//Exit out with i untouched
            }
            else//Random number has not yet reached the chance
            {
                current_pos += chances[i];//Add to current_pos
            }
        }

        return i;//Return the chance that was got
    }
    //Example code
    /*
        array<string> spawned_items = array<string>(3);
        array<float> chances = array<float>(3);
        chances[0] = 0.4;
        spawned_items[0] = "bomb";
        chances[1] = 0.8;
        spawned_items[1] = "mine";
        chances[2] = 0.1;
        spawned_items[2] = "keg";
        print(spawned_items[Nu::RandomWeightedPicker(chances)]);
    */


    //1: The path to a file.
    //Returns the first parameter without any slashes or the file extension.
    shared string CutOutFileName(string value)
    {
        if(value.size() == 0)
        {
            Nu::Error("The size of the input string was 0");
        }
        //Get the last slash
        int last_slash = value.findLast("/");
        int _last_slash = value.findLast("\\");
        if(_last_slash > last_slash)
        {
            last_slash = _last_slash;
        }

        if(last_slash != -1 && value.size() == last_slash + 1)//Is the last slash on the end of the string? (and it existed)
        {
            warning("CutOutFileName: The last slash was on the end of the string."); return value;
        }
        //Cut out things past the dot.
        int last_dot = value.findLast(".");

        //print("last_slash = " + last_slash + " last_dot = " + last_dot);
        //Cut out the part between these two and return it.
        return value.substr(last_slash + 1,//Special note, if the last_slash was not found it returns -1. Adding 1 to it means there is no need to check if it didn't get it.
            last_dot);//When last_dot isn't found, it also returns -1. This is fine as the size.
    }



    //1: Color 1
    //2: Color 2
    //3: weight between 0 and 1
    //This is effectively a lerp statement for two SColors. It interpolates between the two with their every value and returns the result.
    shared SColor Mix(SColor color1, SColor color2, float value)
    {
        u8 alpha = Maths::Lerp(color1.getAlpha(), color2.getAlpha(), value);
        u8 red = Maths::Lerp(color1.getRed(), color2.getRed(), value);
        u8 green = Maths::Lerp(color1.getGreen(), color2.getGreen(), value);
        u8 blue = Maths::Lerp(color1.getBlue(), color2.getBlue(), value);

        return SColor(alpha, red, green, blue);
    }

    //1: The position of the arrow being spun around the wheel's size. I advise setting this as 0 in init.
    //2: The amount of time spun. I advise adding 1 to this after every call of SpinTheWheel.
    //3: The amount of time it takes to complete spinning the wheel (in ticks). When time_spinning reaches this, you should be done spinning the wheel™
    //4: The starting speed that the arrow is spun around the wheel.
    //5: Optional, the size of the wheel. By default this is 360, as a wheel only has 360 degreees. Not sure why you'd change this, but here you go. 
    //Returns arrow_pos. Input quite a few parameters, and this will spin an arrow around the size of a wheel. (usually 360 degrees)
    shared f32 SpinTheWheel(f32 arrow_pos, f32 time_spinning, u32 ticks_to_complete_spin, f32 starting_spin_speed, f32 wheel_size = 360)
    {
        f32 time_spun = time_spinning / ticks_to_complete_spin;//Get value between 0 and 1 for amount of time this has spun.

        f32 spin_speed = Maths::Lerp(starting_spin_speed, 0, time_spun);//Progressivley slow the spin_speed based on time_spun.

        arrow_pos += spin_speed;//Spin the arrow.
        arrow_pos = arrow_pos % wheel_size;//Loop around from the wheel_size.

        return arrow_pos;
    }

    shared void LoadAMap(string map_name = " ")
    {
        CRules@ rules = getRules();
        
        CBitStream params;
        params.write_string(map_name);

        rules.SendCommand(rules.getCommandID("nunextmap"), params, false);//Send command to only server
    }

    //1. Camera
    //2. Top left pos.
    //3. Optional size.
    //Returns true if is on screen. World pos variant.
    shared bool isOnScreen(CCamera@ cam, Vec2f &in pos, Vec2f &in size = Vec2f_zero)
    {
        const Vec2f campos = cam.getPosition();
        
        const f32 screen_width = getScreenWidth();
        const f32 screen_height = getScreenHeight();

        if(campos.y - screen_height / 4.0 / cam.targetDistance > pos.y + size.y//Top of screen
        || campos.y + screen_height / 4.0 / cam.targetDistance < pos.y//Bottom of screen
        || campos.x - screen_width / 4.0 / cam.targetDistance > pos.x + size.x //Left of screen
        || campos.x + screen_width / 4.0 / cam.targetDistance < pos.x)//Right of screen
        {
            return false;
        }

        return true;
    }
    //1. Top left pos.
    //2. Optional size.
    //Returns true if is on screen, Screen pos variant.
    shared bool isOnScreen(Vec2f &in pos, Vec2f &in size = Vec2f_zero)
    {
        const f32 screen_width = getScreenWidth();
        const f32 screen_height = getScreenHeight();

        if(0.0f > pos.y + size.y//Top of screen
        || screen_height < pos.y//Bottom of screen
        || 0.0f > pos.x + size.x //Left of screen
        || screen_width < pos.x)//Right of screen
        {
            return false;
        }

        return true;
    }

    //Enum list of positions within 2 vec2fs.
    shared enum POSPositions//Stores all positions that stuff can be in.
    {
        POSTopLeft,//top left
        POSTopRight,//top right
        POSBottomLeft,//bottom left
        POSBottomRight,//bottom right
        POSCenter,//in the center of the menu
        POSTop,//positioned on the top of the menu      //TopInside
        POSAbove,//above the top of the menu            //TopOutside
        POSBottom,//on the bottom of the menu           //BottomInside
        POSUnder,//under the bottom of the menu         //BottomOutside
        POSLeft,//on the left of the menu               //LeftInside
        POSLefter,//left of the left side of the menu   //LeftOutside
        POSRight,//to the right of the menu             //RightInside
        POSRighter,//right of the right side of the menu//RightOutside

        POSPositionsCount,//Always last, this specifies the amount of positions.
    }

    //1: Enum position you want the point to be on.
    //2: Size of the thing you want the point to be on. Very important.
    //3: The position you desire.
    //4: Optional buffer. For example if you specify POSBottom and make the buffer 2.0f, it will push the position up by 2.
    //Returns false if the inserted position enum was not found. Insert an enum for a position based on given size. This will then give you that position in the size plus buffer.
    shared bool getPosOnSize(u16 position, Vec2f size, Vec2f &out vec_pos, float buffer = 0.0f)
    {
        switch(position)
        {
            case POSTopLeft:
                vec_pos = Vec2f(0, 0);
                break;
            case POSTopRight:
                vec_pos = Vec2f(size.x, 0);
                break;
            case POSBottomLeft:
                vec_pos = Vec2f(0, size.y);
                break;
            case POSBottomRight:
                vec_pos = Vec2f(size.x, size.y);
                break;
            case POSCenter:
                vec_pos = Vec2f(size.x/2, size.y/2);
                break;
            case POSTop:
                vec_pos = Vec2f(size.x/2, buffer);
                break;
            case POSAbove:
                vec_pos = Vec2f(size.x/2, -buffer); 
                break;
            case POSBottom:
                vec_pos = Vec2f(size.x/2, size.y - buffer);
                break;
            case POSUnder:
                vec_pos = Vec2f(size.x/2, size.y + buffer);
                break;
            case POSLeft:
                vec_pos = Vec2f(buffer, size.y/2);
                break;
            case POSLefter:
                vec_pos = Vec2f(-buffer, size.y/2);
                break;
            case POSRight:
                vec_pos = Vec2f(size.x - buffer, size.y/2);
                break;
            case POSRighter:
                vec_pos = Vec2f(size.x + buffer, size.y/2);
                break;
            default://Position out of bounds
            {
                vec_pos = Vec2f_zero;//Just return 0,0
                return false;//Nope.
            }
        }

        return true;
    }

    //1: Enum position you want the point to be on.
    //2: Size of the thing you want the point to be on. Very important.
    //3: The size of the point you want on the thing. For example text, you would put text dimensions here. This would make sure that text is placed inside the menu by dividing it by 2 where needed, so it wont be both half way in and half way out.
    //4: The desired position.
    //5: Optional buffer. For example if you specify POSBottom and make the buffer 2.0f, it will push the position up by 2.
    //Returns false if the inserted position enum was not found. This method works just like getPosOnSize, but takes in dimensions of the point you want on the thing too. See param 2 for an example of what this does.
    shared bool getPosOnSizeFull(u16 position, Vec2f size, Vec2f dimensions, Vec2f &out pos, float buffer = 0.0f)
    {
        if(!getPosOnSize(position, size, pos, buffer))
        {
            return false;
        }
        
        switch(position)
        {
            case POSTopLeft:
                pos = Vec2f(pos.x                 , pos.y);
                break;
            case POSTopRight:
                pos = Vec2f(pos.x - dimensions.x/2, pos.y);
                break;
            case POSBottomLeft:
                pos = Vec2f(pos.x                 , pos.y - dimensions.y);
                break;
            case POSBottomRight:
                pos = Vec2f(pos.x - dimensions.x/2, pos.y - dimensions.y);
                break;
            case POSCenter:
                pos = Vec2f(pos.x - dimensions.x/2, pos.y - dimensions.y/2);
                break;
            case POSTop:
                pos = Vec2f(pos.x - dimensions.x/2, pos.y);
                break;
            case POSAbove:
                pos = Vec2f(pos.x - dimensions.x/2, pos.y - dimensions.y); 
                break;
            case POSBottom:
                pos = Vec2f(pos.x - dimensions.x/2, pos.y - dimensions.y);
                break;
            case POSUnder:
                pos = Vec2f(pos.x - dimensions.x/2, pos.y);
                break;
            case POSLeft:
                pos = Vec2f(pos.x                 , pos.y - dimensions.y/2);
                break;
            case POSLefter:
                pos = Vec2f(pos.x - dimensions.x  , pos.y - dimensions.y/2);
                break;
            case POSRight:
                pos = Vec2f(pos.x - dimensions.x  , pos.y - dimensions.y/2);
                break;
            case POSRighter:
                pos = Vec2f(pos.x                 , pos.y - dimensions.y/2);
                break;
            default:
            {
                pos = Vec2f_zero;
                return false;
            }
        }

        return true;
    }
}