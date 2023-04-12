
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

    

    shared u8 getInt(bool value)
    {
        if(value){ return 1; }
        return 0;
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

    //See IsNumeric
    shared bool IsNumericNoDots(string _string)
    {
        for(uint i = 0; i < _string.size(); i++)
        {
            if(_string[i] < "0"[0] || _string[i] > "9"[0])
            {
                return false;
            }
        }

        return true;
    }

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