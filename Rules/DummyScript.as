#include "DefaultStart.as";
#include "NuLib.as";

const u8 SAFE_WAIT = 30;//Ticks needed to wait before adding rules.

u8 gamemode_got;//On 0, the gamemode is got.

CBitStream@ caught_params;

void onInit(CRules@ rules)
{
    if(!rules.hasCommandID("NuRuleScripts"))
    {
        rules.addCommandID("NuRuleScripts");
    }

    if(!isServer())//No server, no localhost.
    {
        gamemode_got = SAFE_WAIT;

        @caught_params = @null;
        
        //print("Dummy rules loaded. Waiting for server to pass rules.");
        //The client just joined (most likely)

        //Remove all scripts in the whatever gamemode kag initially loads to the client. Don't skip NuToolsLogic.as (avoids removing this script.)
        //Nu::Rules::ClearScripts(false, array<string>());//False means doesn't sync
    }
    else
    {
        gamemode_got = 0;
    }
}

void onTick(CRules@ rules)
{
    if(isServer()) { return; } 
    //Only client, no localhost.

    if(gamemode_got != 0 && caught_params != @null)
    {
        gamemode_got--;
        if(gamemode_got == 0)
        {
            gamemode_got = 1;
            NuRuleScripts(rules, caught_params);
        }
    }
    else if(getGameTime() % 60 == 0)
    {
        print("Waiting for server to pass gamemode. DummyScript.as onTick(CRules@)", SColor(255, 0, 177, 177));
    }

}

void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
{
    if(!isServer() &&//No server, no localhost. 
        cmd == rules.getCommandID("NuRuleScripts"))
    {
        NuRuleScripts(rules, params);
    }
}

void NuRuleScripts(CRules@ rules, CBitStream@ params)
{
    u16 function_to_sync;
    if(!params.saferead_u16(function_to_sync)) { Nu::Error("Failed saferead function_to_sync"); return; }

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
        if(gamemode_got != 0)
        {
            @caught_params = @params;
            return;
        }
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

    if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead current_gamemode_path"); return; }
    rules.set_string("current_gamemode_path", _temp);

    if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead last_gamemode_path"); return; }
    rules.set_string("last_gamemode_path", _temp);

    if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead first_gamemode_path"); return; }
    rules.set_string("first_gamemode_path", _temp);

    if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead gamemode_name"); return; }
    rules.gamemode_name = _temp;

    if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead gamemode_info"); return; }
    rules.gamemode_info = _temp;

    array<string> script_array;

    string gamemode_path = rules.get_string("current_gamemode_path");

    if(gamemode_got == 1)//First join?
    {
        for(i = 0; i < 3; i++)
        {
            //print("Removing every script from " + gamemode_path);
            
            ConfigFile cfg = ConfigFile();

            if(i == 1)
            {
                gamemode_path = rules.get_string("last_gamemode_path");
                if(gamemode_path == "") { continue; }
            }
            else if(i == 2)
            {
                gamemode_path = rules.get_string("first_gamemode_path");
            }

            if(!cfg.loadFile(gamemode_path)) { Nu::Error("Failed to load gamemode to clear all scripts from. Gamemode = " + gamemode_path); continue; }
            cfg.readIntoArray_string(script_array, "scripts");
            if(script_array.size() == 0) { Nu::Warning("gamemode contained no scripts. Gamemode = " + gamemode_path); }
            for(u16 i = 0; i < script_array.size(); i++)
            {
                //print("script removed = " + script_array[i]);
                rules.RemoveScript(script_array[i]);
            }

            script_array.resize(0);
        }
    }

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

    gamemode_got = 0;

    //print("Client got join command");
}

void onNewPlayerJoin(CRules@ rules, CPlayer@ player)
{
    if(player == @null) { Nu::Error("player was null"); return; }
    
    if(!isClient()//Only server, no localhost
        && rules.get_bool("custom_gamemode_loading"))
    {
        array<string> script_array;
        if(!rules.get("script_array", script_array)) { Nu::Error("Could not find script_array"); return; }
        if(script_array.size() == 0) { Nu::Error("script_array was empty"); }

        CBitStream params;
        params.write_u8(Nu::Rules::FSyncEntireGamemode);
        params.write_string(rules.get_string("current_gamemode_path"));
        params.write_string(rules.get_string("last_gamemode_path"));
        params.write_string(rules.get_string("first_gamemode_path"));
        params.write_string(rules.gamemode_name);
        params.write_string(rules.gamemode_info);

        for(u16 i = 0; i < script_array.size(); i++)
        {
            //print("this script sent = " + script_array[i] + " as script " + i);
            params.write_string(script_array[i]);
        }

        rules.SendCommand(rules.getCommandID("NuRuleScripts"), params, player);
    }
}