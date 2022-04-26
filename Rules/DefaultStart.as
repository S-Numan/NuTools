//In autoconfig.cfg, set sv_contact_info = 0 to disable custom gamemode loading.

void RunServer()
{
   
	if (getNet().CreateServer())
	{
        if(sv_contact_info == "0")
        {
            LoadRules("Rules/" + sv_gamemode + "/gamemode.cfg");
            CRules@ rules = getRules();
            if(@rules == @null)
            {
                error("Rules failed to load."); return;
            }
        }
        else
        {
            LoadRules("Rules/" + "DummyGamemode.cfg");//Load dummy gamemode before loading the rules the new way.

            CRules@ rules = getRules();
            if(@rules == @null)
            {
                error("Dummy Rules failed to load"); return;
            }

            rules.RemoveScript("DummyScript.as");//Remove the dummyscript to confirm stuff works. If the print file in this is running, something went wrong.
            
            rules.AddScript("DummyServerCommand.as");

            AddGamemode(rules, sv_gamemode);
        
            rules.set_bool("custom_gamemode_loading", true);
        }
        
        if (sv_mapcycle.size() > 0)
		{
			LoadMapCycle(sv_mapcycle);
		}
		else
		{
			LoadMapCycle("Rules/" + sv_gamemode + "/mapcycle.cfg");
		}

		LoadNextMap();
	}
}

shared void AddGamemode(CRules@ rules, string the_gamemode)
{
    u16 i;
    string gamemode_path = FindGamemode(the_gamemode);



    print("gamemode_path = " + gamemode_path);


    ConfigFile@ cfg = ConfigFile();
    if(!cfg.loadFile(gamemode_path)) { error("Failed to load gamemode"); return; }
    if(!cfg.exists("gamemode_name")) { error("gamemode_path was not a gamemode file"); return; }

    if(cfg.exists("gamemode_name")){
        rules.gamemode_name = cfg.read_string("gamemode_name");
    }
    if(cfg.exists("gamemode_info")){
        rules.gamemode_info = cfg.read_string("gamemode_info");
    }
    if(cfg.exists("daycycle_speed")){
        rules.daycycle_speed = cfg.read_u16("daycycle_speed");
    }
    if(cfg.exists("daycycle_start")){
        rules.daycycle_start = cfg.read_f32("daycycle_start");
    }
    if(cfg.exists("autoassign_teams")){
        rules.autoassign_teams = cfg.read_bool("autoassign_teams");
    }
    if(cfg.exists("attackdamage_modifier")){
        rules.attackdamage_modifier = cfg.read_f32("attackdamage_modifier");
    }
    if(cfg.exists("friendlydamage_modifier")){
        rules.friendlydamage_modifier = cfg.read_f32("friendlydamage_modifier");
    }
    if(cfg.exists("respawn_as_last_blob")){
        rules.set_bool("respawn_as_last_blob", cfg.read_bool("respawn_as_last_blob"));
    } else { rules.set_bool("respawn_as_last_blob", true); }//Default
    
    if(cfg.exists("default_class")){
        rules.set_string("default class", cfg.read_string("default_class"));
    } else { rules.set_string("default class", "knight"); }//Default
    
    if(cfg.exists("respawn_time")){
        rules.set_u16("nu_respawn_time", cfg.read_u16("respawn_time"));
    } else { rules.set_u16("nu_respawn_time", 0); }//Default



       
    

    array<string> existing_script_array;
    if(!rules.get("script_array", existing_script_array))//Try to get an existing script array.
    {//Existing script array doesn't exist?
        existing_script_array = array<string>();//Init this array with nothing
    }

    array<string> gamemode_script_array;//gamemode script array.
    cfg.readIntoArray_string(gamemode_script_array, "scripts");
    if(gamemode_script_array.size() == 0) { warning("gamemode contained no scripts"); }

    for(i = 0; i < existing_script_array.size(); i++)//For every script in the existing script array
    {
        int script_hash = existing_script_array[i].getHash();
        for(u16 q = 0; q < gamemode_script_array.size(); q++)//For every script in the gamemode array.
        {
            if(script_hash == gamemode_script_array[q].getHash())//If the gamemode_script_array contains a script that the existing_script_array already has.
            {
                gamemode_script_array.removeAt(q);//Remove it
                break;//No need to further check
            }
        }
    }

    array<string> script_array = array<string>(existing_script_array.size() + gamemode_script_array.size());//Script array to be added to rules.
    u16 current_pos = 0;

    //Add both arrays into script_array

    for(i = 0; i < existing_script_array.size(); i++)
    {
        script_array[current_pos] = existing_script_array[i];
        current_pos++;
    }
    for(i = 0; i < gamemode_script_array.size(); i++)
    {
        script_array[current_pos] = gamemode_script_array[i];
        current_pos++;
    }


    for(i = existing_script_array.size(); i < script_array.size(); i++)//Don't need to re-add existing scripts
    {
        //print("script " + i + " = " + script_array[i]);
        
        if(!CFileMatcher(script_array[i]).hasMatch())
        {
            //If the script failed to add.
            error("script " + script_array[i] + " failed to find a match");
            script_array.removeAt(i);//Remove it from the array
            i--;//Go back one
            continue;//Do over with the next script
        }

        rules.AddScript(script_array[i]);//Add script to rules
        
        //if(!rules.hasScript(script_array[i]))//Doesn't work without waiting a tick. CFileMatcher is replacing it.
    }
    
    rules.set("script_array", script_array);
    //for(i = 0; i < script_array.size(); i++)
    //{
    //    print("script array " + i + " is " + script_array[i]);
    //}

    rules.set_string("gamemode_path", gamemode_path);
}

//Returns the file path to the gamemode.
shared string FindGamemode(string the_gamemode)
{
    string gamemode_path;

    ConfigFile@ cfg = ConfigFile();
    
    CFileMatcher@ files = CFileMatcher(the_gamemode + ".cfg");
    if(files.hasMatch())
    {
        //files.printMatches();
        
        u32 q = 0;
        while (files.iterating())//For every match found
        {
            if(q > 0) { warning("More than one match when finding gamemode. Defaulting to first found."); break; }

            string current_gamemode_path = files.getCurrent();

            @cfg = @ConfigFile();
            if(!cfg.loadFile(current_gamemode_path))//Attempt to find and load the gamemode.
            {
                //warning("failed to load file");
                continue;
            }
            if(!cfg.exists("gamemode_name"))//Check to make sure this is a gamemode file, and not something else.
            {
                //warning("file is not a gamemode file");
                continue;
            }

            gamemode_path = current_gamemode_path;//The gamemode has been successfully found.
            
            q++;
        }
    }
    if(gamemode_path == "")
    {
        //Search every gamemode.cfg file for their gamemode_name, and compare it to the_gamemode. If they are the same, the gamemode has been found. 

        //warning("search file by file for correct name gamemode path finding");

        @files = @CFileMatcher("gamemode.cfg");
        if(!files.hasMatch())
        {
            error("what? no gamemode.cfg files anywhere?");
        }

        //files.printMatches();
        
        while (files.iterating())//For every match found
        {
            string current_gamemode_path = files.getCurrent();
            
            @cfg = @ConfigFile();
            if(!cfg.loadFile(current_gamemode_path))//Attempt to find and load the gamemode.
            {
                warning("failed to load file");
                continue;
            }
            if(!cfg.exists("gamemode_name"))//Check to make sure this is a gamemode file, and not something else.
            {
                warning("file is not a gamemode file");
                continue;
            }
            //print("get current = " + current_gamemode_path);
            //print("gamemode name = " + cfg.read_string("gamemode_name") + " compared against = " + the_gamemode);
            if(cfg.read_string("gamemode_name") == the_gamemode)//If the gamemode name is the same as the_gamemode
            {
                gamemode_path = current_gamemode_path;//Match has been found
                break;
            }
        }
        if(gamemode_path == "")//Still failed to find the gamemode?
        {
            error("Failed to find gamemode \"" + the_gamemode + "\". Defaulting to vanilla gamemode finding. Note that any modded gamemode.cfg will replace all vanilla gamemode.cfg's");
            gamemode_path = CFileMatcher("Rules/" + the_gamemode + "/gamemode.cfg").getFirst();
        }
    }

    return gamemode_path;
}

void ConnectLocalhost()
{
	getNet().Connect("localhost", sv_port);
}

void RunLocalhost()
{
	RunServer();
	ConnectLocalhost();
}

void LoadDefaultMenuMusic()
{
	if (s_menumusic)
	{
		CMixer@ mixer = getMixer();
		if (mixer !is null)
		{
			mixer.ResetMixer();
			mixer.AddTrack("Sounds/Music/world_intro.ogg", 0);
			mixer.PlayRandom(0);
		}
	}
}
