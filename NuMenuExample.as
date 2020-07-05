#include "NuMenuCommon.as";

array<NuMenu::FancyMenu@> menus();
array<int> namehashes;

void onInit( CRules@ this )
{
    array<NuMenu::FancyMenu@> _menus();
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

    NuMenu::FancyMenu button1 = NuMenu::FancyMenu(
        Vec2f(300, 300),//Top left
        Vec2f(700, 360),//Bottom right
        "TestMenu",//Menu name
        NuMenu::CheckBox);//Menu type

    button1.setMiddleText("|Middle text|");
    //Fancy lower
    button1.setLeftText("|Left text|");
    button1.setRightText("|Right text|");
    button1.setImage("GUI/AccoladeBadges.png",//Image name
        19,//Image frame
        18,//Image frame while pressed
        Vec2f(16, 16),//Image frame size
        Vec2f(0.0f, 0.0f));//button1.getMenuSize().y/2 - 16/2));

    _menus.push_back(button1);

    for(u16 i = 0; i < _menus.size(); i++)
    {
        menus.push_back(_menus[i]);
        namehashes.push_back(_menus[i].getNameHash());
    }
}

void onTick( CRules@ this )
{
    u16 i;
    array<NuMenu::FancyMenu@> gotmenus();
    for(i = 0; i < menus.size(); i++)
    {
        menus[i].Tick();
        if(menus[i].getButtonState() == NuMenu::Released)
        {
            gotmenus.push_back(menus[i]);
        }
        else if(menus[i].getButtonState() == NuMenu::FalseRelease)
        {
            //print("false release");
        }
    }

    for(i = 0; i < gotmenus.size(); i++)
    {
        if(gotmenus[i].getNameHash() == "TestMenu".getHash())//namehashes[0])
        {
            print("release in " + gotmenus[i].getName());
        }
        else if(gotmenus[i].getNameHash() == "TestMenu2".getHash())//namehashes[1])
        {
            print("release in " + gotmenus[i].getName());
        }
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
                menus[0].setInterpolation(!menus[0].getInterpolation());
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