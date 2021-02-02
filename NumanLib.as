//V1.1
namespace Nu
{

    //Returns every player in the server in an array.
    array<CPlayer@> getPlayers()
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
    array<CPlayer@> getPlayersInTeam(u8 team)
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
    u16 getTeamCount(u8 team)
    {
        u16 i, team_players;//Init vars.

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
    array<CBlob@> getPlayerBlobs()
    {
        array<CBlob@> player_blobs(getPlayerCount());

        for(u16 i = 0; i < getPlayerCount(); i++)//For every player
        {
            @player_blobs[i] = @getPlayer(i).getBlob();//Put their blob into the array (even if it is null)
        }

        return player_blobs;//Return the player blobs.
    }

    //1: Input string.
    //Returns true, if that string has only digits 1-9. Returns false if it has something else (spaces aren't digits).
    bool IsNumeric(string _string)
    {
        for(uint i = 0; i < _string.size(); i++)
        {    
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
    bool getBool(string input_string, bool &out bool_value)
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
    array<CPlayer@> getPlayersByShortUsername(string shortname)
    {
        array<CPlayer@> playersout();//The main array for storing all the players which contain shortname

        for(int i = 0; i < getPlayerCount(); i++)//For every player
        {
            CPlayer@ player = getPlayer(i);//Grab the player
            if(player == null)//If the player doesn't exist for whatever reason.
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
    CPlayer@ getPlayerByShortUsername(string shortname)
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
        else if(target_players == null || target_players.size() == 0)
        {
            print("No player was found for the player param.");
            return @null;
        }
        return target_players[0];
    }


    //Parameters
    //1: A point.
    //2: The radius around that point to get the blobs from. Any player blobs outside the radius will not be put in the array.
    //3: If this array should skip both blobs in inventories, and unactive blobs. This is by default true.
    //Returns an array of all players sorted by distance. Players without blobs are not included in this array.
    array<CPlayer@> SortPlayersByDistance(Vec2f point, f32 radius, bool skip_unactive_and_inventory = true)
    {
        u16 i;

        u16 non_null_count = 0;
        
        array<CBlob@> playerblobs(getPlayerCount());

        //Put all blobs in playerblobs array
        for(i = 0; i < playerblobs.size(); i++)
        {
            CPlayer@ player = getPlayer(i);
            if(player != null)
            {
                CBlob@ player_blob = player.getBlob();
                
                if(player_blob != null//If the player has a blob. 
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
    array<CBlob@> SortBlobsByDistance(Vec2f point, f32 radius, array<CBlob@> blob_array, bool skip_unactive_and_inventory = false)
    {
        u16 i, j;

        array<CBlob@> sorted_array(blob_array.size());

        array<f32> blob_dist(blob_array.size());

        u16 non_null_count = 0;

        for (i = 0; i < blob_array.size(); i++)//Make an array that contains the distance that each blob is from the point.
        {
            if(blob_array[i] == null//If the blob does not exist
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
    bool isPointInRadius(Vec2f point, Vec2f radius_center, float radius)
    {
        if((point.x - radius_center.x)^2 + (point.y - radius_center.y)^2 < radius^2)
        {
            return true;
        }

        return false;
    }

    //1: Value to be rounded.
    //2: Multiple to be rounded by.
    //Rounds by the given multiple. If the multiple is 5 and the value is 277, this will return 275. If the multiple is 10 and the value is 277, this would return 280. 
    float RoundByMultiple(float value, float multiple = 10.0f)
    {
        return Maths::Roundf(value / multiple * multiple);
    }
    int RoundByMultiple(int value, int multiple = 10)//Same as above but for ints.
    {
        return Maths::Round(value / multiple * multiple);
    }
    //Same as above except instead of rounding up, it always rounds down.
    float RoundDown(float value, float multiple = 10.0f)
    {
        return value - value % multiple;
    }
    int RoundDown(int value, int multiple = 10)//For ints
    {
        return value - value % multiple;
    }
    float Floor(float value, float multiple = 10.0f)//Alias
    {
        return value - value % multiple;
    }
    int Floor(int value, int multiple = 10)//Alias for ints
    {
        return value - value % multiple;    
    }
    
    //1: Point to get the tile under.
    //Returns the top of the tile under the point.
    f32 getTileUnderPos(Vec2f pos)
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
    enum POSPositions//Stores all positions that stuff can be in.
    {
        POSTopLeft,//top left
        POSTopRight,//top right
        POSBottomLeft,//bottom left
        POSBottomRight,//bottom right
        POSCenter,//in the center of the menu
        POSTop,//positioned on the top of the menu
        POSAbove,//above the top of the menu
        POSBottom,//on the bottom of the menu
        POSUnder,//under the bottom of the menu
        POSLeft,//on the left of the menu
        POSLefter,//left of the left side of the menu
        POSRight,//to the right of the menu
        POSRighter,//right of the right side of the menu

        POSPositionsCount,//Always last, this specifies the amount of positions.
    }

    //1: Enum position you want the point to be on.
    //2: Size of the thing you want the point to be on. Very important.
    //3: The position you desire.
    //4: Optional buffer. For example if you specify POSBottom and make the buffer 2.0f, it will push the position up by 2.
    //Returns false if the inserted position enum was not found. Insert an enum for a position based on given size. This will then give you that position in the size plus buffer.
    bool getPosOnSize(u16 position, Vec2f size, Vec2f &out vec_pos, float buffer = 0.0f)
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
    bool getPosOnSizeFull(u16 position, Vec2f size, Vec2f dimensions, Vec2f &out pos, float buffer = 0.0f)
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
    u16 getFramesInSize(Vec2f image_size, Vec2f frame_size)
    {
        Vec2f output;

        output.x = image_size.x / frame_size.x;
        output.y = image_size.y / frame_size.y;
    
        return u16(output.x * output.y);
    }

    //1: The size of the image.
    //2: The size of the frame in the image
    //3: The frame you want in the image.
    //Returns the Vector of where the desired frame starts. (top left)
    Vec2f getFrameStart(Vec2f image_size, Vec2f frame_size, u16 desired_frame)
    {
        Vec2f frame_start = Vec2f(0,0);

        frame_start.x = frame_size.x * desired_frame % image_size.x;

        frame_start.y = int(frame_size.x * desired_frame / image_size.x) * frame_size.y;

        return frame_start;
    }

    //1: Where the frame starts
    //2: How big the frame is
    //3: Returns the end of a frame. (bottom right)
    Vec2f getFrameEnd(Vec2f frame_start, Vec2f frame_size)
    {
        Vec2f frame_end = frame_start + frame_size;

        return frame_end;
    }

    //1: The size of the image.
    //2: The size of the frame in the image
    //3: The frame you want in the image.
    //Returns an array of the four positions. Now in UV style! Buy now for only 19.99$ free shipping and handling.
    array<Vec2f> getUVFrame(Vec2f image_size, Vec2f frame_size, u16 desired_frame)
    {
        Vec2f frame_start = getFrameStart(image_size, frame_size, desired_frame);
        Vec2f frame_end = getFrameEnd(frame_start, frame_size);

        return getUVFrame(image_size, frame_start, frame_end);
    }
    //Same as above, but less user friendly. Set the frame start and end here instead of frame_size and desired frame.
    array<Vec2f> getUVFrame(Vec2f image_size, Vec2f frame_start, Vec2f frame_end)
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
    array<Vec2f> getFrameSizes(Vec2f frame_size, Vec2f add_to = Vec2f(0,0))
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
    Vec2f MultVec(Vec2f value1, Vec2f value2)
    {
        value1.x = value1.x * value2.x;
        value1.y = value1.y * value2.y;
        return value1;
    }
    






































    class NuImage
    {
        NuImage()
        {
            Setup();
        }
        NuImage(u16 state_count)
        {
            Setup(state_count);
        }

        void Setup(u16 state_count = 1)
        {
            name = "";
            name_id = 0;
            frame_on = array<u16>(state_count, 0);
            color_on = array<SColor>(state_count, SColor(255, 255, 255, 255));
            Vec2f offset = Vec2f(0,0);

            is_texture = false;
            v_raw = array<Vertex>(4);
            frame_points = array<Vec2f>(4);
            z = array<float>(4, 0.0f);
            scale = Vec2f(1.0f, 1.0f);
            auto_frame_points = true;
        }

        void setDefaultFrame(u16 frame)//Sets the regular frame for all states.
        {
            for(u16 i = 0; i < frame_on.size(); i++)
            {
                frame_on[i] = frame;
            }
        }

        void setDefaultColor(SColor color)//Sets the regular color for all states.
        {
            for(u16 i = 0; i < color_on.size(); i++)
            {
                color_on[i] = color;
            }
        }

                            //  JustHover state Hover state Just Pressed  Pressed state--OnHoverFrame|OnPressFrame    
        void setFourTwoFrames(u16 just_hover, u16 hover, u16 just_pressed, u16 pressed, u16 on_hover, u16 on_press)//In NuMenuCommon this is used to set frames for hover and press states easily.
        {
            frame_on[just_hover] = on_hover;
            frame_on[hover] = on_hover;
            frame_on[just_pressed] = on_press;
            frame_on[pressed] = on_press;
        }
        u16 name_id;//Used for keeping track of what image is what image. For when using several NuImages in one array for example. Loop through the array and compare enums to this.
        //Todo - replace name_id with a string name and hash?

        bool is_texture;//Sets if this is a texture. If this is false, this is not a texture.
        
        string name;//Either file name, or texture name.

        private Vec2f image_size;//Size of the image given.
        void setImageSize(Vec2f value, bool calculate = true)
        {
            if(image_size != value)
            {
                image_size = value;
                if(calculate && is_texture)
                {
                    RecalculateUV();
                }
            }
        }
        Vec2f getImageSize()
        {
            return image_size;
        }

        private Vec2f frame_size;//The frame size of the icon. (for choosing different frames);
        void setFrameSize(Vec2f value, bool calculate = true)//Sets the frame size of the frame in the image.
        {
            if(frame_size != value)
            {
                frame_size = value;
                if(calculate && is_texture)
                {
                    RecalculateUV();
                    if(auto_frame_points){
                    setDefaultPoints();
                    }
                }
            }
        }
        Vec2f getFrameSize()//Gets the frame size in the image.
        {
            return frame_size;
        }
        

        array<u16> frame_on;//Stores what frame the image is on depending on what state this is in
        array<SColor> color_on;//Color depending on the state
        Vec2f offset;//Position of image in relation to something else.


        //
        //Below goes into rendering
        //

        //Todo, createimage from sprite.

        //This creates a texture and/or sets up a few things for this image to work with it.
        ImageData@ CreateImage(string render_name, string file_path = "")
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

            ImageData@ _image = Texture::data(render_name);
            if(_image == null) { error("image was null for some reason in NumanLib::NuImage::CreateImage"); return @null; }
            if(_image.size() == 0) { warning("Image provided in NumanLib::NuImage::CreateImage was 0 in size"); return _image; }

            image_size = Vec2f(_image.width(), _image.height());
            frame_size = image_size;
            RecalculateUV();
            if(auto_frame_points){
                setDefaultPoints();
            }
            name = render_name;
            is_texture = true;

            return _image;
        }
        void CreateImage(string render_name, CSprite@ s)//Takes a sprite instead.
        {
            ImageData@ tex = Texture::dataFromSprite(s);//Get the sprite data.
            Texture::createFromData(render_name, tex);//Create a texture from it.
            CreateImage(render_name);//Give this menu the texture.
        }


        bool auto_frame_points;//This, when true, automatically changes frame_points to the accurate points of the frame. This being false allows you to scale the frame however you like.
        
        array<Vec2f> frame_points;//Top left, top right, bottom left, bottom right of the frame when drawn. Stretches or squishes the frame.
        void setPointUpperLeft(Vec2f value)
        {
            frame_points[0] = value;//Top left
            frame_points[1].y = value.y;//Top right
            frame_points[3].x = value.x;//Bottom left

            auto_frame_points = false;
        }
        void setPointLowerRight(Vec2f value)
        {
            frame_points[1].x = value.x;//Top right
            frame_points[2] = value;//Bottom right
            frame_points[3].y = value.y;//Bottom left
        
            auto_frame_points = false;
        }
        void setDefaultPoints()//Sets the correct points taking into factor frame size. Keeps the size of the drawn thing non modified. (ignoring scale)
        {
            frame_points = Nu::getFrameSizes(
                MultVec(frame_size, scale)//Frame size
            );
        }

        array<array<Vec2f>> uv_per_frame;//The uv's required for each frame in the given image.
        
        void RecalculateUV()//Recalculates UV. Basically sets up all four points of each frame in the image and puts it all into one big array. Fancy stuff, don't touch it if you don't know what it does. I hardly know what it does.
        {
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

        array<float> z;//The z level this is drawn on.
        void setZ(float value)//Set the z level. (Simplified)
        {
            for(u8 i = 0; i < z.size(); i++)
            {
                z[i] = value;
            }
        }
        float getZ()//Get the z level. (Simplified)
        {
            return z[0];
        }


        private Vec2f scale;//Scale of the frame.
        void setScale(Vec2f _scale)//Sets the scale of the frame.
        {
            scale = _scale;
            if(auto_frame_points){
                setDefaultPoints();
            }
        }
        void setScale(float _scale)//Sets the scale of the frame.
        {
            setScale(Vec2f(_scale, _scale));
        }
        Vec2f getScale()//Gets the scale of the frame.
        {
            return scale;
        }

        //TODO, don't run this every render call. Only recalculate if needed.
        array<Vertex> v_raw;//For rendering.
        array<Vertex> getVertexsForFrameAndPos(u16 frame, Vec2f _pos = Vec2f(0,0), u16 state = 0)//Gets what this should render.
        {
            if(!is_texture){ error("Tried getVertexsForFrameAndPos from NuImage when it was not a texture. Did you forget to use the method CreateImage?"); return array<Vertex>(4, Vertex(0.0f, 0.0f, 0.0f, 0.0f, 0.0f)); }
            if(frame_points.size() == 0 || uv_per_frame.size() == 0 || uv_per_frame[frame].size() == 0) { error("Instant crash prevention in NumanLib.as"); return array<Vertex>(4, Vertex(0.0f, 0.0f, 0.0f, 0.0f, 0.0f)); }

            Vec2f _offset = MultVec(offset, scale);

            v_raw[0] = Vertex(_offset + _pos + frame_points[0], z[0], uv_per_frame[frame][0], color_on[state]);
			v_raw[1] = Vertex(_offset + _pos + frame_points[1], z[1], uv_per_frame[frame][1], color_on[state]);//Set the colors yourself.
			v_raw[2] = Vertex(_offset + _pos + frame_points[2], z[2], uv_per_frame[frame][2], color_on[state]);
			v_raw[3] = Vertex(_offset + _pos + frame_points[3], z[3], uv_per_frame[frame][3], color_on[state]);
            return v_raw;
        }



        void Render(u16 frame = -1, Vec2f _pos = Vec2f(0,0), u16 state = 0)
        {
            if(frame == -1)
            {
                frame = frame_on[state];
            }
            Render::RawQuads(name, getVertexsForFrameAndPos(frame, _pos, state));
        }
        

    }

}

//TODO
/*

Allow NuImage to be rotated. See frame_points. Take each vector and apply a rotation on them. GL



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
#14. Send chat message to player (CommandChat.as)
#15. Send chat message to all players 
#17. Get player associated with id.
#18. Time since map loaded.
#19. Get blocks in radius. (blocky radius, jagged array of blocks)
#20. Get if there are blocks between two given points. optional "give" value that effectively shrinks the size of all the blocks corners. (it's a quality of life thing)
#21. Get quantity of items in inventory. (say you have 250 wood and 125 wood. It gets them all and adds them together.)
#22. Get spawn locations for specified team.
#23. Transfer over health, items, position between two blobs. Return the new blob. Give option for both name of blob, and CBlob. Also can give CPlayer provided you want that automatically changed.
#24. Angle difference.
#25. Apply force in direction. this.AddForce(Vec2f(this.isFacingLeft() ? -velocity * Maths::Sin(angle) : velocity * Maths::Cos(angle), this.isFacingLeft() ? -velocity * Maths::Cos(angle) : velocity * Maths::Sin(angle))); Would this work?


DrawTextWithWidth(string text, Vec2f pos, SColor color, float width) - Caps width, note this will require an array to save draw text stuff as the calculations should not be done every render call.








*/