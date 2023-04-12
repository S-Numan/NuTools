#include "NuLibCore.as";
#include "DefaultStart.as";

namespace Nu
{
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
            
            if(!CFileMatcher(script_name).hasMatch()) { /*Nu::Error("No match found for " + script_name);*/ return false; }
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
}