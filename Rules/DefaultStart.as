//This file was replaced to handle loading gamemode.cfg better. Unfortunately, the required scripts to do this don't exist.
//At the moment this file only runs example_gamemoe.cfg if the gamemode name is "Testing" and otherwise functions normally.

// default startup functions for autostart scripts

void RunServer()
{
    //Numan - Need to check through every gamemode.cfg file. As it was not possible at the time of this message, certain things were commented out.
	if (getNet().CreateServer())
	{

        //Fancy new gamemode code.
        string gamemode_path = sv_gamemode + ".cfg";

        ConfigFile cfg = ConfigFile();
        if (cfg.loadFile(gamemode_path))
        {
            string cfg_gamemode = cfg.read_string("gamemode_name");
            if(cfg_gamemode.size() != 0)
            {
                LoadRules(gamemode_path);//Load the gamemode.
            }
            else
            {
                error("read gamemode file but it did not contain the string gamemode_name");
                LoadRules("Rules/" + sv_gamemode + "/gamemode.cfg");//Got to try and load something at least.
            }
        }
        else
        {
            //error("failure to load cfg containing gamemode");
            LoadRules("Rules/" + sv_gamemode + "/gamemode.cfg");//Old gamemode loading
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
