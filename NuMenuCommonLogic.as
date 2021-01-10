//This file should go before all other files that use NuMenu in gamemode.cfg

#include "NuMenuCommon.as";

bool init;

CRulesBad@ rulesbad;

void onInit( CRules@ rules )
{
    NuMenu::onInit(rules);


    init = true;

    CRulesBad@ _rulesbad = CRulesBad();

    rules.set("NuMenus", @_rulesbad);

    rules.get("NuMenus", @rulesbad);
    
    //NuMenu::addMenuToList(buttonhere);//Add buttons like this
}

void onReload( CRules@ rules )
{
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