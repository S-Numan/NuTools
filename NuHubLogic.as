//This file should go before all other files that use NuMenu in gamemode.cfg

#include "NuMenuCommon.as";
#include "NuTextCommon.as";
#include "NuHub";

bool init;

void onInit( CRules@ rules )
{
    //NuMenu::addMenuToList(buttonhere);//Add buttons like this
    NuHub@ hub = NuHub();

    rules.set("NuHub", @hub);
    
    print("NuHub Loaded");


    NuMenu::onInit(rules);


    if(!init &&//First time init.
        sv_gamemode == "Testing")//Provided the gamemode name is Testing.
    {
        print("=====NuButton.as attempt to add=====");
        rules.AddScript("NuButton.as");//Add the NuButton script to the gamemode.
        print("=====If an error is above, ignore it.=====");
    }

    init = true;
}

void onReload( CRules@ rules )
{
    onInit(rules);
}

void onTick( CRules@ rules )
{
    NuHub@ hub;
    rules.get("NuHub", @hub);

    NuMenu::onTick(rules);//Important NuMenu things.
    
    NuMenu::MenuTick();//Run logic for the menus.
}

void onRender( CRules@ rules )
{
    if(!init) { return; }//Kag renders before onInit. Stop this.

    NuMenu::onRender(rules);//Important NuMenu things.
}