#include "NuMenuCommon.as";

void onInit( CRules@ this )
{
    if(!isClient())
    {
        return;
    }

    print("creation");

    NuMenu::MenuHolder random_menu = NuMenu::MenuHolder(
        Vec2f(64, 64),//Top left
        Vec2f(128 * 2, 128 * 2),//Bottom right
        "TestMenu");//Menu name
    print("just ate the creation. yummy.");

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
    if(option1.getMenuClass() == NuMenu::Button)//While it is known the above is a button, this is just as an example for how to check if it can be casted.
    {
        @button1 = cast<NuMenu::MenuButton@>(option1);//Cast into button1. 
    }
    button1.addReleaseListener(@ButtonTestFunction);//We can now use button functions and all it's derivatives.

    //option1.setOffset(Vec2f(random_menu.getSize().x/2, random_menu.getSize().y - option1.getSize().y));
    random_menu.setOptionalMenuPos(Vec2f(random_menu.getSize().x/2, random_menu.getSize().y - option1.getSize().y), option1);//*/
    //*/
    
    
    NuMenu::addMenuToList(random_menu);



    NuMenu::MenuButton@ to_remove_button = NuMenu::MenuButton(
        Vec2f(720, 720),//Top left
        Vec2f(820, 820),//Bottom right
        "RemoveButtonInit2-WhyAmIBroken");//Menu name
    
    to_remove_button.kill_on_release = true;

    NuMenu::addMenuToList(to_remove_button);
}

void onReload( CRules@ this )
{
    onInit(this);
}
//                    -Caller of button-     -Params-     -Menu pressed-
void ButtonTestFunction(CPlayer@ caller, CBitStream params, NuMenu::IMenu@ menu)
{
    print("function: button was pressed.");
}

void onTick( CRules@ this )
{
   
    if(NuMenu::getMenuListSize() > 0)
    {
        MenuOptionChanger(NuMenu::getMenuFromList(0));
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
            if(controls.isKeyJustPressed(KEY_KEY_D))
            {
                NuMenu::removeMenuFromList(0);
                print("Menu removed");
            }
        }
    }
}