#include "NuMenuCommon.as";

array<NuMenu::MenuButton@> buttons(5);


void onInit( CRules@ this )
{
    if(!isClient())
    {
        return;
    }

    print("buttons size = " + buttons.size());
    buttons.clear();
    print("buttons size = " + buttons.size());

    //buttons.push_back(_menus[i]);
    //namehashes.push_back(_menus[i].getNameHash());
}






void onTick( CRules@ this )
{
    if(!isClient())
    {
        return;
    }
    CPlayer@ player = getLocalPlayer();
    if(player == null)
    {
        buttons.clear();
        return;
    }
    CControls@ controls = getControls();
    if(controls == null)
    {
        buttons.clear();
        return;
    }

    u16 i;
    //array<NuMenu::FancyMenu@> gotmenus();
    for(i = 0; i < buttons.size(); i++)
    {
        buttons[i].Tick();
    }

    
}

void onRender( CRules@ this )
{
    if(!isClient())
    {
        return;
    }
    
    for(u16 i = 0; i < buttons.size(); i++)
    {
        buttons[i].Render();
    }
}




