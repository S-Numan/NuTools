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

void onTick( CRules@ rules )
{
    NuRender::onTick(rules);

    NuMenu::MenuTick();//Run logic for the menus.
}

void onRender( CRules@ rules )
{
    if(!init) { return; }//Kag renders before onInit. Stop this.

    NuRender::onRender(rules);

}





void addFonts( CRules@ rules, NuHub@ hub)
{
    hub.addFont("Arial", "Arial.png");
    hub.addFont("Calibri", "Calibri-48.png");
    hub.addFont("Calibri-Bold", "Calibri-48-Bold.png");
}