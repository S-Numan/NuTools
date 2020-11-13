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