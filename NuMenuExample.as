#include "NuMenuCommon.as";

array<NuMenu::IMenu@> menus();
array<int> namehashes;

void onInit( CRules@ this )
{
    array<NuMenu::IMenu@> _menus();
        /*NuMenu::FancyMenu(
        Vec2f(200, 200),//Top left
        Vec2f(600, 260),//Bottom right
        "TestMenu",//Menu name
        NuMenu::Button,//Menu option
        "GUI/AccoladeBadges.png",//Image name
        19,//Image frame
        18,//Image frame while pressed
        Vec2f(16, 16),//Icon frame size
        4,//Image distance from left.
        20,//left_text distance from left
        "on left|",//Left text
        "|on right",//Right text
        "menu",//font
        "|Middle text|")//Middle text
        /*,
        
        NuMenu::FancyMenu(
        Vec2f(600, 260),//Top left
        Vec2f(1200, 320),//Bottom right
        "TestMenu2",//Menu name
        NuMenu::Button,//Menu option
        "GUI/AccoladeBadges.png",//Image name
        18,//Image frame
        19,//Image frame while pressed
        Vec2f(16, 16),//Icon frame size
        4,//Image distance from left.
        20,//left_text distance from left
        "on left|",//Left text
        "|on right",//Right text
        "menu",//font
        "|Middle text|")//Middle text
        */

    {
        NuMenu::MenuHolder random_menu = NuMenu::MenuHolder(
            Vec2f(300, 300),//Top left
            Vec2f(700, 360),//Bottom right
            "TestMenu");//Menu name

        random_menu.setIsWorldPos(true);

        random_menu.addMenuOption(NuMenu::CheckBox);

        random_menu.setMiddleText("|Middle text|");
        //Fancy lower
        random_menu.setLeftText("|Left text|");
        random_menu.setRightText("|Right text|");
        random_menu.setImage("GUI/AccoladeBadges.png",//Image name
            19,//Image frame
            18,//Image frame while pressed
            Vec2f(16, 16),//Image frame size
            Vec2f(0.0f, 0.0f));//button1.getMenuSize().y/2 - 16/2));

        random_menu.setTitlebarHeight(16.0f);
        //random_menu.setTitlebarWidth(random_menu.getMenuSize().x - 16.0f);

        NuMenu::IMenu@ option1 = random_menu.addMenuOption(NuMenu::Button, Vec2f(30, 40));
        option1.setRelationPos(Vec2f(random_menu.getMenuSize().x/2, random_menu.getMenuSize().y - option1.getMenuSize().y));
        random_menu.moveMenuAttachments();

        _menus.push_back(random_menu);
    }

    for(u16 i = 0; i < _menus.size(); i++)
    {
        menus.push_back(_menus[i]);
        namehashes.push_back(_menus[i].getNameHash());
    }
}

void onTick( CRules@ this )
{
    u16 i;
    //array<NuMenu::FancyMenu@> gotmenus();
    for(i = 0; i < menus.size(); i++)
    {
        menus[i].Tick();
        if(menus[i].getMenuState() == NuMenu::Released)//Menu itself checking.
        {
            print("release in " + menus[i].getName());
        }
        
        //if(menus[i].getNameHash() == "TestMenu".getHash())//Option checking.
        //{
            NuMenu::MenuHolder@ menubase = cast<NuMenu::MenuHolder@>(menus[i]);
            NuMenu::IMenu@ _menu = menubase.getOptionalMenu();
            if(_menu.getMenuState() == NuMenu::Released)
            {
                print("option checked " + _menu.getName());
            }
        //}
    }

    CPlayer@ player = getLocalPlayer();
    if(player != null)
    {
        CControls@ controls = player.getControls();
        if(controls.isKeyPressed(KEY_LCONTROL))
        {
            if(controls.isKeyPressed(KEY_LBUTTON))
            {
                menus[0].setUpperLeft(controls.getMouseScreenPos());
            }
            if(controls.isKeyPressed(KEY_RBUTTON))
            {
                menus[0].setLowerRight(controls.getMouseScreenPos());
            }
            if(controls.isKeyJustPressed(KEY_KEY_X))
            {
                menus[0].setInterpolated(!menus[0].getInterpolated());
            }
        }
    }

}

void onRender( CRules@ this )
{
    for(u16 i = 0; i < menus.size(); i++)
    {
        menus[i].Render();
    }
}