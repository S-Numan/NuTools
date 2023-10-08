//This file handles misc logic and rendering related things in this mod. This file should go before all other files that interact with functions in this mod
//TODO, swap the sending command system from CRules to a single NuTools blob. The command will only send to the blob and cause less max commands issues and be more performant hopfully. Use a method to send a command.
//TODO, figure out what I meant by this ^
//2022 TODO, figured it out. Instead of making/sending commands on CRules, do it on a CBlob. as you can only have 255 command id's, this heplps prevent the max. Additionally, you can give seperate scripts their own command blob and that allows less checking for x command as it doesn't have to go through every single command in CRules before finding the one it wants.

#include "NuRend.as";
#include "NuToolsRendering.as";
#include "NuLibCore.as";
#include "NuLibPlayers.as";

bool init;
NuRend@ rend;

void onInit( CRules@ rules )//First time start only.
{
    LoadStuff(rules);

    if(isClient())
    {
        rend.SetupRendering();
    }

    NuLib::onInit(rules);

    onRestart(rules);
}

void LoadStuff( CRules@ rules )
{
    if(rules.exists("NuRend"))
    {
        rules.get("NuRend", @rend);    
    }
    else
    {
        @rend = @NuRend();
        rules.set("NuRend", @rend);
    }

    if(isClient())
    {
        NuRender::onInit(rules, rend);
    }

     

    print("NuRend Loaded");
    

    init = true;
}

void onReload( CRules@ rules )
{
    LoadStuff(rules);
}

void onRestart( CRules@ rules)
{
    NuLib::onRestart(rules);
}

void onTick(CRules@ rules)
{
    NuLib::onTick(rules);
    
    NuRender::onTick(rules);
}

void onRender( CRules@ rules )
{
    if(!init) { return; }//Kag renders before onInit. Stop this.

    NuRender::onRender(rules);

    NuLib::onRender(rules);
}




void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
{
    NuLib::onCommand(rules, cmd, params);
}

void onNewPlayerJoin(CRules@ rules, CPlayer@ player)
{
    NuLib::onNewPlayerJoin(rules, player);
}
void onPlayerLeave(CRules@ rules, CPlayer@ player)
{
    NuLib::onPlayerLeave(rules, player);
}

void onPlayerDie(CRules@ rules, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
    NuLib::onPlayerDie(rules, victim, attacker, customData);
}
















NuRend@ o_rend = @null;//Outer rend
bool RendInit()
{
    if(o_rend == @null)//If we don't have o_rend
    {
        if(!getRend(@o_rend, false)) { return false; }//Try and get it
    }
    return true;//We got it if it got here
}
void MenusPostHud(int id)
{
    if(!RendInit()) { return; }
    NuRender::ImageRender(o_rend, Render::layer_posthud);
}
void MenusPreHud(int id)
{
    if(!RendInit()) { return; }
    
    NuRender::ImageRender(o_rend, Render::layer_prehud);
}
void MenusPostWorld(int id)
{
    if(!RendInit()) { return; }
    
    NuRender::ImageRender(o_rend, Render::layer_postworld);
}
void MenusObjects(int id)
{
    if(!RendInit()) { return; }
    
    NuRender::ImageRender(o_rend, Render::layer_objects);
}
void MenusTiles(int id)
{
    if(!RendInit()) { return; }
    
    NuRender::ImageRender(o_rend, Render::layer_tiles);
}
void MenusBackground(int id)
{
    if(!RendInit()) { return; }
    
    NuRender::ImageRender(o_rend, Render::layer_background);
}


















//Generally for functions that require constant ticking/rendering or require to be sent to client or server from client or server.
namespace NuLib
{
    //TODO remove every player array if they are 1. Allowed to respawn(not waiting to respawn anymore). 2. Left the server.
    array<u32> respawn_times;
    array<int> player_times;//Corresponds with respawn_times. Holds player usernames hashed.
    array<CPlayer@> player_times_player;
    const u8 SAFE_TIME = 2;//Amount of time it takes to be "safe" for the player to do things like spawn. Spawning straight away makes kag unhappy.
    u16 getPlayerTimesIndex(CPlayer@ player)
    {
        if(!isServer()) { Nu::Error("This function is server only"); return 0; }
        int name_hash = player.getUsername().getHash();

        u16 i;

        bool exists = false;

        for(i = 0; i < player_times.size(); i++)
        {
            if(@player == @player_times_player[i]) { exists = true; break; }
        }

        if(exists){
            return i;
        }
        else{
            return Nu::u16_max();
        }
    }

    void onInit(CRules@ rules)
    {
        if(!rules.hasCommandID("clientmessage")){ rules.addCommandID("clientmessage"); }//Just for testing purposes
        rules.addCommandID("clienttoclient");
        rules.addCommandID("createblob");
        rules.addCommandID("teleport");
        rules.addCommandID("enginemessage");
        rules.addCommandID("announcement");
        rules.addCommandID("switchfrominventory");
        rules.addCommandID("nunextmap");

        if(isServer())
        {
            respawn_times = array<u32>();
            player_times = array<int>();
            player_times_player = array<CPlayer@>();
        }
    }

    void onRestart(CRules@ rules)
    {
        rules.set_u32("announcementtime", 0);

        if(isServer())
        {
            for(u16 i = 0; i < player_times.size(); i++)//For every player_times
            {
                if(player_times_player == @null)//If the player left
                {
                    //Rid of their arrays
                    respawn_times.removeAt(i);
                    player_times_player.removeAt(i);
                    player_times.removeAt(i);
                }
                else//Player didn't leave?
                {
                    //Default some of their arrays.
                    respawn_times[i] = getGameTime() + SAFE_TIME;
                }
            }
        }
    }

    void onTick(CRules@ rules)
    {
        if(isServer())
        {
            u16 i;
            if(rules.get_u16("nu_respawn_time") != 0)
            {
                for(i = 0; i < player_times.size(); i++)//For every player's respawn time
                {
                    if(respawn_times[i] == getGameTime())//If it is time for them to respawn
                    {
                        if(player_times_player[i] == @null) { continue; }//If the player left, just let them respawn when they rejoin.

                        Nu::RespawnPlayer(rules, player_times_player[i]);
                    }
                }
            }
        }
    }
    
    void onNewPlayerJoin(CRules@ rules, CPlayer@ player)
    {
        if(isServer())
        {
            if(player == @null) { Nu::Error("player was null"); return; }
            
            u16 player_index = getPlayerTimesIndex(player);
            if(player_index == Nu::u16_max())//Player doesn't exist?
            {
                respawn_times.push_back(getGameTime() + SAFE_TIME);//Tick or two to respawn to prevent annoying bugs.
                player_times.push_back(player.getUsername().getHash());
                player_times_player.push_back(@player);
            }
            else//player_index still exists
            {
                @player_times_player[player_index] = @player;//Reset player
                
                //if(respawn_times[player_index] + SAFE_TIME >= getGameTime())
                if(respawn_times[player_index] <= getGameTime())//This player is allowed to respawn?
                {
                    respawn_times[player_index] = getGameTime();//Allow player to respawn
                }
                if(respawn_times[player_index] <= getGameTime() + SAFE_TIME)//If player is allowed to respawn within SAFE_TIME. (as in, player respawning very soon)
                {
                    respawn_times[player_index] += SAFE_TIME;//Make sure it is safe. Tick or two wait before spawning, so kag doesn't complain.
                }
            }
        }
    }
    void onPlayerLeave( CRules@ rules, CPlayer@ player )
    {
        if(isServer())
        {
            u16 player_index = getPlayerTimesIndex(player);
            if(player_index != Nu::u16_max())//Make sure the player exists just in case
            {
                @player_times_player[player_index] = @null;//Remove player
            }

            if(getPlayerCount() == 1)//Last player disconnect?
            {
                if(rules.get_bool("restartmap_onlastplayer_disconnect"))//Restart the map when the last player disconnects?
                {
                    print("LAST PLAYER DISCONNECT. RESTARTING MAP");
                    LoadMap(getMap().getMapName());
                }
            }
        }
    }

    void onPlayerDie( CRules@ rules, CPlayer@ victim, CPlayer@ attacker, u8 customData )//Calls when the player's blob dies
    {
        if(isServer())
        {
            u16 respawn_time = rules.get_u16("nu_respawn_time");

            if(respawn_time != 0)
            {
                if(victim == @null) { Nu::Error("victim was null"); return; }

                if(respawn_time < SAFE_TIME) { respawn_time = SAFE_TIME; rules.set_u16("nu_respawn_time", respawn_time); }

                respawn_times[getPlayerTimesIndex(victim)] = getGameTime() + respawn_time;
            }
        }
    }

    void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
    {
        if(cmd == rules.getCommandID("clienttoclient"))
        {
            if(!isServer()) { return; }
            u8 command_id;
            if(!params.saferead_u8(command_id)) { Nu::Error("clienttoclient failed to saferead command_id"); return; }
            u16 player_id;
            if(!params.saferead_u16(player_id)) { Nu::Error("clienttoclient failed to saferead player_id"); return; }
            CBitStream _params;
            if(!params.saferead_CBitStream(_params)) { Nu::Error("clienttoclient failed to read CBitStream"); return; }

            CPlayer@ player = getPlayerByNetworkId(player_id);
            if(player != @null)
            {
                rules.SendCommand(command_id, _params, player);
            }
        }
        else if(cmd == rules.getCommandID("createblob"))
        {
            if(!isServer()) { Nu::Warning("createblob is a server only command, please only use it on the server."); return; }

            string blob_name;
            u8 team;
            Vec2f pos;
            if(!params.saferead_string(blob_name)) { Nu::Error("failed to read blob_name param on createblob command"); return; }
            params.saferead_u8(team);
            params.saferead_Vec2f(pos);
            
            CBlob@ created_blob = server_CreateBlob(blob_name, team, pos);
            if(created_blob.getName() == "")
            {
                Nu::Warning("Failed to spawn " + blob_name + ". In the createblob command");
            }
        }
        else if(cmd == rules.getCommandID("switchfrominventory"))
        {
            if(!isServer()) { return; }

            bool inventorise_held;
            u16 blob_id;
            u16 getblob_id;

            if(!params.saferead_bool(inventorise_held)) { Nu::Error("bool get was null"); return; }
            if(!params.saferead_u16(blob_id)) { Nu::Error("ID get was null"); return; }
            if(!params.saferead_u16(getblob_id)) { Nu::Error("ID get was null"); return; }

            CBlob@ pblob = getBlobByNetworkID(blob_id);
            if(pblob == @null) { return; }

            CInventory@ inv = pblob.getInventory();
            if(inv == @null) { return; }

            CBlob@ getblob = getBlobByNetworkID(getblob_id);
            if(getblob == @null) { return; }

            CBlob@ carried_blob = pblob.getCarriedBlob();

            if(!inv.isInInventory(getblob) && @getblob != @carried_blob) { return; }//If getblob is not in pblob's inventory or being held by pblob
            
            if(carried_blob != @null)
            {
                if(inventorise_held)//Supposed to put the currently held item in the inventory?
                {
                    if(!inv.canPutItem(carried_blob))//If it can't be put in the inventory
                    {
                        return;//CEASE
                    }
                    else//It is possible?
                    {
                        if(!pblob.server_PutInInventory(carried_blob)) { Nu::Error("Failed to put blob in inventory."); return; }//Put it in
                    }
                    
                    //if(carried_blob.getName() == getblob.getName())//If the getblob is the same type as the carried_blob
                    if(@carried_blob == @getblob)//If the getblob is the exact same blob
                    {
                        return;//Do nothing more.
                    }
                }
                else//No inventorizing
                {
                    pblob.DropCarried();//Just drop it
                }
            }
            //From this point onwards, pblob is no longer holding a blob. 

            
            if(!pblob.server_PutOutInventory(getblob)) { Nu::Error("Failed to put blob out inventory."); return; }//Take it out

            if(!pblob.server_Pickup(getblob)) { Nu::Error("Failed to pickup blob taken out of inventory."); return; }//Pick it up

            //Mission success
        }
        else if(cmd == rules.getCommandID("clientmessage") )//sends message to a specified client
        {
            if(!isClient()) { return; }

            bool to_console = params.read_bool();
            string text = params.read_string();
            u8 alpha = params.read_u8();
            u8 red = params.read_u8();
            u8 green = params.read_u8();
            u8 blue = params.read_u8();

            if(to_console)
            {
                print(text, SColor(alpha, red, green, blue));
            }
            else
            {
                client_AddToChat(text, SColor(alpha, red, green, blue));//Color of the text
            }
        }
        else if(cmd == rules.getCommandID("teleport") )//teleports blob to position
        {
            u16 netid;
            if(!params.saferead_u16(netid)) { Nu::Error("saferead failure"); return; }
            
            CBlob@ target_blob = getBlobByNetworkID(netid);
            if(target_blob == @null) { return; }

            if(target_blob != @null)
            {
                Vec2f pos;
                if(!params.saferead_Vec2f(pos)) { Nu::Error("saferead failure"); return; }
                target_blob.setPosition(pos);
                ParticleZombieLightning(pos);
            }	
        }
        else if(cmd == rules.getCommandID("enginemessage") )
        {
            if(!isClient()) { return; }
            string text = params.read_string();
            EngineMessage(text);
        }
        else if(cmd == rules.getCommandID("announcement"))
        {
            rules.set_string("announcement", params.read_string());
            rules.set_u32("announcementtime",30 * 15 + getGameTime());//15 seconds
        }
        else if(cmd == rules.getCommandID("nunextmap"))
        {
            string map_name = params.read_string();
            if(map_name == " ")
            {
                LoadNextMap();
            }
            else
            {
                LoadMap(map_name);
            }
        }
    }


    void onRender(CRules@ rules)
    {
        GUI::SetFont("menu");

        CPlayer@ localplayer = getLocalPlayer();
        if(localplayer == @null)
        {
            return;
        }

        if(rules.get_u32("announcementtime") > getGameTime())
        {
            GUI::DrawTextCentered(rules.get_string("announcement"), Vec2f(getScreenWidth()/2,getScreenHeight()/2), SColor(255,255,127,60));
        }
    }

}