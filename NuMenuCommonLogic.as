//test
#include "NuMenuCommon.as";

array<NuMenu::IMenu@>@ menus;

bool init;

void onInit( CRules@ rules )
{
    init = true;

    array<NuMenu::IMenu@> _menus = array<NuMenu::IMenu@>();

    @menus = @_menus;
    
    rules.set("NuMenus", @menus);

    //rules.get("NuMenus", menus);//Example for getting the menu list.
}

void onReload( CRules@ rules )
{
    onInit(rules);
}

void onTick( CRules@ rules )
{
    NuMenu::onTick(rules);//Important NuMenu things.
    
    NuMenu::MenuTick(@menus);//Run logic for the menus.
}

void onRender( CRules@ rules )
{
    if(!init) { return; }//Kag renders before onInit. Stop this.
    NuMenu::onRender(rules);//Important NuMenu things.
    
    NuMenu::MenuRender(@menus);//Render the menus.
}