//This file handles misc logic and rendering related things in this mod. This file should go before all other files that interact with functions in this mod
//TODO, swap the sending command system from CRules to a single NuTools blob. The command will only send to the blob and cause less max commands issues and be more performant hopfully. Use a method to send a command.
//TODO, figure out what I meant by this ^

#include "NuRend.as";
#include "NuToolsRendering.as";
#include "NuLib.as";

bool init;
NuRend@ rend;

void onInit( CRules@ rules )//First time start only.
{
    @rend = @LoadStuff(rules);
    
    if(isClient())
    {
        rend.SetupRendering();
    }

    NuLib::onInit(rules);

    onRestart(rules);
}

NuRend@ LoadStuff( CRules@ rules )//Every reload and restart
{
    NuRend@ _rend = NuRend();

    rules.set("NuRend", @_rend);
    
    print("NuRend Loaded");

    if(isClient())
    {
        NuRender::onInit(rules, _rend);
    }

    init = true;

    return @_rend;
}

void onReload( CRules@ rules )
{
    LoadStuff(rules);
}

void onRestart( CRules@ rules)
{
    NuLib::onRestart(rules);
}

void onTick( CRules@ rules )
{
    if(getGameTime() == 30 && isServer() && sv_gamemode == "NuTesting")//If thirty ticks have passed since restarting, this is serverside, and the gamemode is testing.
    {
        CPlayer@ player = getPlayer(0);
        if(player != @null)
        {
            CBlob@ plob = Nu::RespawnPlayer(rules, player);//Respawn the player
            server_CreateBlob("saw", -1, plob.getPosition() + Vec2f(20.0f, 0));
        }
    }

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