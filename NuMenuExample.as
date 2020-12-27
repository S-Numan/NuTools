#include "NuMenuCommon.as";

array<NuMenu::IMenu@> menus();
array<int> namehashes;

void onInit( CRules@ this )
{
    if(!isClient())
    {
        return;
    }

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
        print("creation");
        NuMenu::MenuHolder random_menu = NuMenu::MenuHolder(
            Vec2f(64, 64),//Top left
            Vec2f(128 * 2, 128 * 2),//Bottom right
            "TestMenu");//Menu name
        print("just ater creation");

        random_menu.default_buffer = 40.0f;

        random_menu.setIsWorldPos(false);

        random_menu.addMenuOption(NuMenu::CheckBox);
        random_menu.setOptionalMenuPos(Vec2f(0, 32), 0);
        
        //random_menu.setFont("AveriaSerif-Bold.ttf", 8);

        random_menu.setText("ZCenter textZ", NuMenu::POSCenter);

        random_menu.setText("ZTop textZ"   , NuMenu::POSTop);
        random_menu.setText("ZAbove textZ" , NuMenu::POSAbove);

        random_menu.setText("ZLeft textZ"  , NuMenu::POSLeft);
        random_menu.setText("ZLefter textZ"  , NuMenu::POSLefter);

        random_menu.setText("ZRight textZ" , NuMenu::POSRight);
        random_menu.setText("ZRighter textZ" , NuMenu::POSRighter);


        random_menu.setText("ZBottom textZ", NuMenu::POSBottom);
        random_menu.setText("ZUnder textZ" , NuMenu::POSUnder);
        

        random_menu.reposition_text = true;


        
        random_menu.setIcon("GUI/AccoladeBadges.png",//Image name
            Vec2f(16, 16),//Image frame size
            19,//Image frame
            18,//Image frame while hovered
            18,//Image frame while presseds
            NuMenu::POSTopLeft);//Position

        //random_menu.reposition_icons = true;

        random_menu.setTitlebarHeight(16.0f);
        //random_menu.setTitlebarWidth(random_menu.getSize().x - 16.0f);

        NuMenu::IMenu@ option1 = random_menu.addMenuOption(NuMenu::Button, Vec2f(30, 40));

        NuMenu::MenuButton@ button1;//We will cast option1 into button1 as an example.
        if(option1.getMenuOption() == NuMenu::Button)//While it is known the above is a button, this is just as an example for how to check if it can be casted.
        {
            button1 = cast<NuMenu::MenuButton@>(option1);//Cast into button1. 
        }
        button1.func = @ButtonTestFunction;//We can now use button functions and all it's derivatives.

        //option1.setRelationPos(Vec2f(random_menu.getSize().x/2, random_menu.getSize().y - option1.getSize().y));
        random_menu.setOptionalMenuPos(Vec2f(random_menu.getSize().x/2, random_menu.getSize().y - option1.getSize().y), option1);//*/

        _menus.push_back(random_menu);

        /*NuMenu::MenuButton menu_button_dunno = NuMenu::MenuButton(Vec2f(64,64), Vec2f(72, 72), "well_then");
        menu_button_dunno.setIsWorldPos(true);

        _menus.push_back(menu_button_dunno);*/
    }

    for(u16 i = 0; i < _menus.size(); i++)
    {
        menus.push_back(_menus[i]);
        namehashes.push_back(_menus[i].getNameHash());
    }
}

void ButtonTestFunction(CBitStream lol)
{
    print("function: button was pressed.");
}

void onTick( CRules@ this )
{
    NuMenu::onTick(this);

    if(!isClient())
    {
        return;
    }

    u16 i;
    //array<NuMenu::FancyMenu@> gotmenus();
    for(i = 0; i < menus.size(); i++)
    {
        if(menus[i] == null)
        {
            continue;
        }
        
        menus[i].Tick();
        if(menus[i].getMenuState() == NuMenu::Released)//Menu itself checking.
        {
            print("release in " + menus[i].getName());
        }
        
        if(menus[i].getNameHash() == "TestMenu".getHash())//Option checking.
        {
            NuMenu::MenuHolder@ menubase = cast<NuMenu::MenuHolder@>(menus[i]);
            NuMenu::IMenu@ _menu = menubase.getOptionalMenu();
            //NuMenu::MenuCheckBox@ _menu = cast<NuMenu::MenuCheckBox@>(menubase.getOptionalMenu());
            if(_menu != null && _menu.getMenuState() == NuMenu::Released)
            {
                print("option checked " + _menu.getName());
            }
            //print("old position of child menu 0 = " + _menu.upper_left_old.x + " " + _menu.upper_left_old.y);
            //print("position of child menu 0 =    " +_menu.getPos().x + " " + _menu.getPos().y);
        }
    }

    
    if(menus.size () > 0)
    {
        MenuOptionChanger(menus[0]);
    }
}

void onRender( CRules@ this )
{
    NuMenu::onRender(this);
    
    for(u16 i = 0; i < menus.size(); i++)
    {
        if(menus[i] == null)
        {
            continue;
        }

        menus[i].Render();
    }
}






void MenuOptionChanger(NuMenu::IMenu@ _menu)
{
    CPlayer@ player = getLocalPlayer();
    if(player != null)
    {
        CControls@ controls = player.getControls();
        if(controls.isKeyPressed(KEY_LCONTROL))
        {
            if(controls.isKeyPressed(KEY_LBUTTON))
            {
                Vec2f _pos;
                if(_menu.isWorldPos())
                {
                    _pos = controls.getMouseWorldPos();
                    //Driver@ driver = getDriver();
                    //_pos += driver.getScreenCenterPos();
                }
                else
                {
                    _pos = controls.getMouseScreenPos();
                }
                _menu.setUpperLeft(_pos);
                print("upperleft mouse = " + _pos);
            }
            if(controls.isKeyPressed(KEY_RBUTTON))
            {
                Vec2f _pos;
                if(_menu.isWorldPos())
                {
                    _pos = controls.getMouseWorldPos();
                }
                else
                {
                    _pos = controls.getMouseScreenPos();
                }

                _menu.setLowerRight(_pos);
                print("lowerright mouse = " + _pos);
            }
            if(controls.isKeyJustPressed(KEY_KEY_X))
            {
                _menu.setInterpolated(!_menu.isInterpolated());
                print("Interpolation of menu = " + _menu.isInterpolated());
            }
            if(controls.isKeyJustPressed(KEY_KEY_Z))
            {
                _menu.setIsWorldPos(!_menu.isWorldPos());
                print("IsWorldPos = " + _menu.isWorldPos());
            }
        }
    }
}