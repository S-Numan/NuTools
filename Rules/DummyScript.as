//Suuper jank
#include "DefaultStart.as";
#include "NuLibCore.as";
#include "NuLibRules.as";

bool player_tick_init;

u32 time_since_initial_sync;//How long has it been since this has finished the initial syncing.

//CBlob@ helper_blob;

void onInit(CRules@ rules)
{
    if(!rules.hasCommandID("NuRuleScripts"))
    {
        rules.addCommandID("NuRuleScripts");
    }
    if(!rules.hasCommandID("GimmeScripts"))
    {
        rules.addCommandID("GimmeScripts");
    }
    if(!rules.hasCommandID("GimmeReload"))
    {
        rules.addCommandID("GimmeReload");
    }

    player_tick_init = false;

    time_since_initial_sync = Nu::u32_max();

    if(!isServer())//No server, no localhost.
    {   
        CPlayer@ local_player = getLocalPlayer();
        if(local_player != @null && local_player.hasTag("lateload_loaded"))//Second load.
        {
            rules.set_bool("DummyFeaturesEnabled", true);
        }
        else//First load
        {
            array<string> script_array = GetAllGamemodeScripts(rules, FindGamemode(rules.gamemode_name));
            rules.set("script_array", script_array);
        }
    }
    else
    {
        //@helper_blob = @server_CreateBlob("template");//The info about the position changes if features_enabled are true. by default, false.
        //helper_blob.server_SetActive(false);//No need to tick or DO anything.
        //Info sent when the client joins
        //helper_blob.setPosition(Vec2f(-1337.1234, -404.1234));//Features disabled.
        //helper_blob.setPosition(Vec2f(-404.1234, -1337.1234));//Features enabled
        //If this position is any different, then features are enabled.
    }
}

void onTick(CRules@ rules)
{
    if(isServer()) { return; } 
    //Only client, no localhost.

    if(time_since_initial_sync < Nu::u32_max() - 1)
    {
        if(time_since_initial_sync == 0)
        {
            //Set camera to the blob the player is controlling.
            CCamera@ camera = getCamera();
            CPlayer@ player = getLocalPlayer();
            if(camera != @null && player != @null && !player.hasTag("no_dummy_camera_fix"))
            {
                CBlob@ plob = player.getBlob();
                if(plob != @null)
                {
                    camera.setPosition(plob.getPosition());
                    camera.setTarget(plob);
                    camera.mousecamstyle = 1; // follow
                }
            }
        }
        
        time_since_initial_sync++;
    }

    if(!player_tick_init)
    {
        player_tick_init = true;
        
        CPlayer@ local_player = getLocalPlayer();
        if(local_player == @null) {  player_tick_init = false; return; }

        if(local_player.hasTag("lateload_loaded"))//Second load?
        {
            CBitStream params;
            params.write_u16(local_player.getNetworkID());
            rules.SendCommand(rules.getCommandID("GimmeScripts"), params, false);
        }
        else//First load
        {
            CBitStream params;
            params.write_u16(local_player.getNetworkID());
            rules.SendCommand(rules.getCommandID("GimmeReload"), params, false);
        }
    }
}

void onCommand(CRules@ rules, u8 cmd, CBitStream@ bs)
{
    if(!isServer())//Client only, no localhost
    {
        if(cmd == rules.getCommandID("GimmeReload"))
        {
            bool features_enabled;
            if(!bs.saferead_bool(features_enabled)) { Nu::Error("Failed to read featured_enabled in GimmeReload"); return; }
            if(features_enabled)
            {
                getLocalPlayer().Tag("lateload_loaded");
                LateLoadRules("Rules/" + "DummyGamemode.cfg");
            }
            return;
        }
        else if(cmd == rules.getCommandID("NuRuleScripts"))
        {
            NuRuleScripts(rules, bs);
        }
    }
    else if(!isClient())
    {
        //Server only past this point. No localhost
        if(cmd == rules.getCommandID("GimmeScripts"))
        {
            array<string> script_array;
            if(!rules.get("script_array", script_array)) { Nu::Error("Could not find script_array"); return; }
            if(script_array.size() == 0) { Nu::Error("script_array was empty"); }

            u16 player_id;
            if(!bs.saferead_u16(player_id)) { Nu::Error("Failed saferead player_id"); return; }
            CPlayer@ player = getPlayerByNetworkId(player_id);
            if(player == @null) { Nu::Error("Player was null"); return; }

            CBitStream params;
            params.write_u8(Nu::Rules::FSyncEntireGamemode);
            params.write_string(rules.gamemode_name);
            params.write_string(rules.gamemode_info);

            u16 i;

            array<string> command_ids = array<string>();
            command_ids.reserve(256);
            for(i = 0; i < 256; i++)
            {
                string id_name = rules.getNameFromCommandID(i);
                if(id_name == "") { continue; }

                command_ids.push_back(id_name);
            }
            params.write_u8(command_ids.size());
            for(i = 0; i < command_ids.size(); i++)
            {
                //print("sharing = " + command_ids[i] + " at pos " + i);
                params.write_string(command_ids[i]);                    
            }


            for(i = 0; i < script_array.size(); i++)
            {
                //print("this script sent = " + script_array[i] + " as script " + i);
                params.write_string(script_array[i]);
            }

            rules.SendCommand(rules.getCommandID("NuRuleScripts"), params, player);
        }
        else if(cmd == rules.getCommandID("GimmeReload"))
        {
            u16 player_id;
            if(!bs.saferead_u16(player_id)) { Nu::Error("Failed saferead player_id"); return; }
            CPlayer@ player = getPlayerByNetworkId(player_id);
            if(player == @null) { Nu::Error("Player was null"); return; }
            
            CBitStream params;
            params.write_bool(rules.get_bool("DummyFeaturesEnabled"));
            rules.SendCommand(rules.getCommandID("GimmeReload"), params, player);
        }
    }
}

void NuRuleScripts(CRules@ rules, CBitStream@ params)
{
    u8 function_to_sync;
    if(!params.saferead_u8(function_to_sync)) { Nu::Error("Failed saferead function_to_sync"); return; }

    if(function_to_sync == Nu::Rules::FClearScripts)
    {
        array<string> skip_these = array<string>();

        string _temp;

        while(params.saferead_string(_temp))
        {
            skip_these.push_back(_temp);
        }
        Nu::Rules::ClearScripts(false, skip_these);
    }
    else if(function_to_sync == Nu::Rules::FRemoveScript)
    {
        string script_to_sync;
        if(!params.saferead_string(script_to_sync)) { Nu::Error("Failed saferead script_to_sync"); return; }
        if(!Nu::Rules::RemoveScript(script_to_sync)) { Nu::Error("RemoveScript failed to sync. script_to_sync = " + script_to_sync); return; }
    }
    else if(function_to_sync == Nu::Rules::FAddScript)
    {
        string script_to_sync;
        if(!params.saferead_string(script_to_sync)) { Nu::Error("Failed saferead script_to_sync"); return; }
        if(!Nu::Rules::AddScript(script_to_sync)) { Nu::Error("AddScript failed to sync. script_to_sync = " + script_to_sync); return; }
    }
    else if(function_to_sync == Nu::Rules::FAddGamemode)
    {
        string gamemode_to_sync;
        if(!params.saferead_string(gamemode_to_sync)) { Nu::Error("Failed saferead gamemode_to_sync"); return; }
        Nu::Rules::AddGamemode(gamemode_to_sync);
    }
    else if(function_to_sync == Nu::Rules::FSyncEntireGamemode)
    {
        SyncEntireGamemode(rules, params);
    }
    else
    {
        Nu::Error("In command NuRuleScripts function_to_sync was out of bounds. function_to_sync = " + function_to_sync);
        return;
    }
}

void SyncEntireGamemode(CRules@ rules, CBitStream@ params)
{       
    string _temp;
    u16 i;

    //params.ResetBitIndex();

    //u8 _temper;
    //if(params.saferead_u8(_temper)) { Nu::Error("Failed to bit index one u8 back."); return; };

    if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead gamemode_name"); return; }
    rules.gamemode_name = _temp;

    if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead gamemode_info"); return; }
    rules.gamemode_info = _temp;
    

    u8 id_count;//Command id's
    if(!params.saferead_u8(id_count)) { Nu::Error("Failed saferead id_count"); return; }
    
    for(i = 0; i < id_count; i++)
    {
        if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead id_names"); return; }
        if(!rules.hasCommandID(_temp))
        {
            rules.addCommandID(_temp);
            //print("added id " + _temp);
        }
        else
        {
            //print("id already exists = " + _temp);
        }
    }



    array<string> script_array;

    while(params.saferead_string(_temp))
    {
        script_array.push_back(_temp);
    }

    if(script_array.size() == 0)
    {
        Nu::Error("Attempted to sync script array of size 0");
        return;
    }

    //Check if our script array is exactly the same as the one being given to us. If they are the same, ignore it.
    array<string> existing_array;
    if(rules.get("script_array", existing_array) && existing_array.size() != 0//If a script_array is already in place
    && existing_array.size() == script_array.size())//And the existing_array and script_array are equal in size.
    {
        bool same_array = true;
        for(i = 0; i < existing_array.size(); i++)//If every script between the two arrays are the same
        {
            if(existing_array[i] != script_array[i])
            {
                same_array = false;
                break;   
            }
        }
        if(same_array)//These two arrays are the same.
        {
            print("Attempted to sync same script_array.");
            return;//Stop here
        }
    }
    
    Nu::Rules::ClearScripts(false, array<string>());//Don't sync, don't skip removing anything. Remove it all!

    //if(rules.hasScript("NuToolsLogic.as"))//Remove justin's case, it isn't mine. why do I have it? Someone tell jusin to take it back.
    //{
        //rules.RemoveScript("NuToolsLogic.as");
    //}

    for(i = 0; i < script_array.size(); i++)
    {
        if(!CFileMatcher(script_array[i]).hasMatch())
        {
            //If the script failed to add.
            Nu::Error("Failed to add script on server to client in FSyncEntireGamemode.");
            script_array.removeAt(i);
            i--;
            continue;//Do over with the next script
        }
        rules.AddScript(script_array[i]);//Add script to rules
        //if(!rules.hasScript(script_array[i]))//doesn't work without waiting a tick, use CFileMatcher instead.
        //print("added script = " + script_array[i]);

        //print("syncing gamemode script array " + i + " is " + script_array[i]);
    }
    if(time_since_initial_sync == Nu::u32_max())//Initial sync?
    {
        time_since_initial_sync = 0;//It is no longer.
    }

    rules.set("script_array", script_array);

    //print("Client got join command");
}

bool RemoveAllGamemodeScripts(CRules@ rules, string gamemode_path)
{
    ConfigFile cfg = ConfigFile();

    array<string> script_array;

    script_array = GetAllGamemodeScripts(rules, gamemode_path);

    for(u16 i = 0; i < script_array.size(); i++)
    {
        //print("script removed = " + script_array[i]);
        rules.RemoveScript(script_array[i]);
    }
    
    return true;
}

array<string> GetAllGamemodeScripts(CRules@ rules, string gamemode_path)
{
    ConfigFile cfg = ConfigFile();

    array<string> script_array;
            
    if(!cfg.loadFile(gamemode_path)) { Nu::Error("Failed to load gamemode to clear all scripts from. Gamemode = " + gamemode_path); return array<string>(); }
    cfg.readIntoArray_string(script_array, "scripts");
    if(script_array.size() == 0) { Nu::Warning("gamemode contained no scripts. Gamemode = " + gamemode_path); }

    return script_array;
}