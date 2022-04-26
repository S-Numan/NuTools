#define CLIENT_ONLY//Server handles their rules loading themselves.

#include "NuLib.as";

bool gamemode_got;

void onInit(CRules@ rules)
{
    if(!rules.hasCommandID("NuRuleScripts"))
    {
        rules.addCommandID("NuRuleScripts");
    }
    if(!rules.hasCommandID("ConfirmRulesSent"))
    {
        rules.addCommandID("ConfirmRulesSent");
    }
    
    gamemode_got = false;

    if(!isServer())// No localhost.
    {
        //print("Dummy rules loaded. Waiting for server to pass rules.");
        //The client just joined (most likely)
        //print("==CLIENT GAMEMODE WIPE==");

        //Remove all scripts in the whatever gamemode kag initially loads to the client. Don't skip NuToolsLogic.as (avoids removing this script.)
        //Nu::Rules::ClearScripts(false, array<string>(1, "DummyScript2.as"));//False means doesn't sync
        
        if(rules.hasScript("KAG.as"))
        {
            error("WAAAT\n\n\n\n\n\n\n\n\n\nWAAAT");
        }

        array<string> script_array = array<string>();
        rules.set("script_array", script_array);
    }
}

void onTick(CRules@ rules)
{
    if(!isServer() && !gamemode_got && getGameTime() % 30 == 0)//Is not localhost.
    {
        print("Waiting for server to pass gamemode. DummyScript.as onTick(CRules@)", SColor(255, 0, 177, 177));
    }
}

void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
{
    if(cmd == rules.getCommandID("NuRuleScripts"))
    {
        if(!gamemode_got)
        {
            gamemode_got = true;
            if(!isServer())//Is not localhost
            {
                CBitStream params;
                params.write_u16(getLocalPlayer().getNetworkID());
                rules.SendCommand(rules.getCommandID("ConfirmRulesSent"), params, false);//Send to server only
            }
        }

        RuleScripts(rules, params);
    }
}

void RuleScripts(CRules@ rules, CBitStream@ params)
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
        string _temp;

        if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead gamemode_name"); return; }
        rules.gamemode_name = _temp;
        if(!params.saferead_string(_temp)) { Nu::Error("Failed saferead gamemode_info"); return; }
        rules.gamemode_info = _temp;

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
            for(u16 i = 0; i < existing_array.size(); i++)//If every script between the two arrays are the same
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

        //if(rules.hasScript("NuToolsLogic.as"))//Remove just in case, you never know.
        ///{
            rules.RemoveScript("NuToolsLogic.as");
        //}
        //if(rules.hasScript("DummyScript.as"))//Remove justin's case, it isn't mine. why do I have it? Someone tell jusin to take it back.
        //{
            rules.RemoveScript("DummyScript.as");
        //}

        for(u16 i = 0; i < script_array.size(); i++)
        {
            if(rules.hasScript(script_array[i]))
            {
                Nu::Error("Rules already has this script " + script_array[i] + " . FSyncEntireGamemode. And it shouldn't");
                continue;
            }
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

            print("syncing gamemode script array " + i + " is " + script_array[i]);
        }

        rules.set("script_array", script_array);

        //print("Client got join command");
    }
    else
    {
        Nu::Error("In command NuRuleScripts function_to_sync was out of bounds. function_to_sync = " + function_to_sync);
        return;
    }
}