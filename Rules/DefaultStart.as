

void RunServer()
{
	if (getNet().CreateServer())
	{

        LoadRules("Rules/" + "DummyGamemode.cfg");//Load dummy gamemode before loading the rules the new way.

        CRules@ rules = getRules();
        if(@rules == @null)
        {
            error("Dummy Rules failed to load"); return;
        }

        AddGamemode(rules);
        
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

void AddGamemode(CRules@ rules)
{
    string gamemode_path = "";

    ConfigFile@ cfg;

    CFileMatcher@ files = CFileMatcher(sv_gamemode + ".cfg");
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
        //Search every gamemode.cfg file for their gamemode_name, and compare it to sv_gamemode. If they are the same, the gamemode has been found. 

        //warning("search file by file for correct name gamemode path finding");

        @files = @CFileMatcher("gamemode.cfg");
        if(!files.hasMatch())
        {
            error("what? no gamemode.cfg files anywhere?"); return;
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
            //print("gamemode name = " + cfg.read_string("gamemode_name") + " compared against = " + sv_gamemode);
            if(cfg.read_string("gamemode_name") == sv_gamemode)//If the gamemode name is the same as sv_gamemode
            {
                gamemode_path = current_gamemode_path;//Match has been found
                break;
            }
        }
        if(gamemode_path == "")//Still failed to find the gamemode?
        {
            error("Failed to find gamemode \"" + sv_gamemode + "\". Defaulting to vanilla gamemode finding. Note that any modded gamemode.cfg will replace all vanilla gamemode.cfg's");
            gamemode_path = CFileMatcher("Rules/" + sv_gamemode + "/gamemode.cfg").getFirst();
        }
    }
    



    print("gamemode_path = " + gamemode_path);


    @cfg = @ConfigFile();
    if(!cfg.loadFile(gamemode_path)) { error("Failed to load gamemode"); return; }
    if(!cfg.exists("gamemode_name")) { error("gamemode_path was not a gamemode file"); return; }

    array<string> script_array;

    if(cfg.exists("gamemode_name"))
    {
        rules.gamemode_name = cfg.read_string("gamemode_name");
    }
    if(cfg.exists("gamemode_info"))
    {
        rules.gamemode_info = cfg.read_string("gamemode_info");
    }

    cfg.readIntoArray_string(script_array, "scripts");

    if(script_array.size() == 0) { warning("gamemode contained no scripts"); }

    for(u16 i = 0; i < script_array.size(); i++)
    {
        //print("script " + i + " = " + script_array[i]);
        if(!rules.AddScript(script_array[i]))//Add script to rules
        {
            //If the script failed to add.
            script_array.removeAt(i);//Remove it from the array
            i--;//Go back one
            continue;//Do over with the next script
        }
    }

    rules.set("script_array", script_array);
    
    




    rules.set_string("gamemode_path", gamemode_path);
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
