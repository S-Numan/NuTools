//This file should go before all other files that use NuMenu in gamemode.cfg

#include "NuMenuCommon.as";

bool init;

CRulesBad@ rulesbad;

void onInit( CRules@ rules )
{
    NuMenu::onInit(rules);


    CRulesBad@ _rulesbad = CRulesBad();

    rules.set("NuMenus", @_rulesbad);

    rules.get("NuMenus", @rulesbad);
    
    //NuMenu::addMenuToList(buttonhere);//Add buttons like this


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
    print("NuMenu Reloaded");
    onInit(rules);
}

void onTick( CRules@ rules )
{
    NuMenu::onTick(rules);//Important NuMenu things.
    
    NuMenu::MenuTick(@rulesbad);//Run logic for the menus.
}

void onRender( CRules@ rules )
{
    if(!init) { return; }//Kag renders before onInit. Stop this.
    NuMenu::onRender(rules);//Important NuMenu things.
    
    NuMenu::MenuRender(@rulesbad);//Render the menus.
}