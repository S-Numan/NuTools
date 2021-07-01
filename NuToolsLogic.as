//This file should go before all other files that use NuMenu in gamemode.cfg

#include "NuMenuCommon.as";
#include "NuTextCommon.as";
#include "NuHub.as";
#include "NuToolsRendering.as";

bool init;
NuHub@ hub;

void onInit( CRules@ rules )//First time start only.
{
    @hub = @LoadStuff(rules);
    
    hub.SetupRendering();

    NumanLib::onInit(rules);
}

NuHub@ LoadStuff( CRules@ rules)//Every reload and restart
{
    //NuMenu::addMenuToList(buttonhere);//Add buttons like this
    NuHub@ _hub = NuHub();

    rules.set("NuHub", @_hub);
    
    print("NuHub Loaded");


    NuRender::onInit(rules);
    NuMenu::onInit(rules);


    addFonts(rules, _hub);


    

    if(!init &&//First time init.
        sv_gamemode == "Testing")//Provided the gamemode name is Testing.
    {
        print("=====NuButton.as attempt to add=====");
        rules.AddScript("NuButton.as");//Add the NuButton script to the gamemode.
        print("=====If an error is above, ignore it.=====");
    }

    init = true;

    return @_hub;
}

void onReload( CRules@ rules )
{
    LoadStuff(rules);
}

void onRestart( CRules@ rules)
{
    NumanLib::onRestart(rules);
}

void onTick( CRules@ rules )
{
    NuRender::onTick(rules);

    NuMenu::MenuTick();//Run logic for the menus.

    NumanLib::onTick(rules);
}

void onRender( CRules@ rules )
{
    if(!init) { return; }//Kag renders before onInit. Stop this.

    NuRender::onRender(rules);

    NumanLib::onRender(rules);
}





void addFonts( CRules@ rules, NuHub@ hub)
{
    hub.addFont("Arial", "Arial.png");
    hub.addFont("Calibri", "Calibri-48.png");
    hub.addFont("Calibri-Bold", "Calibri-48-Bold.png");
}





void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
{
    NumanLib::onCommand(rules, cmd, params);
}

namespace NumanLib
{
    void onInit(CRules@ rules)
    {
        rules.addCommandID("clientmessage");
        rules.addCommandID("teleport");
        rules.addCommandID("enginemessage");
        rules.addCommandID("announcement");

    }

    void onRestart(CRules@ rules)
    {
        rules.set_u32("announcementtime", 0);
    }


    void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
    {
        if(cmd == rules.getCommandID("clientmessage") )//sends message to a specified client
        {
            if((!isClient())) { return; }

            string text = params.read_string();
            u8 alpha = params.read_u8();
            u8 red = params.read_u8();
            u8 green = params.read_u8();
            u8 blue = params.read_u8();

            client_AddToChat(text, SColor(alpha, red, green, blue));//Color of the text
        }
        else if(cmd == rules.getCommandID("teleport") )//teleports player to position
        {
            CPlayer@ target_player = getPlayerByNetworkId(params.read_u16());//Player 1
            
            if(target_player == @null) { return; }

            CBlob@ target_blob = target_player.getBlob();
            if(target_blob != @null)
            {
                Vec2f pos = params.read_Vec2f();
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