#include "NuMenuCommon.as";

u16 QUICK_PICK = 7;//Quickly tap e and let go before QUICK_PICK ticks pass to pick the closest button.

array<NuMenu::MenuButton@>@ buttons;

bool init = false;
void onInit( CRules@ rules )
{
    if(!isClient())
    {
        return;
    }
    init = true;

    array<NuMenu::MenuButton@> _buttons = array<NuMenu::MenuButton@>();
    @buttons = @_buttons;

    //buttons.push_back(_menus[i]);
    //namehashes.push_back(_menus[i].getNameHash());

    rules.set("CustomButtons", @buttons);
    
}




u16 e_key_time = 0;
u16 e_key_time_old = e_key_time;

void onTick( CRules@ rules )
{
    NuMenu::onTick(rules);
    
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
    CBlob@ blob = player.getBlob();
    
    bool e_key_release = false; 

    if(controls.isKeyPressed(KEY_KEY_E))
    {
        e_key_time_old = e_key_time;
        e_key_time++;
    }
    else if (e_key_time != 0)
    {
        e_key_time = 0;
        e_key_release = true;
    }
    else
    {
        e_key_time_old = 0;
    }



    u16 i;
    if(blob != null)
    {
        u16 KEY;
        
        if(e_key_release)//On release of the e key
        {
            KEY = KEY_KEY_E;
        }
        else//What normally happens
        {
            KEY = KEY_LBUTTON;
        }
        
        for(i = 0; i < buttons.size(); i++)
        {
            if(buttons[i] == null)
            {
                error("how");
                continue;
            }    
            
            if(e_key_release){buttons[i].initial_press = true;}
            buttons[i].Tick(KEY, controls.getMouseScreenPos(), blob.getPosition());

            if(buttons[i].getMenuState() == NuMenu::Released)
            {
                if(buttons[i].kill_on_press)
                {
                    buttons.removeAt(i);
                }
                break;
            }
            else if(e_key_release)
            {
                buttons[i].initial_press = false;
                buttons[i].button_state = NuMenu::Idle;
            }
        }

        //Quick pass through
        if(i == buttons.size()//If all buttons have been gone through and none of them released upon.
        && e_key_release && e_key_time_old < QUICK_PICK && buttons.size() > 0)
        {
            //Sort array 
            array<float> distances(buttons.size());

            i = 0;
            int j;
            int N = buttons.size();

            for(j = 0; j < N; j++)
            {
                distances[j] = buttons[j].getDistance(blob.getPosition(), buttons[j].getPos(true) + buttons[j].getSize() / 2);
            }
            if(buttons.size() == 1)//No need to sort only one button
            {
                for (j=1; j<N; j++)
                {
                    for (i=j; i>0 && distances[i] < distances[i-1]; i--)
                    {
                        NuMenu::MenuButton@ _buttontemp;
                        float temporary;

                        temporary = distances [i];
                        _buttontemp = buttons[i];
                        distances [i] = distances [i - 1];
                        buttons[i] = buttons[i - 1];
                        distances [i - 1] = temporary;
                        buttons[i - 1] = _buttontemp;
                    }
                }
            }

            for(i = 0; i < buttons.size(); i++)
            {
                if (buttons[i].enableRadius == 0.0f || distances[i] < buttons[i].enableRadius)
                {
                    buttons[i].sendCommand();
                    buttons[i].button_state = NuMenu::Released;
                    break;
                }
            }
            //Sort with the closest on the bottom of the array farthest at the top.
        }
        //Quick pass
    }


    if(e_key_release && buttons.size() != 0)//Tick after e key release
    {
        buttons.clear();
    }
}

void onRender( CRules@ rules )
{   
    if(!init){return;}
    NuMenu::onRender(rules);

    for(u16 i = 0; i < buttons.size(); i++)
    {
        if(buttons[i] == null)
        {
            continue;
        }
        buttons[i].Render();
    }
}

void onRestart(CRules@ rules)
{
    onInit(rules);
}

void onReload( CRules@ rules )
{
    onRestart(rules);
}
















//GetButtonsFor() example
/*
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (!canSeeButtons(this, caller)) { return; }

    const float MAX_DISTANCE = 16;//Max distance the button can be from the caller. Any further and the button wont show up.

	if (//caller.getTeamNum() != this.getTeamNum() ||//Uncomment if team only.
        this.getDistanceTo(caller) > MAX_DISTANCE) { return; }//Max distance button is allowed from the caller.

    NuMenu::MenuButton@ button = NuMenu::MenuButton("", this);//Name of the button, and the button's owner. The button will automatically follow the owner unless specified not to.
    
    button.kill_on_press = true;//The button will be removed on press. (logic for this happens outside the button class)
    button.instant_press = true;//Button is Pressed when hovering over. Button is instantly released upon pressing.

    button.setSize(Vec2f(8, 8));//Size of button. Changes how large the button is. Larger buttons are easier to press.
    button.setRelationPos(-(button.getSize() / 2));//Where the button is in relation to it's OwnerBlob. This should center the button directly on the blob.

    button.setImage("UI/ButtonIcons.png",//Image name
            0,//Image frame
            1,//Image frame while pressed
            Vec2f(16, 16),//Image frame size
            Vec2f(0.0f, 0.0f));//Image position

    button.image_pos = button.image_frame_size / 2;//Where the image is on the button


    //CBitStream params;//Params sent when the button is pressed.
    //params.write_u16(caller.getNetworkID());//The caller, I.E the player blob is added as a param.
    //button.params = params;//Set params
    button.command_string = "activate";//This command will be sent to this blob when this button is pressed.
    //button.send_to_rules = true;//If this is true, instead of sending the command to OwnerBlob, the the command will be sent to CRules.
            
    //button.TODO(getTranslatedString("Open"));//Description placed under the button

    button.enableRadius = 32.0f;//How close you have to be to press the button. Out of this distance the button is greyed out and unpressable.
    button.Tick(caller.getPosition());//Tick button once to initially set the button state. For example if the button is out of range this will instantly tell the button to be greyed. Without this the button with be normal for a tick.

    array<NuMenu::MenuButton@>@ buttons;//Init array.
    getRules().get("CustomButtons", @buttons);//Grab array.
    buttons.push_back(button);//Put button in CustomButtons array.
}

*/
