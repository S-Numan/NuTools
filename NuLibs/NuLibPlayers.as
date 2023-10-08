#include "NuLibCore.as"; 
#include "NuLibTiles.as";
#include "NuLibBlobs.as";

namespace Nu
{
    
    shared CBlob@ RespawnPlayer(CRules@ rules, CPlayer@ player)
    {
        return RespawnPlayer(rules, player, "", Vec2f_zero);
    }
    shared CBlob@ RespawnPlayer(CRules@ rules, CPlayer@ player, string blob_name)
    {
        return RespawnPlayer(rules, player, blob_name, Vec2f_zero);
    }
    shared CBlob@ RespawnPlayer(CRules@ rules, CPlayer@ player, Vec2f spawn)
    {
        return RespawnPlayer(rules, player, "", spawn);
    }
    //1: rules for rules things
    //2: player that will be respawned
    //3: optional parameter to specify what blob they will respawn as
    //4: optional paramter to specify spawn location
    //Respawns the player firstly at a spawn if avaliable, secondly at the ground from the top left.
    shared CBlob@ RespawnPlayer(CRules@ rules, CPlayer@ player, string blob_name, Vec2f spawn)
    {
        if(!isServer()) { Nu::Warning("Tried respawning player on client"); return @null; }
        if(player == @null) { Nu::Error("player was null"); return @null; }

        CMap@ map = getMap();

        Vec2f[] spawns;
        
        int player_team = player.getTeamNum();

        //
        //Find spawn location
        //
        bool no_spawn = false;//If no spawn was found, this will be true.
        if(spawn == Vec2f_zero)
        {
            if (player_team == 0)//Team 0?
            {
                if(getMap().getMarkers("blue spawn", spawns))//If blue markers exist
                {
                    spawn = spawns[ XORRandom(spawns.length) ];//Pick on randomly
                }
                else if(getMap().getMarkers("blue main spawn", spawns))//if blue main markers exist
                {
                    spawn = spawns[ XORRandom(spawns.length) ];//Pick one randomly
                }
            }
            else if (player_team == 1)//Team 1?
            {
                if(getMap().getMarkers("red spawn", spawns))
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                }
                else if(getMap().getMarkers("red main spawn", spawns))
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                }
            }
            if(spawn == Vec2f_zero)//No spawn found?
            {
                if(getMap().getMarkers("default spawn", spawns))
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                }
                else if(getMap().getMarkers("default main spawn", spawns))
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                }
            }
            if(spawn == Vec2f_zero)
            {
                CBlob@[] respawn_posts;
                getBlobsByTag("respawn", @respawn_posts);

                spawns.resize(0);

                for (u16 i = 0; i < respawn_posts.size(); i++)
                {
                    CBlob@ blob = respawn_posts[i];

                    if (blob.getTeamNum() == player_team)
                    {
                        spawns.push_back(blob.getPosition());
                    }
                }
                if(spawns.size() != 0)
                {
                    spawn = spawns[ XORRandom(spawns.length) ];
                    spawn.y += map.tilesize;//One tile down.
                }
            }

            if(spawn == Vec2f_zero)//Still no spawn found?
            {
                no_spawn = true;//No spawn was found

                spawn.x = map.tilesize * 2;//Start two tiles out
                
                //Look for ground under point tile by tile going right.
                while(spawn.y == 0.0f)//While no ground is found
                {
                    if(spawn.x > map.tilemapwidth * map.tilesize)//If we've gone beyond the right of the map.
                    {
                        spawn = Vec2f(0,0);//Just default to the top left
                        break;//And stop
                    }
                    spawn.x += map.tilesize;//Go one tile right
                    spawn.y = Nu::getTileUnderPos(Vec2f(spawn.x, 0));//Find tile below x pos
                }
            }
        }
        //
        //Find spawn location
        //


        string actor;//Name of the new blob
        if(blob_name != "")//If a blob name is specified.
        {
            actor = blob_name;//Use it
        }
        else if(rules.get_bool("respawn_as_last_blob") && player.lastBlobName != "")//No blob name? If respawn_as_last_blob is true, check for a lastBlobName. 
        {
            actor = player.lastBlobName;//Use it
        }
        else//No last player blob?
        {
            actor = rules.get_string("default class");//Just default to the default class
        }

        CBlob@ newBlob = server_CreateBlob(actor);//Create the new blob with the player's team at the position spawn

        if(newBlob != @null)//If the new blob is not null
        {
            if(!no_spawn)//If no spawn was found
            {
                spawn.y -= newBlob.getHeight() / 2;//Push blob up from spawn location to keep it from colliding with the ground.
            }

            f32 tile_under_pos = Nu::getTileUnderPos(spawn);//Get tile under the spawn location.
            while(spawn.y + (newBlob.getHeight() / 2) > tile_under_pos)//While the newBlob is colliding with the ground.
            {
                spawn.y -= map.tilesize;//Push the spawn position up by one.
            }

            newBlob.server_setTeamNum(player_team);//Set team
            newBlob.setPosition(spawn);//Set spawn location

            CBlob@ plob = @player.getBlob();//Get the current player's blob
            if(plob != @null)//If it is not null.
            {
                plob.server_SetPlayer(@null);//No idea if this is needed
                plob.server_Die();//Deadify it.
            }
            newBlob.server_SetPlayer(player);//Set the player to it's new blob
        }

        return @newBlob;
    }

    //Returns every player in the server in an array.
    shared array<CPlayer@> getPlayers()
    {
        array<CPlayer@> players(getPlayerCount());
        
        for(u16 i = 0; i < getPlayerCount(); i++)
        {
            @players[i] = @getPlayer(i);
        }
        
        return players;
    }

    //1: Parameter of the team
    //Returns an array of players that are in that team. 
    shared array<CPlayer@> getPlayersInTeam(u8 team)
    {
        u16 i;//Init i.
        
        u16 team_players = getTeamCount(team);//Get amount of players in the team.

        array<CPlayer@> players(team_players);//Create the player array with the amount of players in the team.

        for(i = 0; i < getPlayerCount(); i++)//For every player
        {
            CPlayer@ player = getPlayer(i);//Get the player in a var.
            if(player.getTeamNum() == team)//If this player is the same team as the parameter "team"
            {
                team_players--;//Found a team player
                
                @players[team_players] = @player;//Add the team player to the array
            }
        }

        return players;//Return the array
    }

    //1: Parameter of the team.
    //Returns amount of players in the team. The player's team, not the blob team
    shared u16 getTeamCount(u8 team)
    {
        u16 i;
        u16 team_players = 0;

        for(i = 0; i < getPlayerCount(); i++)//For every player
        {
            if(getPlayer(i).getTeamNum() == team)//If this player is the same team as the parameter "team"
            {
                team_players++;//Add a team player
            }
        }
        return team_players;
    }

    //Returns an array of all the player blobs. Players without blobs will have their spot be null. This array lines up with the getPlayers() array
    shared array<CBlob@> getPlayerBlobs()
    {
        array<CBlob@> player_blobs(getPlayerCount());

        for(u16 i = 0; i < getPlayerCount(); i++)//For every player
        {
            @player_blobs[i] = @getPlayer(i).getBlob();//Put their blob into the array (even if it is null)
        }

        return player_blobs;//Return the player blobs.
    }

    //1: A string. The shortened/first half version of a player's username. Case sensitive.
    //Returns an array of players that have "shortname" at the start of their username. If their username is exactly the same, it will return an array containing only that player excluding the rest.
    shared array<CPlayer@> getPlayersByShortUsername(string shortname)
    {
        array<CPlayer@> playersout();//The main array for storing all the players which contain shortname

        for(int i = 0; i < getPlayerCount(); i++)//For every player
        {
            CPlayer@ player = getPlayer(i);//Grab the player
            if(player == @null)//If the player doesn't exist for whatever reason.
            {
                continue;//Skip past them.
            }

            string playerusername = player.getUsername();//Get the player's username

            if(playerusername == shortname)//If the name is exactly the same
            {
                array<CPlayer@> playersoutone;//Make a quick array
                playersoutone.push_back(player);//Put the player in that array
                return playersoutone;//Return this array
            }

            if(playerusername.substr(0, shortname.size()) == shortname)//If the players username contains shortname
            {
                playersout.push_back(player);//Put the array.
            }
        }
        return playersout;//Return the array
    }

    //1: A string. The shortened/first half version of a player's username. Case sensitive.
    //2: Optional .An output of every player name with a " : " in between each. Empty if zero or only one player was found.
    //See getPlayersByShortUsername. Returns a single player, if no players were found returns null.
    shared CPlayer@ getPlayerByShortUsername(string shortname, string &out player_names = void)
    {
        player_names = "";
        array<CPlayer@> target_players = getPlayersByShortUsername(shortname);//Get a list of players that have this as the start of their username
        
        if(target_players.size() > 1)//If there is more than 1 player in the list
        {
            for(int i = 0; i < target_players.size(); i++)//for every player in that list
            {
                player_names += " : " + target_players[i].getUsername();//put their name in a string
            }
            //print("There is more than one possible player for the player param" + playernames);//tell the client that these players in the string were found
            return @target_players[0];//don't send the message to chat, don't do anything else
        }
        else if(target_players == @null || target_players.size() == 0)
        {
            print("No player was found for the player param.");
            return @null;
        }
        return target_players[0];
    }


    //Parameters
    //1: A point.
    //2: The radius around that point to get the blobs from. Any player blobs outside the radius will not be put in the array.
    //3: If this array should skip both blobs in inventories, and unactive blobs. This is by default true.
    //Returns an array of all players sorted by distance. Players without blobs are not included in this array.
    shared array<CPlayer@> SortPlayersByDistance(Vec2f point, f32 radius, bool skip_unactive_and_inventory = true)
    {
        u16 i;

        u16 non_null_count = 0;
        
        array<CBlob@> playerblobs(getPlayerCount());

        //Put all blobs in playerblobs array
        for(i = 0; i < playerblobs.size(); i++)
        {
            CPlayer@ player = getPlayer(i);
            if(player != @null)
            {
                CBlob@ player_blob = player.getBlob();
                
                if(player_blob != @null//If the player has a blob. 
                && (!skip_unactive_and_inventory || player_blob.isActive() || !player_blob.isInInventory()))//And if skip_unactive is true, only if the blob is active and not in an inventory.
                {
                    @playerblobs[non_null_count] = @player_blob;
                    non_null_count++;
                }
            }
        }

        playerblobs.resize(non_null_count);

        playerblobs = SortBlobsByDistance(point, radius, playerblobs, skip_unactive_and_inventory);
        
        array<CPlayer@> sorted_players(playerblobs.size());

        for(i = 0; i < non_null_count; i++)
        {
            @sorted_players[i] = @playerblobs[i].getPlayer();
        }

        return sorted_players;
    }
}