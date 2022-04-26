#include "DefaultStart.as";
#include "NuLib.as";

const u8 SAFE_WAIT = 30;//Ticks needed to wait before adding rules.

bool player_tick_init;

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

    if(!isServer())//No server, no localhost.
    {
        CPlayer@ local_player = getLocalPlayer();
        if(local_player != @null && local_player.hasTag("lateload_loaded"))//Second load.
        {

        }
        else//First load
        {
            RemoveAllGamemodeScripts(rules, FindGamemode(rules.gamemode_name));
        }
    }
    else
    {

    }
}

void onTick(CRules@ rules)
{
    if(isServer()) { return; } 
    //Only client, no localhost.

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
            getLocalPlayer().Tag("lateload_loaded");
            LateLoadRules("Rules/" + "DummyGamemode.cfg");
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
                print("sharing = " + command_ids[i] + " at pos " + i);
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
            print("added id " + _temp);
        }
        else
        {
            print("id already exists = " + _temp);
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

    //rules.gamemode_name = _temp;

    rules.set("script_array", script_array);

    //print("Client got join command");
}

bool RemoveAllGamemodeScripts(CRules@ rules, string gamemode_path)
{
    ConfigFile cfg = ConfigFile();

    array<string> script_array = array<string>();
            
    if(!cfg.loadFile(gamemode_path)) { Nu::Error("Failed to load gamemode to clear all scripts from. Gamemode = " + gamemode_path); return false; }
    cfg.readIntoArray_string(script_array, "scripts");
    if(script_array.size() == 0) { Nu::Warning("gamemode contained no scripts. Gamemode = " + gamemode_path); }
    for(u16 i = 0; i < script_array.size(); i++)
    {
        //print("script removed = " + script_array[i]);
        rules.RemoveScript(script_array[i]);
    }
    
    return true;
}