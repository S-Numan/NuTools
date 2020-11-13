#include "NuMenuCommon.as";

array<NuMenu::MenuBasePlus@> buttons();
array<int> namehashes;



void onInit( CRules@ this )
{
    //buttons.push_back(_menus[i]);
    //namehashes.push_back(_menus[i].getNameHash());
}






void onTick( CRules@ this )
{
    u16 i;
    //array<NuMenu::FancyMenu@> gotmenus();
    for(i = 0; i < buttons.size(); i++)
    {
        buttons[i].Tick();
        if(buttons[i].getMenuState() == NuMenu::Released)//Menu itself checking.
        {
            print("release in " + buttons[i].getName());
        }
    }
}

void onRender( CRules@ this )
{
    for(u16 i = 0; i < menus.size(); i++)
    {
        buttons[i].Render();
    }
}