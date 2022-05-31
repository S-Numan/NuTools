#include "NuRend.as";
#include "DefaultStart.as";

//This file is a library of functions, it contains many convenient functions to make modding kag easier.

bool isLocalHost()
{
    return isClient() && isServer();
}

namespace Nu
{
    shared u64 u64_max()
    {
        return 18446744073709551615;
    }
    shared s64 s64_max()
    {
        return 9223372036854775807;
    }
    shared s64 s64_min()
    {
        return -9223372036854775808;
    }
    shared u32 u32_max()
    {
        return 4294967295;
    }
    shared s32 s32_max()
    {
        return 2147483647;
    }
    shared s32 s32_min()
    {
        return -2147483648;
    }
    shared u16 u16_max()
    {
        return 65535;
    }
    shared s16 s16_max()
    {
        return 32767;
    }
    shared s16 s16_min()
    {
        return -32768;
    }
    shared u8 u8_max()
    {
        return 255;
    }
    shared s8 s8_max()
    {
        return 127;
    }
    shared s8 s8_min()
    {
        return -128;
    }

    shared u8 getInt(bool value)
    {
        if(value){ return 1; }
        return 0;
    }

    //Returns every player in the server in an array.
    shared array<CPlayer@> getPlayers()
    {
        array<CPlayer@> players(getPlayerCount());
        
        for(u16 i = 0; i < getPlayerCount(); i++)
        {
            @players[i] = @getPlayer(i);
        }
        
        return players;
    }

    //1: Parameter of the team
    //Returns an array of players that are in that team. 
    shared array<CPlayer@> getPlayersInTeam(u8 team)
    {
        u16 i;//Init i.
        
        u16 team_players = getTeamCount(team);//Get amount of players in the team.

        array<CPlayer@> players(team_players);//Create the player array with the amount of players in the team.

        for(i = 0; i < getPlayerCount(); i++)//For every player
        {
            CPlayer@ player = getPlayer(i);//Get the player in a var.
            if(player.getTeamNum() == team)//If this player is the same team as the parameter "team"
            {
                team_players--;//Found a team player
                
                @players[team_players] = @player;//Add the team player to the array
            }
        }

        return players;//Return the array
    }

    //1: Parameter of the team.
    //Returns amount of players in the team. The player's team, not the blob team
    shared u16 getTeamCount(u8 team)
    {
        u16 i;
        u16 team_players = 0;

        for(i = 0; i < getPlayerCount(); i++)//For every player
        {
            if(getPlayer(i).getTeamNum() == team)//If this player is the same team as the parameter "team"
            {
                team_players++;//Add a team player
            }
        }
        return team_players;
    }

    //Returns an array of all the player blobs. Players without blobs will have their spot be null. This array lines up with the getPlayers() array
    shared array<CBlob@> getPlayerBlobs()
    {
        array<CBlob@> player_blobs(getPlayerCount());

        for(u16 i = 0; i < getPlayerCount(); i++)//For every player
        {
            @player_blobs[i] = @getPlayer(i).getBlob();//Put their blob into the array (even if it is null)
        }

        return player_blobs;//Return the player blobs.
    }

    //1: Input string.
    //Returns true, if that string has only digits 1-9 and dots (for floats). Returns false if it has something else (spaces aren't digits).
    shared bool IsNumeric(string _string)
    {
        bool single_dot = false;
        for(uint i = 0; i < _string.size(); i++)
        {    
            if(!single_dot && _string[i] == "."[0]) { single_dot = true; continue; }
            if(_string[i] < "0"[0] || _string[i] > "9"[0])
            {
                return false;
            }
        }

        return true;
    }//Thanks jammer312

    //1: Input string paramter.
    //2: Output bool value. If true, the string contained true. If false, the string contained false.
    //Returns a bool value of if the input_string is true or false. If the returned value happens to be false, it was neither true or false.
    shared bool getBool(string input_string, bool &out bool_value)
    {
        input_string = input_string.toLower();
        
        if(input_string == "1" || input_string == "true")
        {
            bool_value = true;
            return true;
        }
        else if(input_string == "0" || input_string == "false")
        {
            bool_value = false;
            return true;
        }

        bool_value = true;

        return false;
    }
    //Same as above, but with an input that is an int instead of a string.
    /*bool getBool(int input_value, bool &out bool_value)
    {
        if(input_value == 1)
        {
            bool_value = true;
            return true;
        }
        else if(input_value == 0)
        {
            bool_value = false;
            return true;
        }

        bool_value = true;

        return false;
    }*///decided to comment this out as doing it yourself should be better. Tell me if you disagree.

    //1: A string. The shortened/first half version of a player's username. Case sensitive.
    //Returns an array of players that have "shortname" at the start of their username. If their username is exactly the same, it will return an array containing only that player excluding the rest.
    shared array<CPlayer@> getPlayersByShortUsername(string shortname)
    {
        array<CPlayer@> playersout();//The main array for storing all the players which contain shortname

        for(int i = 0; i < getPlayerCount(); i++)//For every player
        {
            CPlayer@ player = getPlayer(i);//Grab the player
            if(player == @null)//If the player doesn't exist for whatever reason.
            {
                continue;//Skip past them.
            }

            string playerusername = player.getUsername();//Get the player's username

            if(playerusername == shortname)//If the name is exactly the same
            {
                array<CPlayer@> playersoutone;//Make a quick array
                playersoutone.push_back(player);//Put the player in that array
                return playersoutone;//Return this array
            }

            if(playerusername.substr(0, shortname.size()) == shortname)//If the players username contains shortname
            {
                playersout.push_back(player);//Put the array.
            }
        }
        return playersout;//Return the array
    }

    //1: A string. The shortened/first half version of a player's username. Case sensitive.
    //See getPlayersByShortUsername. This is more of an example of how to use than something you should use. Returns a single player if there was only one player, otherwise returns null.
    /*shared CPlayer@ getPlayerByShortUsername(string shortname)
    {
        array<CPlayer@> target_players = getPlayersByShortUsername(shortname);//Get a list of players that have this as the start of their username
        if(target_players.size() > 1)//If there is more than 1 player in the list
        {
            string playernames = "";
            for(int i = 0; i < target_players.size(); i++)//for every player in that list
            {
                playernames += " : " + target_players[i].getUsername();//put their name in a string
            }
            print("There is more than one possible player for the player param" + playernames);//tell the client that these players in the string were found
            return @null;//don't send the message to chat, don't do anything else
        }
        else if(target_players == @null || target_players.size() == 0)
        {
            print("No player was found for the player param.");
            return @null;
        }
        return target_players[0];
    }*/ //Use the one that returns an array


    //Parameters
    //1: A point.
    //2: The radius around that point to get the blobs from. Any player blobs outside the radius will not be put in the array.
    //3: If this array should skip both blobs in inventories, and unactive blobs. This is by default true.
    //Returns an array of all players sorted by distance. Players without blobs are not included in this array.
    shared array<CPlayer@> SortPlayersByDistance(Vec2f point, f32 radius, bool skip_unactive_and_inventory = true)
    {
        u16 i;

        u16 non_null_count = 0;
        
        array<CBlob@> playerblobs(getPlayerCount());

        //Put all blobs in playerblobs array
        for(i = 0; i < playerblobs.size(); i++)
        {
            CPlayer@ player = getPlayer(i);
            if(player != @null)
            {
                CBlob@ player_blob = player.getBlob();
                
                if(player_blob != @null//If the player has a blob. 
                && (!skip_unactive_and_inventory || player_blob.isActive() || !player_blob.isInInventory()))//And if skip_unactive is true, only if the blob is active and not in an inventory.
                {
                    @playerblobs[non_null_count] = @player_blob;
                    non_null_count++;
                }
            }
        }

        playerblobs.resize(non_null_count);

        playerblobs = SortBlobsByDistance(point, radius, playerblobs, skip_unactive_and_inventory);
        
        array<CPlayer@> sorted_players(playerblobs.size());

        for(i = 0; i < non_null_count; i++)
        {
            @sorted_players[i] = @playerblobs[i].getPlayer();
        }

        return sorted_players;
    }

    //Parameters
    //1: A point.
    //2: The radius around that point to get the blobs from. Any blob outside the radius will not be put in the array.
    //3: The array of blobs that are sorted.
    //4: If this array should skip both blobs in inventories, and unactive blobs. This is by default false.
    //Returns an array of blobs sorted by distance taken from the blob_array parameter. Blobs outside the radius, blobs that don't exist, and other cases will not be added to the array.
    shared array<CBlob@> SortBlobsByDistance(Vec2f point, f32 radius, array<CBlob@> blob_array, bool skip_unactive_and_inventory = false)
    {
        u16 i, j;

        array<CBlob@> sorted_array(blob_array.size());

        array<f32> blob_dist(blob_array.size());

        u16 non_null_count = 0;

        for (i = 0; i < blob_array.size(); i++)//Make an array that contains the distance that each blob is from the point.
        {
            if(blob_array[i] == @null//If the blob does not exist
            || (skip_unactive_and_inventory && (blob_array[i].isActive() == false || blob_array[i].isInInventory())))//Or skip_unactive is true and the blob is not active or in an inventory
            {
                continue;//Do not add this to the array
            }

            f32 dist = (blob_array[i].getPosition() - point).getLength();//Find the distance from the point to the blob
            
            if(dist > radius) //If the distance to the blob from the point is greater than the radius.
            {
                continue;//Do not add this to the array
            }

            @sorted_array[non_null_count] = blob_array[i];

            blob_dist[non_null_count] = dist;
            
            non_null_count++;
        }

        sorted_array.resize(non_null_count);//Resize to remove nulls
        blob_dist.resize(non_null_count);//This too. Null things don't have positions to calculate the distance between it and the point given.
        
        for (j = 1; j < non_null_count; j++)//Insertion sort each blob.
        {
            for(i = j; i > 0 && blob_dist[i] < blob_dist[i - 1]; i--)
            {
                //Swap
                float _dist = blob_dist[i - 1];
                blob_dist[i - 1] = blob_dist[i];
                blob_dist[i] = _dist;
                //Swap
                CBlob@ _blob = sorted_array[i - 1];
                @sorted_array[i - 1] = sorted_array[i];
                @sorted_array[i] = _blob;
            }
        }

        //for(i = 0; i < non_null_count; i++)
        //{
        //    print("blob_dist[" + i + "] = " + blob_dist[i]);
        //}

        return sorted_array;
    }
    
    //1: The point to check if it is within the radius
    //2: The center of the radius (or circle if you want to call it a circle)
    //3: The radius.
    //Returns if the point is within the radius
    shared bool isPointInRadius(Vec2f point, Vec2f radius_center, float radius)
    {
        if(Maths::Pow(point.x - radius_center.x, 2) + Maths::Pow(point.y - radius_center.y, 2) < Maths::Pow(radius, 2))
        {
            return true;
        }

        return false;
    }

    //1: Value to be rounded.
    //2: Multiple to be rounded by.
    //Rounds by the given multiple. If the multiple is 5 and the value is 277, this will return 275. If the multiple is 10 and the value is 277, this would return 280. 
    shared float RoundByMultiple(float value, float multiple = 10.0f)
    {
        if(multiple == 0) { return value; }
        return Maths::Roundf(value / multiple) * multiple;
        /*f32 rem = Maths::FMod(value, multiple);
        f32 result = value - rem;
        if (rem > (multiple / 2))
            result += multiple;
        return result;*/
    }
    shared int RoundByMultiple(int value, int multiple = 10)//Same as above but for ints.
    {
        if(multiple == 0) { return value; }
        return Maths::Round(value / multiple) * multiple;
        /*int rem = value % multiple;
        int result = value - rem;
        if (rem > (multiple / 2))
            result += multiple;
        return result;*/
    }
    //Same as above except instead of rounding up, it always rounds down.
    shared float RoundDown(float value, float multiple = 10.0f)
    {
        if(multiple == 0) { return value; }
        return value - Maths::FMod(value, multiple);
    }
    shared int RoundDown(int value, int multiple = 10)//For ints
    {
        if(multiple == 0) { return value; }
        return value - value % multiple;
    }
    shared float Floor(float value, float multiple = 10.0f)//Alias
    {
        return RoundDown(value, multiple);
    }
    shared int Floor(int value, int multiple = 10)//Alias for ints
    {
        return RoundDown(value, multiple);
    }
    
    //1: Point to get the tile under.
    //Returns the top of the tile under the point.
    shared f32 getTileUnderPos(Vec2f pos)
    {
        CMap@ map = getMap();	
        u16 tilesdown = 0;
        
        u32 pos_y = pos.y - pos.y % map.tilesize;//Store the y pos floored to the nearest top of a tile
        while(true)//Loop until stopped inside
        {
            if(map.tilemapheight * map.tilesize < pos_y + tilesdown * map.tilesize)//If we are checking below the map itself
            {
                break;
            }
            if(map.isTileSolid(Vec2f(pos.x, pos_y + map.tilesize * tilesdown)))//if this current point has a solid tile
            {
                return(pos_y + tilesdown * map.tilesize);//The current blobs pos plus one or more tiles down
            }
            tilesdown += 1;
        }
        return 0.0f;
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

    //1: The size of the image.
    //2: The size of the frame in the image
    //Returns the amount of frames in a given size.
    shared u16 getFramesInSize(Vec2f image_size, Vec2f frame_size)
    {
        Vec2f output;
        if(frame_size.x == 0 || frame_size.y == 0)
        {
            return 0;
        }

        output.x = image_size.x / frame_size.x;
        output.y = image_size.y / frame_size.y;
    
        return u16(output.x * output.y);
    }

    //1: The size of the image.
    //2: The size of the frame in the image
    //3: The frame you want in the image.
    //Returns the Vector of where the desired frame starts. (top left)
    shared Vec2f getFrameStart(Vec2f image_size, Vec2f frame_size, u16 desired_frame)
    {
        Vec2f frame_start = Vec2f(0,0);

        frame_start.x = frame_size.x * desired_frame % image_size.x;

        frame_start.y = int(frame_size.x * desired_frame / image_size.x) * frame_size.y;

        return frame_start;
    }

    //1: Where the frame starts
    //2: How big the frame is
    //3: Returns the end of a frame. (bottom right)
    shared Vec2f getFrameEnd(Vec2f frame_start, Vec2f frame_size)
    {
        Vec2f frame_end = frame_start + frame_size;

        return frame_end;
    }

    //1: The size of the image.
    //2: The size of the frame in the image
    //3: The frame you want in the image.
    //Returns an array of the four positions. Now in UV style! Buy now for only 19.99$ free shipping and handling.
    shared array<Vec2f> getUVFrame(Vec2f image_size, Vec2f frame_size, u16 desired_frame)
    {
        Vec2f frame_start = getFrameStart(image_size, frame_size, desired_frame);
        Vec2f frame_end = getFrameEnd(frame_start, frame_size);

        return getUVFrame(image_size, frame_start, frame_end);
    }
    //Same as above, but less user friendly. Set the frame start and end here instead of frame_size and desired frame.
    shared array<Vec2f> getUVFrame(Vec2f image_size, Vec2f frame_start, Vec2f frame_end)
    {
        Vec2f[] v_uv(4);

        frame_start.x = frame_start.x / image_size.x;
        frame_start.y = frame_start.y / image_size.y;

        frame_end.x = frame_end.x / image_size.x;
        frame_end.y = frame_end.y / image_size.y;

        v_uv[0] = Vec2f(frame_start.x,  frame_start.y   );//Top left
        v_uv[1] = Vec2f(frame_end.x,    frame_start.y   );//Top right
        v_uv[2] = Vec2f(frame_end.x,    frame_end.y     );//Bottom right
        v_uv[3] = Vec2f(frame_start.x,  frame_end.y     );//Bottom left
    
        return v_uv;
    }

    
    //1: The size of the frame
    //2: Optional extra Vec2f applied to each Vector in the returned array for ease.
    //Returns an array of the four positions (top left. top right. bottom left. bottom right.) of the frame.
    shared array<Vec2f> getFrameSizes(Vec2f frame_size, Vec2f add_to = Vec2f(0,0))
    {
        Vec2f[] v_pos(4);

        v_pos[0] = add_to + Vec2f(0,                0                   );//Top left
        v_pos[1] = add_to + Vec2f(0 + frame_size.x, 0                   );//Top right
        v_pos[2] = add_to + Vec2f(0 + frame_size.x, 0 + frame_size.y    );//Bottom right
        v_pos[3] = add_to + Vec2f(0,                0 + frame_size.y    );//Bottom left

        //v_pos[0] = add_to + Vec2f(-frame_start.x,   -frame_start.y  );//Top left
        //v_pos[1] = add_to + Vec2f( frame_end.x,     -frame_start.y  );//Top right
        //v_pos[2] = add_to + Vec2f( frame_end.x,     frame_end.y     );//Bottom right
        //v_pos[3] = add_to + Vec2f(-frame_start.x,   frame_end.y     );//Bottom left
    
        return v_pos;
    }


    //1: The first vector.
    //2: The second Vector
    //Returns a vector of two vector's x's and y's multiplied together. 
    shared Vec2f MultVec(Vec2f value1, Vec2f value2)
    {
        value1.x = value1.x * value2.x;
        value1.y = value1.y * value2.y;
        return value1;
    }
    


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


    //1: Output scriptstack string
    //2: Output callstack string
    //3: Optional skip parameter. This skips the amount of callstacks as input in. It is by default 1 to skip itself.
    //Gives out two variables that are the scriptstack and callstack. They are both numbered.
    shared void getStackString(string &out scriptstack, string &out callstack, u16 skip = 1)
    {
        u16 i;

        array<string> stack = getScriptStack();

        scriptstack = "";

        for(i = 0; i < stack.size(); i++)
        {
            string next_line;
            if(i != stack.size() - 1)//As long as this isn't the last iteration.
            {
                next_line = "\n          ";//Throw a next line on the end.
            }

            scriptstack += "#" + (i + 1) + ": " + stack[i] + next_line;
        }

        stack = getCallStack();
        
        callstack = "";//Output

        for(i = skip; i < stack.size(); i++)//Skip getCallStackString.
        {
            string next_line;
            if(i != stack.size() - 1)//As long as this isn't the last iteration.
            {
                next_line = "\n          ";//Throw a next line on the end.
            }

            callstack += "#" + (i - skip + 1) + ": " + stack[i] + next_line;
        }
    }

    //1: Text to send as the message.
    //2: Optional Message color.
    //3: Optional Regular color.
    //4: Optional Title color.
    //5: Optional Skipped callstacks.
    //Throws an error to the console, with the script stack and callstack included and colored.
    shared void StackAndMessage(string input, SColor message_color = SColor(255, 0, 50, 255), SColor regular_color = SColor(200, 255, 255, 255), SColor title_color = SColor(255, 0, 255, 255), u16 skip = 2)
    {
        string scriptstack;
        string callstack;

        getStackString(scriptstack, callstack, skip);//Skip itself and this method. that is what 2 means. 
        
        //print("1==========1 ", message_color);

        print("Script stack", title_color);
        
        print(scriptstack, regular_color);
        
        print("Callstack for current script: ", title_color);

        print(callstack, regular_color);
        
        if(input.size() != 0)//If there is an input.
        {
            print("Message: " + input, message_color);
        }
        //print("2==========2 ", message_color);
    }
    //1: Text to throw out as the message.
    //Calls StackAndMessage with error colors.
    shared void Error(string input)
    {
        StackAndMessage(input, SColor(255, 255, 0, 0), SColor(200, 255, 255, 255), SColor(255, 255, 0, 200), 3);
    }
    //1: Text to throw out as the message.
    //Calls StackAndMessage with warning colors.
    shared void Warning(string input)
    {
        StackAndMessage(input, SColor(255, 255, 255, 0), SColor(200, 255, 255, 255), SColor(255, 255, 0, 200), 3);
    }


    //1: Vec2f 1.
    //2: Vec2f 2.
    //Returns a float that is the distance between the two points.
    shared float getDistance(Vec2f point1, Vec2f point2)
    {
        float dis = (Maths::Pow(point1.x-point2.x,2)+Maths::Pow(point1.y-point2.y,2));
        return Maths::Sqrt(dis);
        //return getDistanceToLine(point1, point1 + Vec2f(0,1), point2);
    }

    //1: float 1.
    //2: float 2.
    //Returns a float that is the distance between the two floats.
    shared float getDistance(float value1, float value2)
    {
        float dis = Maths::Abs(value1 - value2);
        return dis;
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

    //1: Regular position in world space.
    //Returns the tile position of this vector.
    shared Vec2f TilePosify(Vec2f pos)
    {
        CMap@ map = getMap();
        pos.x = Maths::Floor(pos.x) / map.tilesize;
        pos.y = Maths::Floor(pos.y) / map.tilesize;

        return pos;
    }

    //1: The player the message is sent to.
    //2: The message sent to the player.
    //3: Optional color of the text. (default red)
    //4: Optional bool. if true, instead of placing the message in the player's chat it will place the message in the players's console
    //Sends a message to a specific player. by default, into their chat box.
    shared void sendClientMessage(CPlayer@ player, string message, SColor color = SColor(255, 255, 0, 0), bool to_console = false)//Now with color
    {
        CRules@ rules = getRules();


        CBitStream params;//Assign the params
        params.write_bool(to_console);
        params.write_string(message);
        params.write_u8(color.getAlpha());
        params.write_u8(color.getRed());
        params.write_u8(color.getGreen());
        params.write_u8(color.getBlue());
        if(isServer())//Is server, or is localhost
        {
            rules.SendCommand(rules.getCommandID("clientmessage"), params, player);//Send message to player via command
        }
        else//Is client
        {
            SendClientToClientCommand(rules, rules.getCommandID("clientmessage"), params, player);
        }
    }

    //1: The message sent to all player's.
    //2: Optional color of the message. (default red)
    //3: Optional bool. if true, instead of placing the message in the player's chat it will place the message in the players's console
    //Sends a message to every player. by default, into their chat box.
    shared void sendAllMessage(string message, SColor color = SColor(255, 255, 0, 0), bool to_console = false)
    {
        for(u16 i = 0; i < getPlayerCount(); i++)
        {
            CPlayer@ player = getPlayer(i);
            if(player == null) { continue; }
            sendClientMessage(player, message, color, to_console);
        }
    }

    //1: The player this message is sent to.
    //2: The message contents.
    //Sends a drop down from the top of screen message to the specified player, this is referred to as a "engine message".
    shared void sendEngineMessage(CPlayer@ player, string message)//Message that comes down from the top of the screen.
    {
        CRules@ rules = getRules();

        CBitStream params;//Assign the params
        params.write_string(message);

        rules.SendCommand(rules.getCommandID("enginemessage"), params, player);
    }

    //1: The blob that both has it's inventory checked, and item held.
    //2: The blob to be held by pblob.
    //3: Controls if the blob held by pblob is put in the inventory of pblob instead of dropped on the ground to make space for get_blob.
    //Takes get_blob from pblob's inventory and makes it held by pblob. 
    shared void SwitchFromInventory(CBlob@ pblob, CBlob@ get_blob, bool inventorise_held = true)
    {
        if(pblob == @null) { return; Nu::Error("pblob was null"); }
        if(get_blob == @null) { return; Nu::Error("get_blob was null"); }

        CInventory@ inv = pblob.getInventory();
        if(inv == @null) { return; }

        CBlob@ carried_blob = pblob.getCarriedBlob();

        if(!inv.isInInventory(get_blob) && @get_blob != @carried_blob) { return; }//get_blob has to either be in the inventory of pblob or be held by pblob

        if(inventorise_held && carried_blob != @null && !inv.canPutItem(carried_blob))//Supposed to put the currently not null held item in the inventory but it isn't possible?
        {
            return;//CEASE
        }

        CRules@ rules = getRules();
        CBitStream params;

        params.write_bool(inventorise_held);
        params.write_u16(pblob.getNetworkID());
        params.write_u16(get_blob.getNetworkID());

        rules.SendCommand(rules.getCommandID("switchfrominventory"), params, false);//Send command to server only
    }
    //Exact same as above, except takes a string in place of the get_blob and converts it to a blob.
    shared void SwitchFromInventory(CBlob@ pblob, string s_get_blob, bool inventorise_held = true)
    {
        CInventory@ inv = pblob.getInventory();
        if(inv == @null) { return; }

        CBlob@ get_blob = inv.getItem(s_get_blob);
        if(get_blob == @null) { return; }

        SwitchFromInventory(pblob, get_blob, inventorise_held);
    }


    shared CBlob@ RespawnPlayer(CRules@ rules, CPlayer@ player)
    {
        return RespawnPlayer(rules, player, "", Vec2f_zero);
    }
    shared CBlob@ RespawnPlayer(CRules@ rules, CPlayer@ player, string blob_name)
    {
        return RespawnPlayer(rules, player, blob_name, Vec2f_zero);
    }
    shared CBlob@ RespawnPlayer(CRules@ rules, CPlayer@ player, Vec2f spawn)
    {
        return RespawnPlayer(rules, player, "", spawn);
    }
    //1: rules for rules things
    //2: player that will be respawned
    //3: optional parameter to specify what blob they will respawn as
    //4: optional paramter to specify spawn location
    //Respawns the player firstly at a spawn if avaliable, secondly at the ground from the top left.
    shared CBlob@ RespawnPlayer(CRules@ rules, CPlayer@ player, string blob_name, Vec2f spawn)
    {
        if(!isServer()) { Nu::Warning("Tried respawning player on client"); return @null; }
        if(player == @null) { Nu::Error("player was null"); return @null; }

        CMap@ map = getMap();

        Vec2f[] spawns;
        
        int player_team = player.getTeamNum();

        //
        //Find spawn location
        //
        bool no_spawn = false;//If no spawn was found, this will be true.
        if(spawn == Vec2f_zero)
        {
            if (player_team == 0)//Team 0?
            {
                if(getMap().getMarkers("blue spawn", spawns))//If blue markers exist
                {
                    spawn = spawns[ XORRandom(spawns.length) ];//Pick on randomly
                }
                else if(getMap().getMarkers("blue main spawn", spawns))//if blue main markers exist
                {
                    spawn = spawns[ XORRandom(spawns.length) ];//Pick one randomly
                }
            }
            else if (player_team == 1)//Team 1?
            {
                if(getMap().getMarkers("red spawn", spawns))
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                }
                else if(getMap().getMarkers("red main spawn", spawns))
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                }
            }
            if(spawn == Vec2f_zero)//No spawn found?
            {
                if(getMap().getMarkers("default spawn", spawns))
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                }
                else if(getMap().getMarkers("default main spawn", spawns))
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                }
            }
            if(spawn == Vec2f_zero)
            {
                CBlob@[] respawn_posts;
                getBlobsByTag("respawn", @respawn_posts);

                spawns.resize(0);

                for (u16 i = 0; i < respawn_posts.size(); i++)
                {
                    CBlob@ blob = respawn_posts[i];

                    if (blob.getTeamNum() == player_team)
                    {
                        spawns.push_back(blob.getPosition());
                    }
                }
                if(spawns.size() != 0)
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                    spawn.y += map.tilesize;//One tile down.
                }
            }

            if(spawn == Vec2f_zero)//Still no spawn found?
            {
                no_spawn = true;//No spawn was found

                spawn.x = map.tilesize * 2;//Start two tiles out
                
                //Look for ground under point tile by tile going right.
                while(spawn.y == 0.0f)//While no ground is found
                {
                    if(spawn.x > map.tilemapwidth * map.tilesize)//If we've gone beyond the right of the map.
                    {
                        spawn = Vec2f(0,0);//Just default to the top left
                        break;//And stop
                    }
                    spawn.x += map.tilesize;//Go one tile right
                    spawn.y = Nu::getTileUnderPos(Vec2f(spawn.x, 0));//Find tile below x pos
                }
            }
        }
        //
        //Find spawn location
        //


        string actor;//Name of the new blob
        if(blob_name != "")//If a blob name is specified.
        {
            actor = blob_name;//Use it
        }
        else if(rules.get_bool("respawn_as_last_blob") && player.lastBlobName != "")//No blob name? If respawn_as_last_blob is true, check for a lastBlobName. 
        {
            actor = player.lastBlobName;//Use it
        }
        else//No last player blob?
        {
            actor = rules.get_string("default class");//Just default to the default class
        }

        CBlob@ newBlob = server_CreateBlob(actor);//Create the new blob with the player's team at the position spawn

        if(newBlob != @null)//If the new blob is not null
        {
            if(!no_spawn)//If no spawn was found
            {
                spawn.y -= newBlob.getHeight() / 2;//Push blob up from spawn location to keep it from colliding with the ground.
            }

            f32 tile_under_pos = Nu::getTileUnderPos(spawn);//Get tile under the spawn location.
            while(spawn.y + (newBlob.getHeight() / 2) > tile_under_pos)//While the newBlob is colliding with the ground.
            {
                spawn.y -= map.tilesize;//Push the spawn position up by one.
            }

            newBlob.server_setTeamNum(player_team);//Set team
            newBlob.setPosition(spawn);//Set spawn location

            CBlob@ plob = @player.getBlob();//Get the current player's blob
            if(plob != @null)//If it is not null.
            {
                plob.server_SetPlayer(@null);//No idea if this is needed
                plob.server_Die();//Deadify it.
            }
            newBlob.server_SetPlayer(player);//Set the player to it's new blob
        }

        return @newBlob;
    }

    //1: Float for the Vec2f
    //Takes a float, and puts it in both sides of a Vec2f, then returns the Vec2f. Generally only useful if you don't want to call something twice like a config read, and also don't want to put a variable on another line.
    shared Vec2f f32ToVec2f(float value)
    {
        return Vec2f(value, value);
    }

    //1: float 1
    //2: float 2
    //3: float
    //Gets the median between 3 floats
    shared float Median(float r, float g, float b) 
    {
        return Maths::Max(Maths::Min(r, g), Maths::Min(Maths::Max(r, g), b));
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

    //1: Min value for random number
    //2: Max value for random number (- 1)
    //This gives you a random integer between the min and max specified values
    shared s32 getRandomInt(s32 min, s32 max)
    {
        NuRend@ rend;
        if(!getRend(@rend)) { return 0; }

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

    //TODO, not tested
    shared CBlob@ getHolder(CBlob@ held)
    {
        if(!held.isAttached()) { return @null; }
        
        AttachmentPoint@ point = held.getAttachments().getAttachmentPointByName("PICKUP");
        if(point == @null) { return @null; }
        
        return point.getOccupied();
    }
    
    shared void LoadAMap(string map_name = " ")
    {
        CRules@ rules = getRules();
        
        CBitStream params;
        params.write_string(map_name);

        rules.SendCommand(rules.getCommandID("nunextmap"), params, false);//Send command to only server
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

    namespace Rules
    {
        //Sync is for the server only. Sync does nothing for clients

        shared enum script_function
        {
            FClearScripts = 1,
            FRemoveScript,
            FAddScript,
            FAddGamemode,
            FSyncEntireGamemode,
            FLateLoadRules,
            ScriptFunctionCount
        }

        shared void ClearScripts(bool sync = false, array<string> skip_these = array<string>(1, "NuToolsLogic.as"))
        {
            CRules@ rules = getRules();

            array<string> script_array;
            if(!rules.get("script_array", script_array))
            {
                return;
            }


            for(u16 i = 0; i < script_array.size(); i++)
            {
                bool skip_this = false;
                for(u16 q = 0; q < skip_these.size(); q++)
                {
                    if(script_array[i] == skip_these[q]) { skip_this = true; break; }//Skip   
                }
                if(skip_this) { continue; }//Skip

                if(!rules.RemoveScript(script_array[i])) { Nu::Error("Failed to remove script somehow? Might've used AddScript via CRules rather than Nu::\nFailed to remove script " + script_array[i]); }
            
                script_array.removeAt(i);
                i--;
            }
            
            rules.set("script_array", script_array);//Set new array
        
            rules.set_bool("DummyFeaturesEnabled", true);
            rules.Sync("DummyFeaturesEnabled", true);

            if(sync)
            {
                if(!isClient())//Is server, not localhost
                {
                    CBitStream params;
                    params.write_u8(FClearScripts);
                    for(u16 q = 0; q < skip_these.size(); q++)
                    {
                        params.write_string(skip_these[q]);
                    }
                    Nu::SendCommandSkipSelf(rules, rules.getCommandID("NuRuleScripts"), params);//Sync to all clients, skip server.
                    return;//Return, because the server will get this command later anyway.
                }
                else if(!isServer()) { Nu::Warning("Sync on client not allowed."); }//Is client, is not localhost
            }
        }

        shared bool RemoveScript(string script_name, bool sync = false)
        {
            CRules@ rules = getRules();

            if(!hasScript(script_name)) { return false; }//Script doesn't exist? Can't remove what isn't there.
            array<string> script_array;
            if(!rules.get("script_array", script_array)) { Nu::Error("Could not find script_array"); return false; }

            for(u16 i = 0; i < script_array.size(); i++)//For every script
            {
                if(script_array[i] == script_name)//If this script is the same as script_name
                {
                    script_array.removeAt(i);//Remove it
                    break;//Exit this loop
                }
            }

            if(!rules.RemoveScript(script_name))//Attempt to remove the script from rules
            {//Failure?
                Nu::Error("Script " + script_name + " failed to remove? How?"); return false;//???
            }
            
            rules.set("script_array", script_array);//Set new array
        
            rules.set_bool("DummyFeaturesEnabled", true);
            rules.Sync("DummyFeaturesEnabled", true);

            if(sync)
            {
                if(!isClient())//Is server, not localhost
                {
                    CBitStream params;
                    params.write_u8(FRemoveScript);
                    params.write_string(script_name);
                    Nu::SendCommandSkipSelf(rules, rules.getCommandID("NuRuleScripts"), params);//Sync to all clients, skip server.
                    return true;//Return, because the server will get this command later anyway.
                }
                else if(!isServer()) { Nu::Warning("Sync on client not allowed."); }//Is client, is not localhost
            }

            return true;
        }

        shared bool AddScript(string script_name, bool sync = false)
        {
            CRules@ rules = getRules();

            if(hasScript(script_name)) { return false; }//Script already exists? Don't add it
            array<string> script_array;
            if(!rules.get("script_array", script_array)) { Nu::Error("Could not find script_array"); return false; }
            
            if(!CFileMatcher(script_name).hasMatch()) { Nu::Error("No match found for " + script_name); return false; }
            rules.AddScript(script_name);
            //if(!rules.hasScript(script_name))//Does not work without waiting a tick.

            script_array.push_back(script_name);//Add it to the script array.
            
            rules.set("script_array", script_array);//Set new array

            rules.set_bool("DummyFeaturesEnabled", true);
            rules.Sync("DummyFeaturesEnabled", true);

            if(sync)
            {
                if(!isClient())//Is server, not localhost
                {
                    CBitStream params;
                    params.write_u8(FAddScript);
                    params.write_string(script_name);
                    Nu::SendCommandSkipSelf(rules, rules.getCommandID("NuRuleScripts"), params);//Sync to all clients, skip server.
                    return true;//Return, because the server will get this command later anyway.
                }
                else if(!isServer()) { Nu::Warning("Sync on client not allowed."); }//Is client, is not localhost
            }

            return true;
        }

        shared bool hasScript(string script_name)
        {
            CRules@ rules = getRules();

            array<string> script_array;
            if(!rules.get("script_array", script_array))
            { 
                //Nu::Error("Could not find script_array");
                return false;//The answer is no.
            }

            for(u16 i = 0; i < script_array.size(); i++)
            {
                if(script_array[i] == script_name)
                {
                    return true;
                }
            }
            
            return false;
        }

        shared array<string> getScriptArray()
        {
            CRules@ rules = getRules();

            array<string> script_array;
            if(!rules.get("script_array", script_array)) { Nu::Error("Could not find script_array"); return array<string>(); }
            return script_array;
        }

        shared void AddGamemode(string the_gamemode, bool sync = false)
        {
            CRules@ rules = getRules();

            ::AddGamemode(@getRules(), the_gamemode);

            rules.set_bool("DummyFeaturesEnabled", true);
            rules.Sync("DummyFeaturesEnabled", true);

            if(sync)
            {
                if(!isClient())//Is server, not localhost
                {
                    CBitStream params;
                    params.write_u8(FAddGamemode);
                    params.write_string(the_gamemode);
                    Nu::SendCommandSkipSelf(rules, rules.getCommandID("NuRuleScripts"), params);//Sync to all clients, skip server.
                    return;//Return, because the server will get this command later anyway.
                }
                else if(!isServer()) { Nu::Warning("Sync on client not allowed."); }//Is client, is not localhost
            }
        }

        shared void SetGamemode(string the_gamemode, bool sync = false)
        {
            ClearScripts(sync, array<string>());
            
            AddGamemode(the_gamemode, sync);
        
            /*if(!hasScript("NuToolsLogic.as"))
            {
                print("adding NuToolsLogic.as in SetGamemode to prevent being unable to switch back gamemodes.");
                AddScript("NuToolsLogic.as", sync);
            }*/
        }
    }




    //Sends a command via CBlob to all but the sender
    //void SendCommand(CBlob@ blob, u8 command_id, CBitStream@ bs)
    //{
    //    
    //}
    
    //1: CRules, required
    //2: Command ID
    //3: Params for the command
    //4: Optional parameter to specify if this is sent to the server. If this parameter is false, this command wont be sent to the server. 
    //Sends a command via CRules to all but the sender
    shared void SendCommandSkipSelf(CRules@ rules, u8 command_id, CBitStream@ params, bool sendToServer = true)
    {
        if(isServer())//The server
        {
            for(u16 i = 0; i < getPlayerCount(); i++)//Send the command to all players
            {
                CPlayer@ player = getPlayer(i);
                if(@player == @null) { continue; }//If player is null, skip
                rules.SendCommand(command_id, params, player);//Send this command to this specific player   
            }
        }
        else//A client
        {
            for(u16 i = 0; i < getPlayerCount(); i++)//Send the command to all players
            {
                CPlayer@ player = getPlayer(i);
                if(@player == @null || @player == @getLocalPlayer()) { continue; }//If player is null, skip. Or if the player is the sender, skip.
                rules.SendCommand(command_id, params, player);//Send this command to this specific player
            }
            if(sendToServer)
            {
                rules.SendCommand(command_id, params, false);//Send this command to the server
            }
        }
    }
    
    //DON'T DO ANYTHING IMPORTANT USING THIS FUNCTION! it is a jank work around
    shared void SendClientToClientCommand(CRules@ rules, u8 command_id, CBitStream@ sendparams, CPlayer@ player)
    {
        if(!isClient()) { Nu::Error("Tried to send ClientToClient command from server. Cease."); return; }
        if(player == @null) { Nu::Error("Player was null"); return; }

        CBitStream params;
        params.write_u8(command_id);
        params.write_u16(player.getNetworkID());
        params.write_CBitStream(sendparams);
        rules.SendCommand(rules.getCommandID("clienttoclient"), params, false);//Send command to server
    }







    shared class IntKeyDictionary
    {
        IntKeyDictionary()
        {
            Keys = array<s32>();
            KeyPointers = array<s32>();
            Values = array<s32>();
        
            expected_size = 50;
        }

        private array<s32> Keys;
        private array<s32> KeyPointers;
        private array<s32> Values;

        u32 expected_size;

        //TODO?
        //void set(s32 _key, Object &in ob)
        //{
        //}

        void set(s32 _key, s32 _value)
        {
            u32 i;
            for(i = 0; i < Keys.size(); i++)//For every key
            {
                if(Keys[i] == _key)//If the key already exists
                {
                    Values[KeyPointers[i]] = _value;//Assign the value to where the key points to
                    return;//End
                }
            }

            bool free_key = false;

            for(i = 0; i < Keys.size(); i++)//For every key.
            {
                if(Keys[i] == s32_min())//If the key is free.
                {   //It's free estate.
                    Keys[i] = _key;
                    free_key = true;
                    break;
                }
            }

            if(!free_key)//No free key position found?
            {
                i = Keys.size();
                Keys.push_back(_key);//Create more space for the new key and add it.
                KeyPointers.push_back(0);//Create more space for the KeyPointers too.
            }

            for(u32 q = 0; q < Values.size(); q++)//For each value
            {
                if(Values[q] == s32_min())//If the value position is free
                {
                    KeyPointers[i] = q;//This is the new position that KeyPointers points to.
                    Values[q] = _value;//Set new value at this position.
                    return;//We're done here
                }
            }
            
            //No free value position found?

            KeyPointers[i] = Values.size();//Make the new key pointer point to the end of the values array

            Values.push_back(_value);//Add the value to the values array
        }

        bool get(s32 _key, s32 &out _value)
        {
            for(u32 i = 0; i < Keys.size(); i++)//For every key
            {
                if(Keys[i] == _key)//If the key exists
                {
                    _value = Values[KeyPointers[i]];//Get the value from where the key points to
                    return true;//Return with a college degree
                }
            }

            return false;//Return as a highschool dropout
        }

        bool exists(s32 _key)
        {
            for(u32 i = 0; i < Keys.size(); i++)//For every key
            {
                if(Keys[i] == _key)//If the key exists
                {
                    return true;//Return a yes, the key exists
                }
            }

            return false;
        }

        void delete(s32 _key)
        {
            for(u32 i = 0; i < Keys.size(); i++)//For every key
            {
                if(Keys[i] == _key)//If the key exists
                {
                    s32 key_pointer = KeyPointers[i];//Get what value the key points to
                    Values[key_pointer] = s32_min();//Remove the value
                    Keys[i] = s32_min();//Remove the key
                    KeyPointers[i] = s32_min();//Remove the key pointer

                    return;//End
                }
            }
        }

        void deleteAll()
        {
            //if(Keys.size() > expected_size) { Keys.resize(expected_size) }
            u32 i;
            for(i = 0; i < Keys.size(); i++)
            {
                Keys[i] = s32_min();
                KeyPointers[i] = s32_min();
            }
            for(i = 0; i < Values.size(); i++)
            {
                Values[i] = s32_min();
            }            
        }

        void wipeArrays()
        {
            Keys.resize(0);
            KeyPointers.resize(0);
            Values.resize(0);
        }
        

        u32 getSize()
        {
            return size();
        }
        u32 size()
        {
            u32 count = 0;
            for(u32 i = 0; i < Keys.size(); i++)
            {
                if(Keys[i] != s32_min())
                {
                    count++;
                }
            }
            return count;
        }
        u32 realSize()
        {
            return Keys.size();
        }

        bool isEmpty()
        {
            return (size() == 0);
        }

        array<s32> getKeys()//Gets keys for the array.
        {
            return Keys;
        }

        array<s32> getValuesInOrder()//Gets the values for the keys, in the order the keys are in provided you get the keys through the getKeys() method.
        {
            array<s32> orderedValues(Keys.size());

            for(u32 i = 0; i < Keys.size(); i++)
            {
                s32 _value;
                
                get(Keys[i], _value);
                
                orderedValues[i] = _value;
            }

            return orderedValues;
        }

        //Merges another dictionaries with this dictionary.
        //Adds all keys to this dictionary
        //Provided the key already exists in this dictionary, an attempt to add the values together of each key is made.
        void ConsumeDictionary(IntKeyDictionary@ dic, bool remove_zero = false)
        {
            array<s32> input_keys = dic.getKeys();//Get all keys for this input
            array<s32> input_values = dic.getValuesInOrder();//Get all values for this input in the order of the keys
        
            for(u32 q = 0; q < input_keys.size(); q++)//For each key
            {
                s32 current_value;
                if(!get(input_keys[q], current_value))//If the key does not exist in this dictionary
                {
                    set(input_keys[q], input_values[q]);//Add it
                }
                else//Key exists in this dictionary
                {
                    current_value += input_values[q];//Add the values together
                    if(remove_zero && current_value == 0)//If the value is 0
                    {
                        delete(input_keys[q]);//Remove it
                    }
                    else//Value not equal to 0
                    {
                        set(input_keys[q], current_value);//Set the new value
                    }
                }
            }
        }

        void savefile(string file_name)
        {
            print("savefile not implemented");
        }

        void loadfile(string file_name)
        {
            print("loadfile not implemented");
        }
    }



    //You should use NuImage instead, unless you know what you're doing.
    //Not advised for use on things that often change frames, use NuImage instead.
    shared class NuImageLight
    {
        NuImageLight()
        {
            Setup();
        }
        //TODO, make constructor that let's you put CreateImage stuff in straight away.

        private u16 frame;

        void Setup()
        {
            if(!isClient()) { Nu::Error("NuImage was created serverside. This should not happen."); }
            frame = 0;
            Vec2f offset = Vec2f(0,0);

            is_texture = false;
            v_raw = array<Vertex>(4);
            frame_points = array<Vec2f>(4);
            frame_uv = array<Vec2f>(4);
            z = array<float>(4, 0.0f);
            center_scale = false;
            scale = Vec2f(1.0f, 1.0f);
            would_crash = false;
            angle = 0.0f;
            color = SColor(255, 255, 255, 255);

            recalculate_v_raw = false;

            frame_size = Vec2f(0,0);
            frame_center = Vec2f(0,0);
            image_size = Vec2f(0,0);
            max_frames = 0;

            name = "";
            name_id = 0;
        }

        u16 name_id;//Used for keeping track of what image is what image. For when using several NuImages in one array for example. Loop through the array and compare enums to this.
        //Todo - replace name_id with a string name and hash?

        string name;//Either file name, or texture name.


        bool recalculate_v_raw;

        Vec2f frame_center;//Center of frame_points

        private SColor color;
        void setColor(SColor _color)//Sets the color
        {
            color = _color;

            if(!recalculate_v_raw) { recalculate_v_raw = true; }
        }
        SColor getColor()
        {
            return color;
        }

        array<Vec2f> frame_uv;//TODO, make this an array of arrays, and only use the first array in NuImageLight. Then make it 4 arrays in NuImage.

        void CalculateFrameUV()//Calculates the UV (4 points in the image) for the current frame.
        {
            if(!is_texture) { return; }

            frame_uv = Nu::getUVFrame(
                image_size,//Image size
                frame_size,//Frame size
                frame//Desired frame
                );
        }    

        void CalculateVRaw()//Calculates the details needed for rendering.
        {
            v_raw = getVertices(would_crash, would_crash, v_raw,
                frame_uv, frame_points,
                z, scale, center_scale, frame_center, offset, angle, color);
        
            if(recalculate_v_raw) { recalculate_v_raw = false; }
        }

        private u16 max_frames;

        u16 getMaxFrames()
        {
            return max_frames;
        }

        void setFrame(u16 _frame, bool calculate = true)//Sets the frame
        {
            if(_frame >= max_frames)//If the frame goes beyond max_frames.
            {
                if(max_frames == 0) { Nu::Error("Max frames was 0 on attempt to setFrame in NuImage to frame " + _frame); return; }
                _frame = _frame % max_frames;
            }
            frame = _frame;
            
            if(calculate)
            {
                CalculateFrameUV();
            
                if(!recalculate_v_raw) { recalculate_v_raw = true; }
            }
        }
        u16 getFrame()//Sets the frame
        {
            return frame;
        }

        bool is_texture;//Sets if this is a texture. If this is false, this is not a texture.

        private Vec2f image_size;//Size of the image given.
        void setImageSize(Vec2f &in value, bool calculate = true)
        {
            if(image_size != value)
            {
                image_size = value;
                max_frames = getFramesInSize(image_size, frame_size);

                if(calculate)
                {
                    CalculateFrameUV();
                
                    if(!recalculate_v_raw) { recalculate_v_raw = true; }
                }
            }
        }
        Vec2f getImageSize()
        {
            return image_size;
        }

        private Vec2f frame_size;//The frame size of the icon. (for choosing different frames);
        void setFrameSize(Vec2f &in value, bool calculate = true)//Sets the frame size of the frame in the image.
        {
            if(frame_size != value)
            {
                frame_size = value;
                max_frames = getFramesInSize(image_size, frame_size);

                if(calculate)
                {
                    CalculateFrameUV();
                    frame_points = Nu::getFrameSizes(frame_size);
                    frame_center = (frame_points[2] - frame_points[0]) / 2;

                    if(!recalculate_v_raw) { recalculate_v_raw = true; }
                }
            }
        }
        Vec2f getFrameSize()//Gets the frame size in the image.
        {
            return frame_size;
        }
        
        private Vec2f offset;//Position of image in relation to something else. This is modified by scale. (Bug Numan if you think that's bad)
        void setOffset(Vec2f &in value)
        {
            offset = value;

            if(!recalculate_v_raw) { recalculate_v_raw = true; }
        }
        Vec2f getOffset()
        {
            return offset;
        }


        //This creates a texture and/or sets up a few things for this image to work with it.
        ImageData@ CreateImage(string &in render_name, string &in file_path)
        {
            //ensure texture for our use exists
            if(!Texture::exists(render_name))
            {
                if(!Texture::createFromFile(render_name, file_path))
                {
                    warn("texture creation failed");
                    return @null;
                }
            }
            
            return SetImage(render_name);
        }
        private ImageData@ SetImage(string &in render_name)
        {
            ImageData@ _image = Texture::data(render_name);
            if(_image == @null) { error("image was null for some reason in NuLib::NuImage::SetImage"); return @null; }
            if(_image.size() == 0) { warning("Image provided in NuLib::NuImage::SetImage was 0 in size"); return _image; }

            is_texture = true;
            image_size = Vec2f(_image.width(), _image.height());
            setFrameSize(image_size);

            return @_image;
        }
        void CreateImage(string &in render_name, ImageData@ _image)
        {
            if(_image.size() == 0) { warning("Image provided in NuLib::NuImage::CreateImage was 0 in size"); return; }

            if(!Texture::exists(render_name))
            {
                if(!Texture::createFromData(render_name, _image))
                {
                    warn("texture creation failed");
                    return;
                }
            }

            SetImage(render_name);

            return;
        }
        /*//tex returns null for some reason
        ImageData@ CreateImage(string render_name, CSprite@ s)//Takes a sprite instead.
        {
            if(Texture::exists(render_name)){ print("texture " + render_name + " already exists"); }
            if(s == @null){ Nu::Error("Sprite was equal to null"); return @null; }
            
            ImageData@ tex = @Texture::dataFromSprite(@s);//Get the sprite data.//This returns null for some reason
            if(tex == @null){ Nu::Error("ImageData@ tex was somehow null?"); return @null; }
            
            Texture::createFromData(render_name, tex);//Create a texture from it.
            return @CreateImage(render_name);//Give this menu the texture.
        }*/
        ImageData@ CreateImage(string &in render_name, CSprite@ s)//Takes a sprite instead.
        {
            if(s == @null){ Nu::Error("Sprite was equal to null"); return @null; }

            ImageData@ tex = @CreateImage(render_name, s.getFilename());//Give this menu the texture.

            setFrame(s.getFrame(), false);

            setFrameSize(Vec2f(s.getFrameWidth(), s.getFrameHeight()));

            return @tex;
        }
        ImageData@ CreateImage(string &in file_path)//Takes just a file path.
        {
            string file_name = Nu::CutOutFileName(file_path);//Cuts out the file name.
            file_name = "a_" + file_name;//a for auto is placed in the render name, in an attempt to avoid accidently using the render name somebody else is using by accident. 
            return @CreateImage(file_name, file_path);//Uses the file_name as the render_name, and the file path as is.
        }


        private array<Vec2f> frame_points;//Top left, top right, bottom left, bottom right of the frame when drawn. Stretches or squishes the frame.
        void setPointUpperLeft(Vec2f value, bool calculate = true)
        {
            frame_points[0] = value;//Top left
            frame_points[1].y = value.y;//Top right
            frame_points[3].x = value.x;//Bottom left
        
            if(calculate) { frame_center = (frame_points[2] - frame_points[0]) / 2; }
            
            if(!recalculate_v_raw) { recalculate_v_raw = true; }
        }
        void setPointLowerRight(Vec2f value, bool calculate = true)
        {
            frame_points[1].x = value.x;//Top right
            frame_points[2] = value;//Bottom right
            frame_points[3].y = value.y;//Bottom left

            if(calculate) { frame_center = (frame_points[2] - frame_points[0]) / 2; }
        
            if(!recalculate_v_raw) { recalculate_v_raw = true; }
        }
        void setFramePoints(array<Vec2f> &in _frame_points, bool calculate = true)
        {
            frame_points = _frame_points;

            if(calculate) { frame_center = (frame_points[2] - frame_points[0]) / 2; }
        
            if(!recalculate_v_raw) { recalculate_v_raw = true; }
        }

        private array<float> z;//The z level this is drawn on.
        void setZ(float value)//Set the z level. (Simplified)
        {
            for(u8 i = 0; i < z.size(); i++)
            {
                z[i] = value;
            }

            if(!recalculate_v_raw) { recalculate_v_raw = true; }
        }
        float getZ()//Get the z level. (Simplified)
        {
            return z[0];
        }

        //TODO, option to angle across the top left, or the center.
        private float angle;
        void setAngle(float value)
        {
            angle = value;

            if(!recalculate_v_raw) { recalculate_v_raw = true; }
        }
        float getAngle()
        {
            return angle;
        }

        private bool center_scale;//When this is true, this image scales from the center (expands/shrinks equally from all sides).
        //When this is false, this image scales from the top left. Thus, the top left stays to the top left. (bottom right expands/shrinks outwards)

        void setCenterScale(bool value)
        {
            center_scale = value;
            
            if(!recalculate_v_raw) { recalculate_v_raw = true; }
        }

        bool getCenterScale()
        {
            return center_scale;
        }

        private Vec2f scale;//Scale of the frame.
        void setScale(Vec2f _scale)//Sets the scale of the frame
        {
            scale = _scale;

            if(!recalculate_v_raw) { recalculate_v_raw = true; }
        }
        void setScale(float _scale)//Sets the scale of the frame.
        {
            setScale(Vec2f(_scale, _scale));
        }
        Vec2f getScale()//Gets the scale of the frame.
        {
            return scale;
        }

        bool would_crash;

        //TODO, figure out if you can render more than 4 Vertices at once.
        //If possible, make it possible to have multiple frames to be drawn at once, with their seperate positions and colors. With only one render call.
        array<Vertex> v_raw;//For rendering.



        void Render(Vec2f &in pos = Vec2f(0,0))
        {
            if(recalculate_v_raw)
            {
                CalculateVRaw();
            }

            u16 v_raw_size = v_raw.size();
            u16 i;

            for(i = 0; i < v_raw_size; i++)
            {
                v_raw[i].x += pos.x;
                v_raw[i].y += pos.y;
            }

            Render::RawQuads(name, v_raw);
        
            for(i = 0; i < v_raw_size; i++)
            {
                v_raw[i].x -= pos.x;
                v_raw[i].y -= pos.y;
            }
        }
        

    }



    shared class NuImage : NuImageLight
    {
        NuImage()
        {
            
        }

        void Setup()
        {
            NuImageLight::Setup();

        }

        //Overrides
        //
            void CalculateVRaw() override
            {
                v_raw = getVertices(would_crash, would_crash, v_raw,
                    uv_per_frame[frame], frame_points,
                    z, scale, center_scale, frame_center, offset, angle, color);
            
                if(recalculate_v_raw) { recalculate_v_raw = false; }
            }

            ImageData@ CreateImage(string &in render_name, string &in file_path) override
            {
                ImageData@ data = NuImageLight::CreateImage(render_name, file_path);

                name = render_name;

                return @data;
            }

            void setFrame(u16 _frame, bool calculate = true) override//Sets the frame
            {
                NuImageLight::setFrame(_frame, false);

                if(!recalculate_v_raw) { recalculate_v_raw = true; }
            }

            void setImageSize(Vec2f &in value, bool calculate = true) override
            {
                NuImageLight::setImageSize(value, false);

                if(calculate)
                {
                    CalculateAllFrameUV();

                    if(!recalculate_v_raw) { recalculate_v_raw = true; }
                }
            }

            void setFrameSize(Vec2f &in value, bool calculate = true) override//Sets the frame size of the frame in the image.
            {
                NuImageLight::setFrameSize(value, false);

                if(calculate)
                {
                    CalculateAllFrameUV();
                    frame_points = Nu::getFrameSizes(frame_size);
                    frame_center = (frame_points[2] - frame_points[0]) / 2;
                
                    if(!recalculate_v_raw) { recalculate_v_raw = true; }
                }
            }

            void Render(Vec2f &in pos = Vec2f(0,0)) override
            {
                if(recalculate_v_raw)
                {
                    CalculateVRaw();
                }

                u16 v_raw_size = v_raw.size();
                u16 i;

                for(i = 0; i < v_raw_size; i++)
                {
                    v_raw[i].x += pos.x;
                    v_raw[i].y += pos.y;
                }

                Render::RawQuads(name, v_raw);
            
                for(i = 0; i < v_raw_size; i++)
                {
                    v_raw[i].x -= pos.x;
                    v_raw[i].y -= pos.y;
                }
            }
        //
        //Overrides

        array<array<Vec2f>> uv_per_frame;//The uv's required for each frame in the given image.
        
        void CalculateAllFrameUV()//Calculates the UV (4 points in the image) for every frame in the image.
        {
            if(!is_texture) { return; }//Only calculate if this is/has a texture.

            array<array<Vec2f>> _uv_per_frame(Nu::getFramesInSize(image_size, frame_size));

            u16 i;
            for(i = 0; i < _uv_per_frame.size(); i++)
            {
                _uv_per_frame[i] = Nu::getUVFrame(
                image_size,//Image size
                frame_size,//Frame size
                i//Desired frame
                );
            }

            uv_per_frame = _uv_per_frame;
        }
        
    }

    //Gets vertices to be rendered.
    shared array<Vertex> getVertices(bool &in stop_if_crash, bool &out would_crash, array<Vertex> &inout v_raw,
        const array<Vec2f> &in frame_uv, array<Vec2f> &in frame_points,
        const array<f32> &in z, const Vec2f &in scale, const bool &in center_scale, const Vec2f &in frame_center, const Vec2f &in offset, const f32 &in angle, const SColor &in color = SColor(255, 255, 255, 255))
    {
        if(stop_if_crash){ return array<Vertex>(4, Vertex(0.0f, 0.0f, 0.0f, 0.0f, 0.0f)); would_crash = true; }//Already sent the error log, this could of crashed. So just stop to not spam.
        //if(!is_texture){ Nu::Error("Tried getVerticesForFrameAndPos from NuImage when it was not a texture. Did you forget to use the method CreateImage?"); return array<Vertex>(4, Vertex(0.0f, 0.0f, 0.0f, 0.0f, 0.0f)); }
        would_crash = false;
        if(frame_points.size() == 0) {          Nu::Error("frame_points.size() was equal to 0");          would_crash = true; }
        if(frame_uv.size() == 0) {          Nu::Error("frame_uv.size() was equal to 0");          would_crash = true; }
        if(would_crash){ return array<Vertex>(4, Vertex(0.0f, 0.0f, 0.0f, 0.0f, 0.0f)); }//This will crash instantly if it goes beyond this point, so exit out.

        Vec2f _offset = MultVec(offset, scale);

        Vec2f add_scale = MultVec(frame_center, Vec2f(scale.x - 1.0f, scale.y - 1.0f));

        if(!center_scale)
        {
            _offset += add_scale;
        }
        
        v_raw[0] = Vertex(_offset + 
            (frame_points[0] + (add_scale * -1)//XY
            ).RotateByDegrees(angle, frame_center), z[0], frame_uv[0], color);
        
        v_raw[1] = Vertex(_offset +
            Vec2f(frame_points[1].x + add_scale.x,//X
                frame_points[1].y + (add_scale.y * -1)//Y
            ).RotateByDegrees(angle, frame_center), z[1], frame_uv[1], color);//Set the colors yourself.
        
        v_raw[2] = Vertex(_offset +
            (frame_points[2] + add_scale//XY
            ).RotateByDegrees(angle, frame_center), z[2], frame_uv[2], color);
        
        v_raw[3] = Vertex(_offset +
            Vec2f(frame_points[3].x + (add_scale.x * -1),//X
                frame_points[3].y + add_scale.y//Y
            ).RotateByDegrees(angle, frame_center), z[3], frame_uv[3], color);
        
        return v_raw;
    }






    //TODO delete (or move) this. Could move it into NuMenu.
    shared class NuStateImage : NuImage
    {
        NuStateImage()
        {
            Setup(1);
        }
        NuStateImage(u16 state_count)
        {
            Setup(state_count);
        }

        array<u16> frame_on;//Stores what frame the image is on depending on what state this is in
        array<SColor> color_on;//Color depending on the state

        void Setup(u16 state_count)
        {
            frame_on = array<u16>(state_count, 0);
            color_on = array<SColor>(state_count, SColor(255, 255, 255, 255));
            NuImage::Setup();
        }

        //Overrides
        //
        void setFrame(u16 _frame, bool calculate = true) override//Sets the frame
        {
            setFrame(_frame, 0);
        }
        u16 getFrame() override//Sets the frame
        { 
            return getFrame(0);
        }
        void setColor(SColor _color) override//Sets the color
        {
            setColor(_color, 0);
        }
        SColor getColor() override
        {
            return getColor(0);
        }

        ImageData@ CreateImage(string &in render_name, CSprite@ s) override//Takes a sprite instead.
        {
            ImageData@ tex = NuImage::CreateImage(render_name, s);
            if(tex == @null) { return @null; }

            setDefaultFrame(s.getFrame());

            return @tex;
        }
        //
        //Overrides

        void setDefaultFrame(u16 frame)//Sets the frame for all states.
        {
            for(u16 i = 0; i < frame_on.size(); i++)
            {
                setFrame(frame, i);
            }
        }
        void setFrame(u16 _frame, u16 i)//Sets the frame
        {
            frame_on[i] = _frame;
        }
        u16 getFrame(u16 i)//Sets the frame
        {
            return frame_on[i];
        }

        void setDefaultColor(SColor color)//Sets the color for all states.
        {
            for(u16 i = 0; i < color_on.size(); i++)
            {
                setColor(color, i);
            }
        }
        void setColor(SColor _color, u16 i)//Sets the color
        {
            color_on[i] = _color;
        }
        SColor getColor(u16 i)
        {
            return color_on[i];
        }

        void Render(u16 state, Vec2f &in pos = Vec2f(0,0))
        {
            recalculate_v_raw = true;//Cheap fix, because I'm too lazy to fix something I want to remove anyway.

            frame = frame_on[state];
            color = color_on[state];

            Render(pos);
        }

        void Render(Vec2f &in pos = Vec2f(0,0)) override
        {
            NuImage::Render(pos);
        }
    }

}

//Generally for functions that require constant ticking/rendering or require to be sent to client or server from client or server.
namespace NuLib
{
    //TODO remove every player array if they are 1. Allowed to respawn(not waiting to respawn anymore). 2. Left the server.
    array<u32> respawn_times;
    array<int> player_times;//Corresponds with respawn_times. Holds player usernames hashed.
    array<CPlayer@> player_times_player;
    const u8 SAFE_TIME = 2;//Amount of time it takes to be "safe" for the player to do things like spawn. Spawning straight away makes kag unhappy.
    u16 getPlayerTimesIndex(CPlayer@ player)
    {
        if(!isServer()) { Nu::Error("This function is server only"); return 0; }
        int name_hash = player.getUsername().getHash();

        u16 i;

        bool exists = false;

        for(i = 0; i < player_times.size(); i++)
        {
            if(@player == @player_times_player[i]) { exists = true; break; }
        }

        if(exists){
            return i;
        }
        else{
            return Nu::u16_max();
        }
    }

    void onInit(CRules@ rules)
    {
        if(!rules.hasCommandID("clientmessage")){ rules.addCommandID("clientmessage"); }//Just for testing purposes
        rules.addCommandID("clienttoclient");
        rules.addCommandID("teleport");
        rules.addCommandID("enginemessage");
        rules.addCommandID("announcement");
        rules.addCommandID("switchfrominventory");
        rules.addCommandID("nunextmap");

        if(isServer())
        {
            respawn_times = array<u32>();
            player_times = array<int>();
            player_times_player = array<CPlayer@>();
        }
    }

    void onRestart(CRules@ rules)
    {
        rules.set_u32("announcementtime", 0);

        if(isServer())
        {
            for(u16 i = 0; i < player_times.size(); i++)//For every player_times
            {
                if(player_times_player == @null)//If the player left
                {
                    //Rid of their arrays
                    respawn_times.removeAt(i);
                    player_times_player.removeAt(i);
                    player_times.removeAt(i);
                }
                else//Player didn't leave?
                {
                    //Default some of their arrays.
                    respawn_times[i] = getGameTime() + SAFE_TIME;
                }
            }
        }
    }

    void onTick(CRules@ rules)
    {
        if(isServer())
        {
            u16 i;
            if(rules.get_u16("nu_respawn_time") != 0)
            {
                for(i = 0; i < player_times.size(); i++)//For every player's respawn time
                {
                    if(respawn_times[i] == getGameTime())//If it is time for them to respawn
                    {
                        if(player_times_player[i] == @null) { continue; }//If the player left, just let them respawn when they rejoin.

                        Nu::RespawnPlayer(rules, player_times_player[i]);
                    }
                }
            }
        }
    }
    
    void onNewPlayerJoin(CRules@ rules, CPlayer@ player)
    {
        if(isServer())
        {
            if(player == @null) { Nu::Error("player was null"); return; }
            
            u16 player_index = getPlayerTimesIndex(player);
            if(player_index == Nu::u16_max())//Player doesn't exist?
            {
                respawn_times.push_back(getGameTime() + SAFE_TIME);//Tick or two to respawn to prevent annoying bugs.
                player_times.push_back(player.getUsername().getHash());
                player_times_player.push_back(@player);
            }
            else//player_index still exists
            {
                @player_times_player[player_index] = @player;//Reset player
                
                //if(respawn_times[player_index] + SAFE_TIME >= getGameTime())
                if(respawn_times[player_index] <= getGameTime())//This player is allowed to respawn?
                {
                    respawn_times[player_index] = getGameTime();//Allow player to respawn
                }
                if(respawn_times[player_index] <= getGameTime() + SAFE_TIME)//If player is allowed to respawn within SAFE_TIME. (as in, player respawning very soon)
                {
                    respawn_times[player_index] += SAFE_TIME;//Make sure it is safe. Tick or two wait before spawning, so kag doesn't complain.
                }
            }
        }
    }
    void onPlayerLeave( CRules@ rules, CPlayer@ player )
    {
        if(isServer())
        {
            u16 player_index = getPlayerTimesIndex(player);
            if(player_index != Nu::u16_max())//Make sure the player exists just in case
            {
                @player_times_player[player_index] = @null;//Remove player
            }

            if(getPlayerCount() == 1)//Last player disconnect?
            {
                if(rules.get_bool("restartmap_onlastplayer_disconnect"))//Restart the map when the last player disconnects?
                {
                    print("LAST PLAYER DISCONNECT. RESTARTING MAP");
                    LoadMap(getMap().getMapName());
                }
            }
        }
    }

    void onPlayerDie( CRules@ rules, CPlayer@ victim, CPlayer@ attacker, u8 customData )//Calls when the player's blob dies
    {
        if(isServer())
        {
            u16 respawn_time = rules.get_u16("nu_respawn_time");

            if(respawn_time != 0)
            {
                if(victim == @null) { Nu::Error("victim was null"); return; }

                if(respawn_time < SAFE_TIME) { respawn_time = SAFE_TIME; rules.set_u16("nu_respawn_time", respawn_time); }

                respawn_times[getPlayerTimesIndex(victim)] = getGameTime() + respawn_time;
            }
        }
    }

    void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
    {
        if(cmd == rules.getCommandID("clienttoclient"))
        {
            if(!isServer()) { return; }
            u8 command_id;
            if(!params.saferead_u8(command_id)) { Nu::Error("clienttoclient failed to saferead command_id"); return; }
            u16 player_id;
            if(!params.saferead_u16(player_id)) { Nu::Error("clienttoclient failed to saferead player_id"); return; }
            CBitStream _params;
            if(!params.saferead_CBitStream(_params)) { Nu::Error("clienttoclient failed to read CBitStream"); return; }

            CPlayer@ player = getPlayerByNetworkId(player_id);
            if(player != @null)
            {
                rules.SendCommand(command_id, _params, player);
            }
        }
        else if(cmd == rules.getCommandID("switchfrominventory"))
        {
            if(!isServer()) { return; }

            bool inventorise_held;
            u16 blob_id;
            u16 getblob_id;

            if(!params.saferead_bool(inventorise_held)) { Nu::Error("bool get was null"); return; }
            if(!params.saferead_u16(blob_id)) { Nu::Error("ID get was null"); return; }
            if(!params.saferead_u16(getblob_id)) { Nu::Error("ID get was null"); return; }

            CBlob@ pblob = getBlobByNetworkID(blob_id);
            if(pblob == @null) { return; }

            CInventory@ inv = pblob.getInventory();
            if(inv == @null) { return; }

            CBlob@ getblob = getBlobByNetworkID(getblob_id);
            if(getblob == @null) { return; }

            CBlob@ carried_blob = pblob.getCarriedBlob();

            if(!inv.isInInventory(getblob) && @getblob != @carried_blob) { return; }//If getblob is not in pblob's inventory or being held by pblob
            
            if(carried_blob != @null)
            {
                if(inventorise_held)//Supposed to put the currently held item in the inventory?
                {
                    if(!inv.canPutItem(carried_blob))//If it can't be put in the inventory
                    {
                        return;//CEASE
                    }
                    else//It is possible?
                    {
                        if(!pblob.server_PutInInventory(carried_blob)) { Nu::Error("Failed to put blob in inventory."); return; }//Put it in
                    }
                    
                    //if(carried_blob.getName() == getblob.getName())//If the getblob is the same type as the carried_blob
                    if(@carried_blob == @getblob)//If the getblob is the exact same blob
                    {
                        return;//Do nothing more.
                    }
                }
                else//No inventorizing
                {
                    pblob.DropCarried();//Just drop it
                }
            }
            //From this point onwards, pblob is no longer holding a blob. 

            
            if(!pblob.server_PutOutInventory(getblob)) { Nu::Error("Failed to put blob out inventory."); return; }//Take it out

            if(!pblob.server_Pickup(getblob)) { Nu::Error("Failed to pickup blob taken out of inventory."); return; }//Pick it up

            //Mission success
        }
        else if(cmd == rules.getCommandID("clientmessage") )//sends message to a specified client
        {
            if(!isClient()) { return; }

            bool to_console = params.read_bool();
            string text = params.read_string();
            u8 alpha = params.read_u8();
            u8 red = params.read_u8();
            u8 green = params.read_u8();
            u8 blue = params.read_u8();

            if(to_console)
            {
                print(text, SColor(alpha, red, green, blue));
            }
            else
            {
                client_AddToChat(text, SColor(alpha, red, green, blue));//Color of the text
            }
        }
        else if(cmd == rules.getCommandID("teleport") )//teleports player to position
        {
            CPlayer@ target_player = getPlayerByNetworkId(params.read_u16());//Player 1
            
            if(target_player == @null) { return; }

            CBlob@ target_blob = target_player.getBlob();
            if(target_blob != @null)
            {
                Vec2f pos = params.read_Vec2f();
                target_blob.setPosition(pos);
                ParticleZombieLightning(pos);
            }	
        }
        else if(cmd == rules.getCommandID("enginemessage") )
        {
            if(!isClient()) { return; }
            string text = params.read_string();
            EngineMessage(text);
        }
        else if(cmd == rules.getCommandID("announcement"))
        {
            rules.set_string("announcement", params.read_string());
            rules.set_u32("announcementtime",30 * 15 + getGameTime());//15 seconds
        }
        else if(cmd == rules.getCommandID("nunextmap"))
        {
            string map_name = params.read_string();
            if(map_name == " ")
            {
                LoadNextMap();
            }
            else
            {
                LoadMap(map_name);
            }
        }
    }


    void onRender(CRules@ rules)
    {
        GUI::SetFont("menu");

        CPlayer@ localplayer = getLocalPlayer();
        if(localplayer == @null)
        {
            return;
        }

        if(rules.get_u32("announcementtime") > getGameTime())
        {
            GUI::DrawTextCentered(rules.get_string("announcement"), Vec2f(getScreenWidth()/2,getScreenHeight()/2), SColor(255,255,127,60));
        }
    }

}









//TODO
/*

Only render things from NuImage if the NuImage is on screen? Look into this.



//IDEAS

/*
Numan_library. Including 
1. Is any key pressed (can input blob or CControls) Is any mouse button pressed. etc.
2. Input an array of control enums to check if any are pressed.
4. Is string a 0 or 1 (outputs bool if is not a 0 or 1). takes in a referenced bool, changes it to true or falsed based on the inputted string
5. Put string array into one big string.
6. Easy on command method/function. Make it possible to send around things via methods and without using onCommand stuff. only CBitStream.
7. Easy way to display contents of array. Make a bunch of methods for each datatype, printing all of them out.
8. Get all players in array, arrange from closest to furthest (only if they have blobs). (CommandChat.as)
8.5 Sort an array of blobs by distance. Include optional team parameter (CommandChat.as)
8.75 Sort array of Vectors
9. Enum array of every KEY_CODE
10. Is block above? check every block above and check if it is the requested one. return true or false.
11. Is block below? 
12. Is block left?
13. Is block right?(maybe merge into one with a directional parameter)
#17. Get player associated with id.
#18. Time since map loaded.
#19. Get blocks in radius. (blocky radius, jagged array of blocks)
#20. Get if there are blocks between two given points. optional "give" value that effectively shrinks the size of all the blocks corners. (it's a quality of life thing)
#21. Get quantity of items in inventory. (say you have 250 wood and 125 wood. It gets them all and adds them together.)
#22. Get spawn locations for specified team.
#23. Transfer over health, items, position between two blobs. Return the new blob. Give option for both name of blob, and CBlob. Also can give CPlayer provided you want that automatically changed.
#24. Angle difference.
#25. Apply force in direction. this.AddForce(Vec2f(this.isFacingLeft() ? -velocity * Maths::Sin(angle) : velocity * Maths::Cos(angle), this.isFacingLeft() ? -velocity * Maths::Cos(angle) : velocity * Maths::Sin(angle))); Would this work?
#27. How much of this blob does the inventory have.
#28. PatchAllBlobs("ScriptName", remove_script = false);//Adds a script to all blobs currently existing, and all future blobs on their creation. if remove_script is true the script with the specified name is instead removed. If it's there.
#29. PatchBlobs("BlobName", "ScriptName", remove_script = false);//Same as above but only for blobs with the specified name
#30. Function to get pi 3.14. Because pie is yummy.
#31. Does gamemode exist? Run a check for if a gamemode exists, without changing the gamemode.
#32. Serialize and DeSerialize ImageData to CBitStream.

DrawTextWithWidth(string text, Vec2f pos, SColor color, float width) - Caps width, note this will require an array to save draw text stuff as the calculations should not be done every render call.








*/