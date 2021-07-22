//This file handles misc logic and rendering related things in this mod. This file should go before all other files that use NuHub in gamemode.cfg.
//TODO, swap the sending command system from CRules to a single NuTools blob. The command will only send to the blob and cause less max commands issues and be more performant hopfully. Use a method to send a command.

#include "NuMenuCommon.as";
#include "NuTextCommon.as";
#include "NuHub.as";
#include "NuToolsRendering.as";

bool init;
NuHub@ hub;

void onInit( CRules@ rules )//First time start only.
{
    @hub = @LoadStuff(rules);
    
    if(isClient())
    {
        hub.SetupRendering();
    }

    NuLib::onInit(rules);
}

NuHub@ LoadStuff( CRules@ rules)//Every reload and restart
{
    //NuMenu::addMenuToList(buttonhere);//Add buttons like this
    NuHub@ _hub = NuHub();

    rules.set("NuHub", @_hub);
    
    print("NuHub Loaded");

    if(isClient())
    {
        NuRender::onInit(rules, _hub);

        NuMenu::onInit(rules, _hub);

        addFonts(rules, _hub);
    }
    

    if(!init &&//First time init.
        sv_gamemode == "Testing")//Provided the gamemode name is Testing.
    {
        print("=====NuButton.as attempt to add=====");
        rules.AddScript("NuButton.as");//Add the NuButton script to the gamemode.
        print("=====If an error is above, ignore it.=====");
    }//It's done like this to allow NuTools Testing gamemode with or without the NuButton mod installed 

    init = true;

    return @_hub;
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
    NuRender::onTick(rules);

    NuMenu::MenuTick();//Run logic for the menus.
}

void onRender( CRules@ rules )
{
    if(!init) { return; }//Kag renders before onInit. Stop this.

    NuRender::onRender(rules);

    NuLib::onRender(rules);
}





void addFonts( CRules@ rules, NuHub@ hub)
{
    //hub.addFont("Arial", "Arial.png");
    hub.addFont("Calibri-48", "Calibri-48.png");
    hub.addFont("Calibri-48-Bold", "Calibri-48-Bold.png");
}





void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
{
    NuLib::onCommand(rules, cmd, params);
}