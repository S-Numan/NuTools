//This file handles misc logic and rendering related things in this mod. This file should go before all other files that interact with functions in this mod
//TODO, swap the sending command system from CRules to a single NuTools blob. The command will only send to the blob and cause less max commands issues and be more performant hopfully. Use a method to send a command.
//TODO, figure out what I meant by this ^
//2022 TODO, figured it out. Instead of making/sending commands on CRules, do it on a CBlob. as you can only have 255 command id's, this heplps prevent the max. Additionally, you can give seperate scripts their own command blob and that allows less checking for x command as it doesn't have to go through every single command in CRules before finding the one it wants.

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