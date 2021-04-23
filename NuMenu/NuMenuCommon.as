#include "NumanLib.as";
#include "NuHub.as";
#include "NuTextCommon.as";


namespace NuMenu
{

    /*Menu that looks like this

         |
    -----|----------------------------------|
>   image| itemname description cost/amount |
    -----|----------------------------------|
    image| left text             right text |
    -----|----------------------------------|
         |
    
select which menu you want
change where the cursor > is by pressing down or up or hover over something with your mouse. Option to disable up and down to navigate and have it only be by mouse.
Allow the color to be changed
Allow the menu to be horizontal instead.
Allow the menu to be squished to only have the image. (most importantly for horizontal)
Option to not use an image
Buffer between buttons
Left right arrow togglable option for right_text
Check mark option on right


*/
//
//TODO LIST
//


//add params to Tick? such as Tick(CControls controls)
//fix text/font size changing//Copy and paste several font files and fix text
//Stretchy ends for MenuBaseExEx. Drag the menu size around.
//Take another look at reposition_text. Optimise perhaps. Perhaps not. Improve it somehow, maybe.
//Make more things in MenuBase methods for IMenu.
//Stop button spazz when pushed against terrain with owner blob. Blob pos freaks out when attached to user while pushing against wall. Try an attachment point? Maybe try making your own with nothing on it to see if it smooths it. Use CShape pos?
//Confirm the distance calculation with buttons isn't that wonky. It feels wonky. Something has to be wonky
//Rotate value. Only for if I'm really bored. Since it probably wont ever get used. Plus you cannot rotate GUI.
//Editable text while the game is running. Think naming something.
//See if the icon repositioning is actually required for CustomButton.as stuff. Figure out how to not make it required if it is. It shouldn't be.
//Test does not reposition when not interpolated. Look into this
//Menu opening/closing animations. Full animations that you can put in a sprite sheet and configure.
//Check if the camera moved, put info in transporter.
//Rapid button pressing does not work.
//Don't setMenuMoved(true) if no positions actually changed.
//Moving interpolated when camera is moving isWorldPos(). it's shakey atm.
//Add scale x/y to button, make it work with NuImage scale of course.
//Remove the titlebar and replace with with an actual menu.//X button on titlebar that closes the menu.
//Have values for the first part of a sprite. The middle part. And the end part. Modify NuImage for this.
//Make setting to world pos actually set the upper left and lower right to the correct positions to not look like the menu changed position.
//Make an option to make the menu animated. Animation frames and how fast they loop through. See cfg animations. Maybe add it to NumanLib NuImage?


//Option list for debugging blobs.
//Surround blobs in a red box.
//Clicking a blob selects it and shows it's info. OR always show info.
//Type in tags to show details of those tags.



//1. Before the first tick, the checkbox in menuholder runs away from it's owner. Fix plz.
//2. Remake text. All text. Add shaky text. And different color text for each induvidual letter.
//3. Fix button rendering to render like it should. Not just via a method, but a render script.

//
//TODO LIST
//

    //Actual classes.
    shared enum MenuClasses
    {
        MenuClassNotSet,//When you haven't set the class.

        BaseClass,//TODO comment
        
        BaseExClass,//TODO comment
        
        BaseExExClass,//TODO comment

        ButtonClass,//Press a button. Buttons have many states. Catch em all!
        
        SliderClass,//Slide a slider left and right. Choose color of each side. Increments instead of smoothness is possible too. Both vertical and horizontal. Option to act more like the traditional kag heart system instead of a bar.
        //Start and end percentage points
        //Option to drag if held or only move if pressed once. Options to drag the start, end, or both points at once. And only while within?
        //Left/right top/down buttons. (buttons appaer to the left and right of the slider. Can press to move slider.)
        //Can cut texture in half or other amounts to display exact loss of health.

        //CheckBox,//Remove my class. Replace with button

        TextWriterClass,//Features such as slowly writing in text. Scrollable text is not drawn if it goes under the menu. If this happens, a scrollbar will appear. (Slider basically)

        HolderClass,//Holds their child menus and spoils them by positioning them to themself without extra work.

        GridClass,//Works like the holder class, but has an array of holders to hold children below/above them.

        MenuClassesCount,//Always last, this specifies the amount of menu classes.
    }

    shared enum MenuConfiguration//Configuration for specific classes. For example you can have a Slider with the On off configuration or the Statusbar configuration.
    {   
        //TODO, figure out how to make an auto-configeration system for slider and other classes. Maybe a global method or something. Make a method that allows you to pick the cofiguration you want too.
        //New -> Create a new file, add auto configs there as methods. Each method has the same name but a different argument type. The IMenu input type checks what class it is, then refers to the correct method.

        //Any
        Custom = MenuClassesCount + 1,//To prevent accidently using MenuClasses or MenuConfiguration when the other is required, this is done.

        //Slider
        StatusBar,//Give a max value and current value. Choose color of each side. This works like a Slider but is automatically configured for ease of use. No draggy bit.
        OnOffSwitch,//Slider between 0 and 1. Increments by 0 and 1.
        TraditionalSlider,//(E.G choose a circle. 1-5 circles. 2 and a half health would only fill two and a half circles.)
        
        //Button
        CheckBox,//Button: Press once and the button is pressed. Press again and the button is unpressed.
        
        //TextWriter
        InputText,//Click this box, and you can type in text! Other options for selecting too.

        //Holder
        DropDownOptions,//Click this box to get a bunch of different boxes below it. It places other menus right below itself plus buffer then another menu below that using the y sizes of the menu added.
        //Can choose if this menu opens up or down.
        //Slider to scroll through options provided there is not enough space for all them to display.
        //Can have automatically open. With no close/open button. Just already showing a list.
        
        Tabs,//Below a possible titlebar, you get options to select that open a certain menu below. like -> |Lettuce|  |Shoes|  |Frogs|  . Select an option get get a menu below/above it and unselect the other options.
    }

    shared enum ButtonState
    {
        Idle,//Mouse is scared of button. Is not near and has not touched.
        Hover,//Mouse is hovering over the button without doing anything. The mouse has anxiety of what will happen if it touches the button.
        JustHover,//Mouse has only just started stalking this button.
        UnHover,//Mouse has just stopped stalking this button, a shame.
        JustPressed,//Mouse just pressed the button. The mouse says "Hello!" to the button.
        Pressed,//Mouse is currently pressing the button. Good job mouse.
        Selected,//Mouse has touched this button first, but is still nervous and is not over the button. Still holding left mouse button though.
        Released,//Mouse has released while over the button. ( ͡° ͜ʖ ͡°)
        FalseRelease,//Mouse released while not over the button. (when the ButtonState was Selected and the mouse let go)
        AfterRelease,//This happens after the button has been released on. However, if the mouse is still pressing down on the button on the next tick, the button must stay in this state and cannot escape this state until the mouse stops pressing it about government conspiracies. 
        Disabled,//The mouse has shown dominance over the button by breaking it's knees with a crowbar
        
        ButtonStateCount,//Always last, this specifies the amount of button states.
    }

    shared SColor DebugColor(u16 state)//Debug color on each button state. For debugging.
    {
        SColor rec_color;
        switch(state)
        {
            case Idle:
                rec_color = SColor(255, 200, 200, 200);
                break;
            case Hover:
                rec_color = SColor(255, 70, 50, 25);
                break;
            case JustHover:
                rec_color = SColor(255, 100, 100, 100);
                break;
            case UnHover:
                rec_color = SColor(255, 255, 25, 25);
                break;
            case Selected:
                rec_color = SColor(255, 30, 50, 25);
                break;
            case FalseRelease:
                rec_color = SColor(255, 30, 50, 255);
                break;
            case AfterRelease:
                rec_color = SColor(255, 50, 50, 50);
                break;
            case Pressed:
                rec_color = SColor(255, 127,25,25);
                break;
            case Released:
                rec_color = SColor(255, 25,127,25);
                break;
            case Disabled:
                rec_color = SColor(255, 5, 5, 5);
                break;
            default:
                rec_color = SColor(255, 255, 255, 255);
                break;
        }

        return rec_color;
    }

    shared interface IMenu
    {
        void initVars();
        void afterInitVars(string _name, u8 _menu_config, Vec2f _upper_left = Vec2f(0,0), Vec2f _lower_right = Vec2f(0,0));

        u32 getTicksSinceCreated();

        void KillMenu();
        bool getKillMenu();

        string getName();
        int getNameHash();
        void setName(string value);

        IMenu@ getOwnerMenu();
        bool setOwnerMenu(IMenu@ _menu);
        CBlob@ getOwnerBlob();
        bool setOwnerBlob(CBlob@ _blob);
        bool getMoveToOwner();
        void setMoveToOwner(bool value);

        u8 getMenuConfig();
        void setMenuConfig(u8 value);
        u8 getMenuClass();
        //void setMenuClass(u8 value);//Don't touch this.

        u8 getMenuState();
        u8 getButtonState();
        void setButtonState(u8 _button_state);
        void setMenuState(u8 _button_state);

        void setTicksSinceStateChange(u32 value);
        u32 getTicksSinceStateChange();

        bool isWorldPos();
        void setIsWorldPos(bool value);

        bool getRenderBackground();
        void setRenderBackground(bool value);

        bool isInterpolated();
        void setInterpolated(bool value);

        Vec2f getUpperLeftInterpolated();//Gets the interpolated upper left
        Vec2f getPosInterpolated();//Gets the upper left interpolated.
        Vec2f getUpperLeft(bool get_raw_pos = false);
        void setUpperLeft(Vec2f value, bool menu_just_move = true);//Assigning menu_just_move to false will tell the menu that nothing moved. No other positions should update, no sound, nothing should change besides the position.
        Vec2f getPos(bool get_raw_pos = false);
        void setPos(Vec2f value, bool menu_just_move = true);
        Vec2f getMiddle(bool get_raw_pos = false);
        Vec2f getLowerRightInterpolated();
        Vec2f getLowerRight(bool get_raw_pos = false);
        void setLowerRight(Vec2f value, bool menu_just_move = true);
        Vec2f getSize();
        void setSize(Vec2f value);

        Vec2f getUpperLeftOld(bool get_raw_pos = false);
        Vec2f getLowerRightOld(bool get_raw_pos = false);

        bool didMenuJustMove();
        void setMenuJustMoved(bool value);

        Vec2f getOffset();
        void setOffset(Vec2f value);

        Vec2f getCollisionUpperLeft(bool get_raw_pos = false);
        Vec2f getCollisionLowerRight(bool get_raw_pos = false);
        void setCollisionUpperLeft(Vec2f value);
        void setCollisionLowerRight(Vec2f value);
        bool getCollisionSetter();
        void setCollisionSetter(bool value);

        f32 getRadius();
        void setRadius(f32 value);

        bool isPointInMenu(Vec2f value);

        bool Tick();

        void InterpolatePositions();
        
        void setRenderFunction(RENDER_CALLBACK@ value);
        RENDER_CALLBACK@ getRenderFunction();
        bool DefaultRenderCaller();
        
        array<Nu::NuImage@> getBackgrounds();
        Nu::NuImage@ getBackground(u16 element);
        void addBackground(Nu::NuImage@ _background);
        void removeBackground(u16 element);
        void clearBackgrounds();

        Render::ScriptLayer getRenderLayer();
        void setRenderLayer(Render::ScriptLayer value);

        bool Render();

    }

    funcdef bool RENDER_CALLBACK();//NuMenu::IMenu@ menu);//Kag just refuses to include this parameter

    //Base of all menus.
    class MenuBase : IMenu
    {
        MenuBase(string _name, u8 _menu_config = NuMenu::Custom)// add default option for world pos/screen pos? - Todo numan
        {
            if(!isClient())
            {
                return;
            }

            initVars();
            afterInitVars(_name, _menu_config);
            
            setMenuClass(BaseClass);
        }
        
        MenuBase(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_config = NuMenu::Custom)// add default option for world pos/screen pos? - Todo numan
        {
            if(!isClient())
            {
                return;
            }

            initVars();
            afterInitVars(_name, _menu_config, _upper_left, _lower_right);
            
            setMenuClass(BaseClass);
        }

        void initVars()
        {
            if(!getRules().get("NuHub", @transporter))
            {
                error("NuHubLogic.as must be before anything else that uses NuMenu in gamemode.cfg");
            }

            ticks_since_created = 0;

            default_buffer = 4.0f;
            is_world_pos = false;

            kill_menu = false;

            name = "";
            name_hash = 0;

            @owner_menu = @null;
            @owner_blob = @null;
            move_to_owner = true;

            button_state = Idle;

            ticks_since_state_change = 0;

            render_background = true;

            did_menu_just_move = false;

            upper_left = array<Vec2f>(4);
            lower_right = array<Vec2f>(4);

            collision_setter = true;

            radius = 0.0f;

            @render_func = @RENDER_CALLBACK(DefaultRenderCaller);

            render_layer = Render::layer_prehud;
        
            backgrounds = array<Nu::NuImage@>();
        }

        void afterInitVars(string _name, u8 _menu_config ,Vec2f _upper_left = Vec2f(0,0), Vec2f _lower_right = Vec2f(0,0))
        {
            Nu::NuImage@ _background = Nu::NuImage(ButtonStateCount);
            _background.CreateImage("testy_testers", "RenderExample.png");
            _background.setFrameSize(Vec2f(32, 32));
            for(u16 i = 0; i < ButtonStateCount; i++)
            {
                _background.color_on[i] = DebugColor(i);
            }
            
            addBackground(_background);
    

            setUpperLeft(_upper_left, false);
            setLowerRight(_lower_right, false);

            setInterpolated(true);

            setMenuJustMoved(true);

            setName(_name);

            setMenuConfig(_menu_config);
        }

        u32 ticks_since_created;
        u32 getTicksSinceCreated()
        {
            return ticks_since_created;
        }

        NuHub@ transporter;

        float default_buffer;
        float getDefaultBuffer()
        {
            return default_buffer;
        }
        void setDefaultBuffer(float value)
        {
            default_buffer = value;
        }

        private bool kill_menu;

        void KillMenu()
        {
            kill_menu = true;
        }
        bool getKillMenu()
        {
            return kill_menu;
        }

        //
        //World
        //

        private bool is_world_pos;//If this is true, this works on worldpos. If this is false, this works like normal gui (on ScreenPos). I.E move with camera or not. TODO

        bool isWorldPos()
        {
            return is_world_pos;
        }

        void setIsWorldPos(bool value)
        {
            is_world_pos = value;
            setUpperLeft(upper_left[0]);
            setLowerRight(lower_right[0]);
        }
        
        //
        //World 
        //


        //
        //Name stuff
        //

        private string name;//Name of the menu. (for figuring out what menu was pressed and doing it's logic)
        private int name_hash;//Hash of name. To make things run faster.

        string getName()
        {
            return name;
        }

        int getNameHash()
        {
            return name_hash;
        }

        void setName(string value)
        {
            name = value;
            name_hash = name.getHash();
        }
        
        //
        //Name stuff
        //


        //
        //Owners
        //

        //Menu
        //

        private IMenu@ owner_menu;//The owner of this menu, usually the one that spawned this menu in.
        IMenu@ getOwnerMenu()
        {
            return owner_menu;
        }
        bool setOwnerMenu(IMenu@ _menu)//Be aware, when this menu is moving with it's owner setPos stuff will not do much. You need to change setOffset. As in offset to it's owner.
        {
            if(_menu.getNameHash() == getNameHash())
            {
                error("Tried to make menu its own owner.");
                return false;
            }
            if(_menu.getOwnerMenu() != @null && _menu.getOwnerMenu().getNameHash() == getNameHash())
            {
                error("Tried to intertwine ownership of menus.");
                return false;
            }
            if(getOwnerBlob() != @null)
            {
                error("You cannot have both a menu and blob as an owner at the same time.");
                return false;
            }

            @owner_menu = @_menu;
            return true;
        }

        //
        //Menu

        //Blob
        //

        private CBlob@ owner_blob;//The owner of this menu, usually the one that spawned this menu in.
        CBlob@ getOwnerBlob()
        {
            return owner_blob;
        }
        bool setOwnerBlob(CBlob@ _blob)//Be aware, when this menu is moving with it's owner setPos stuff will not do much. You need to change setOffset. As in offset to it's owner.
        {
            if(getOwnerMenu() != @null)
            {
                error("You cannot have both a menu and blob as an owner at the same time.");
                return false;
            }

            @owner_blob = @_blob;
            return true;
        }

        //Blob
        //

        private bool move_to_owner;//If this is true, this menu will move itself to the position of it's owner with offset added to it. 
        bool getMoveToOwner()
        {
            return move_to_owner;
        }
        void setMoveToOwner(bool value)
        {
            move_to_owner = value;
        }

        //
        //Owners
        //



        //
        //Options and States
        //

        private u8 menu_class;
        u8 getMenuClass()
        {
            if(menu_class == MenuClassNotSet)
            {
                error("menu_class not set");
            }
            
            return menu_class;
        }
        void setMenuClass(u8 value)
        {
            menu_class = value;
        }

        private u8 menu_config;//Menu config.
        u8 getMenuConfig()
        {
            return menu_config;
        }
        void setMenuConfig(u8 value)
        {
            menu_config = value;
        }


        private u8 button_state;//State of button (being pressed? mouse is hovered over?)
        u8 getMenuState()
        {
            return button_state;
        }
        u8 getButtonState()
        {
            return button_state;
        }
        void setButtonState(u8 _button_state)
        {
            if(_button_state >= ButtonStateCount)
            {
                error("STOP! YOU HAVE VIOLATED THE LAW! PAY THE COURT A FINE OR SERVE YOUR SENTENCE. YOUR HIGHER THAN POSSIBLE BUTTON STATE IS NOW FORFEIT"); return;
            }
            if(_button_state == button_state)
            {
                warning("Warning: Button state was set to the same button state the menu is. This should in most cases not happen. Please don't set the button state to the same state the menu is."); return;
            }
            
            button_state = _button_state;
        
            setTicksSinceStateChange(0);
        }
        void setMenuState(u8 _button_state)
        {
            setButtonState(_button_state);
        }

        private u32 ticks_since_state_change;
        void setTicksSinceStateChange(u32 value)
        {
            ticks_since_state_change = value;
        }
        u32 getTicksSinceStateChange()
        {
            return ticks_since_state_change;
        }

        private bool button_interpolation;
        bool isInterpolated()
        {
            return button_interpolation;
        }
        void setInterpolated(bool value)
        {
            if(value)
            {
                upper_left[2] = getUpperLeft();//set interpolated
                lower_right[2] = getLowerRight();//set interpolated
                upper_left[1] = getUpperLeft();//set old
                lower_right[1] = getLowerRight();//set old
            }
            button_interpolation = value;
        }

        //
        //Options and States
        //


        //
        //Positions
        //


        //Normal Positions
        //

        private array<Vec2f> upper_left;//Upper left of menu. [0] is normal; [1] is old; [2] is interpolated; [3] is collision 
        Vec2f getUpperLeft(bool get_screen_pos = false)//If this bool is true, this menu will always get screen position regardless of if it's world pos or screen pos.
        {
            if(isWorldPos() && get_screen_pos)
            {
                //CCamera@ camera = getCamera();
                //This might be slow. - Todo numan
                return getDriver().getScreenPosFromWorldPos(upper_left[0]);
            }
            
            return upper_left[0];
        }
        void setUpperLeft(Vec2f value, bool menu_just_move = true)
        {
            upper_left[0] = value;
            menu_size = Vec2f(lower_right[0].x - upper_left[0].x, lower_right[0].y - upper_left[0].y);
            if(getCollisionSetter())//If the collision setter is not disabled.
            {
                upper_left[3] = Vec2f_zero;//Reset collisinos
            }

            setMenuJustMoved(menu_just_move);
        }

        //Changes the upper left position and lower right at the same time. No changes to the size of the menu.
        void setPos(Vec2f value, bool menu_just_move = true)
        {
            upper_left[0] = value;
            lower_right[0] = upper_left[0] + menu_size;

            setMenuJustMoved(menu_just_move);
        }
        Vec2f getPos(bool get_screen_pos = false)
        {
            return getUpperLeft(get_screen_pos);
        }

        //Not in relation to the menu
        Vec2f getMiddle(bool get_screen_pos = false)
        {
            if(isWorldPos() && get_screen_pos)//If isWorldPos and we aren't getting a raw pos. (I.E convert world to screen)
            {
                return getDriver().getScreenPosFromWorldPos(getUpperLeft() + (getSize() / 2));//Get the world pos upper left, then add the size divided by two to it. Then convert it to screen pos. 
            }
            else
            {
                return getUpperLeft(get_screen_pos) + (getSize() / 2);//Add the size divided by two.
            }
        }

        private array<Vec2f> lower_right(3);//Lower right of menu. [0] is normal; [1] is old; [2] is interpolated; [3] is collision
        Vec2f getLowerRight(bool get_screen_pos = false)//If this bool is true; even if isWorldPos() is true, it will get the raw position. I.E in most cases the actual world position. not the world to screen pos. does nothing if isWorldPos is false.
        {
            if(isWorldPos() && get_screen_pos)
            {
                return getDriver().getScreenPosFromWorldPos(lower_right[0]);
            }

            return lower_right[0];
        }
        void setLowerRight(Vec2f value, bool menu_just_move = true)
        { 
            lower_right[0] = value;
            menu_size = Vec2f(lower_right[0].x - upper_left[0].x, lower_right[0].y - upper_left[0].y);

            if(getCollisionSetter())//If the collision setter is not disabled.
            {
                lower_right[3] = menu_size;//Reset collisinos
            }

            setMenuJustMoved(menu_just_move);
        }

        

        private Vec2f menu_size;//The size of the menu. How far it takes for top_left to get to lower_right. In relation to the menu
        Vec2f getSize()
        {
            return menu_size;
        }
        void setSize(Vec2f value)//Changes the length of the lower_right pos to make it the correct size.
        {
            setLowerRight(upper_left[0] + value);
        }

        //
        //Normal Positions


        //Old Positions
        //

        Vec2f getUpperLeftOld(bool get_screen_pos = false)
        {
            if(isWorldPos() && get_screen_pos)
            {
                return getDriver().getScreenPosFromWorldPos(upper_left[1]);
            }
            
            return upper_left[1];
        }
        Vec2f getLowerRightOld(bool get_screen_pos = false)
        {
            if(isWorldPos() && get_screen_pos)
            {
                return getDriver().getScreenPosFromWorldPos(lower_right[1]);
            }
            
            return lower_right[1];
        }

        private bool did_menu_just_move;
        //Checks if the button just moved. If the old position is not equal to the new position, the button just moved. The button growing counts as moving.
        bool didMenuJustMove()
        {
            return did_menu_just_move;
        }
        void setMenuJustMoved(bool value)
        {
            did_menu_just_move = value;
            if(value)
            {
                for(u16 i = 0; i < backgrounds.size(); i++)
                {
                    backgrounds[i].setPointLowerRight(getSize());
                }
            }
        }

    

        //
        //Old Positions

        //Offset positions
        //

        private Vec2f offset;//For moving this in relation to something else

        Vec2f getOffset()
        {
            return offset;
        }
        void setOffset(Vec2f value)
        {
            offset = value;
            setMenuJustMoved(true);//Not sure if this should be here.
        }

        //
        //Offset positions

        //Collisions
        //
        

        //Not in relation to the menu.
        Vec2f getCollisionUpperLeft(bool get_screen_pos = false)
        {
            if(isWorldPos() && get_screen_pos)
            {
                return getDriver().getScreenPosFromWorldPos(upper_left[0] + upper_left[3]);
            }

            return upper_left[0] + upper_left[3];//Top left of the menu plus the top left collision position.
        }
        Vec2f getCollisionLowerRight(bool get_screen_pos = false)
        {
            if(isWorldPos() && get_screen_pos)
            {
                return getDriver().getScreenPosFromWorldPos(upper_left[0] + lower_right[3]);
            }
            
            return upper_left[0] + lower_right[3];//Top left of the menu plus the lower right collision position. (usually menu_size)
        }

        //In relation to the menu.
        void setCollisionUpperLeft(Vec2f value)
        {
            upper_left[3] = value;
        }
        void setCollisionLowerRight(Vec2f value)
        {
            lower_right[3] = value;
        }
        
        //If this is false, the collision will not be automatically set to the regular upper_left sizes.
        private bool collision_setter;
        bool getCollisionSetter()
        {
            return collision_setter;
        }
        void setCollisionSetter(bool value)
        {
            collision_setter = value;
        }


        private f32 radius;
        f32 getRadius()
        {
            return radius;
        }
        void setRadius(f32 value)
        {
            radius = value;
        }


        
        //
        //Collisions



        //
        //Positions
        //


        //
        //Checks
        //

        bool isPointInMenu(Vec2f value)//Is the vec2f value within the menu?
        {
            if((getCollisionUpperLeft() != Vec2f_zero || getCollisionLowerRight() != Vec2f_zero)//If there is a collision box.
            && value.x <= getCollisionLowerRight().x
            && value.x >= getCollisionUpperLeft().x 
            && value.y <= getCollisionLowerRight().y
            && value.y >= getCollisionUpperLeft().y)
            {
                return true;//Yes
            }
            else if(getRadius() != 0.0f)//Try checking for radius instead
            {
                if(Nu::getDistance(getMiddle(), value) < getRadius()//If the distance between the middle and value is less than the radius
                * (isWorldPos() ? 0.75 : 1))//That is multiplied by 0.75 if isWorldPos is true to keep them lining up. TODO replace with scale system.
                {
                    return true;//Yes but radius.
                }
            }
            return false;//No
        }

        //
        //Checks
        //


        //
        //Logic
        //

        //Always change positions AFTER this method.
        bool Tick()
        {
            if(!isClient())//This is for clients only.
            {
                error("Menu class Tick method was ran on server. This shouldn't happen.");
                return false;//Inform anything that uses this method that something went wrong.
            }

            if(getTicksSinceCreated() == 0)//Menu just created. First tick
            {
                //setMenuJustMoved(true);//I have no idea why, but if the menu does not tick right after being created, the background size will be at (0,0) and as such is invisible. This fixes that. But first, figure out why.
            }

            if(didMenuJustMove())//If the menu just moved
            {
                setMenuJustMoved(false);//Well it didn't just move anymore.
            }

            //Set the interpolated values to the positions.
            upper_left[2] = getUpperLeft();
            lower_right[2] = getLowerRight();

            //And make the old be equal to the new.
            upper_left[1] = getUpperLeft();
            lower_right[1] = getLowerRight();


            //Automatically move to blob if there is an owner blob and getMoveToOwner is true.
            CBlob@ _owner_blob = getOwnerBlob();
            if(_owner_blob != @null && getMoveToOwner())
            {
                if(isWorldPos())
                {
                    setPos(_owner_blob.getPosition() + getOffset());
                }
                else//Screen pos
                {
                    setPos(getDriver().getScreenPosFromWorldPos(_owner_blob.getPosition()) + getOffset());
                }
            }


            //One more tick has passed since the state was changed.
            setTicksSinceStateChange(getTicksSinceStateChange() + 1);

            ticks_since_created++;//A tick has passed.
            

            CPlayer@ player = getLocalPlayer();
            if(player == @null)//The player must exist to get the CControls. (and maybe some other stuff)
            {
                return false;
            }

            CControls@ controls = player.getControls();
            if(controls == @null)//The controls must exist
            {
                return false;
            }


            return true;//Everything worked out correctly.
        }

        //
        //Logic
        //


        //
        //Interpolation
        //

        //Interpolated Positions
        //

        Vec2f getUpperLeftInterpolated()
        {
            return upper_left[2];
        }
        Vec2f getPosInterpolated()
        {
            return getUpperLeftInterpolated();
        }

        Vec2f getLowerRightInterpolated()
        {
            return lower_right[2];
        }
        //
        //Interpolated Positions

        //Put in onRender
        void InterpolatePositions()
        {
            //No interpolation? Just set them to where they should be on the screen then.
            if(!isInterpolated()
                || getTicksSinceCreated() == 0)//Or if the menu hasn't ticked yet.
            {
                upper_left[2] = getUpperLeft();
                lower_right[2] = getLowerRight();
                return;
            }

            //If the menu just moved, interpolate.
            if(didMenuJustMove())
            {
                CBlob@ _blob = getOwnerBlob();

                //Move towards owner blob
                if(_blob != @null && getMoveToOwner())//If this menu has an owner blob and it is supposed to move towards it.
                {
                    if(isWorldPos())
                    {
                        upper_left[2] = _blob.getInterpolatedPosition() + getOffset();

                        lower_right[2] = _blob.getInterpolatedPosition() + getOffset()//Upper left interpolated + the offset.
                        + getSize();//+ the size.
                    }
                    else
                    {
                        Driver@ driver = getDriver();
                        Vec2f b_ipos = driver.getScreenPosFromWorldPos(_blob.getInterpolatedPosition());//Blob_interpolatedPOS
                        
                        upper_left[2] = b_ipos + getOffset();

                        lower_right[2] = b_ipos + getOffset()//Upper left interpolated + the offset.
                        + getSize();//+ the size.
                    }
                }
                else//Just interpolate
                {
                    upper_left[2] = Vec2f_lerp(getUpperLeftOld(), getUpperLeft(), transporter.FRAME_TIME);

                    lower_right[2] = Vec2f_lerp(getLowerRightOld(), getLowerRight(), transporter.FRAME_TIME);
                }
                //print(FRAME_TIME+'');
                Vec2f size_interpolated = getLowerRightInterpolated() - getUpperLeftInterpolated();
                for(u16 i = 0; i < backgrounds.size(); i++)
                {
                    backgrounds[i].setPointLowerRight(size_interpolated);//Size interpolated.
                }
            }
            //No longer required with new rendering system. Probably.
            /*else if(isWorldPos())//If the menu didn't move, but the camera may of(check not yet added). move the menu to where it should be. TODO - check if the camera moved. only do this is it moved.
            {
                upper_left[2] = getUpperLeft();
                lower_right[2] = getLowerRight();

                image.setPointLowerRight(getLowerRightInterpolated());
            }*/
        }

        //
        //Interpolation
        //


        //
        //Rendering
        //

        private bool render_background;//If this is true, the menu will draw a background for the menu button by default.
        bool getRenderBackground()
        {
            return render_background;
        }
        void setRenderBackground(bool value)
        {
            render_background = value;
        }

        private RENDER_CALLBACK@ render_func;


        void setRenderFunction(RENDER_CALLBACK@ value)
        {
            @render_func = @value;
        }

        RENDER_CALLBACK@ getRenderFunction()
        {
            return @render_func;
        }

        bool DefaultRenderCaller()
        {
            return Render();
        }
        
        private array<Nu::NuImage@> backgrounds;
        array<Nu::NuImage@> getBackgrounds()
        {
            return backgrounds;
        }
        Nu::NuImage@ getBackground(u16 element)
        {
            if(element >= backgrounds.size()) { error("tried to get past backgrounds array max."); return @null; }
            return backgrounds[element];
        }
        void addBackground(Nu::NuImage@ _background)
        {
            _background.setPointLowerRight(getSize());
            backgrounds.push_back(@_background);
        }
        void removeBackground(u16 element)
        {
            if(element >= backgrounds.size()) { error("tried to remove past backgrounds array max."); return; }
            backgrounds.removeAt(element);
        }
        void clearBackgrounds()
        {
            backgrounds.clear();
        }
        //TODO, add remove options to remove by name and hash

        Render::ScriptLayer render_layer;
        Render::ScriptLayer getRenderLayer()
        {
            return render_layer;
        }
        void setRenderLayer(Render::ScriptLayer value)
        {
            render_layer = value;
        }

        bool Render()//Overwrite this method if you want a different look.
        {
            Driver@ driver = getDriver();

            if(!isWorldPos())
            {
                Render::SetTransformScreenspace();
            }
            else//World pos
            {
                Render::SetTransformWorldspace();
            }

            //If this cannot be seen. This is out of range. 
            /*if(getUpperLeft().x  - transporter.MARGIN > driver.getScreenWidth()
            || getUpperLeft().y  - transporter.MARGIN > driver.getScreenHeight()
            || getLowerRight().x + transporter.MARGIN < 0
            || getLowerRight().y + transporter.MARGIN < 0 )
            {
                return false;//Don't draw it then.
            }*/
            //TODO, re add this.

            InterpolatePositions();//Don't forget this if you want interpolation.

            if(getRenderBackground())
            {
                for(u16 i = 0; i < backgrounds.size(); i++)
                {
                    backgrounds[i].Render(backgrounds[i].frame_on[getButtonState()], getUpperLeftInterpolated(), getButtonState());
                    //GUI::DrawRectangle(getUpperLeftInterpolated(), getLowerRightInterpolated(), DebugColor(getButtonState()));
                }
            }

            return true;
        }

        //
        //Rendering
        //

    }
    









    class MenuBaseEx : MenuBase
    {
        MenuBaseEx(string _name, u8 _menu_config = NuMenu::Custom)
        {
            if(!isClient()) { return; }

            initVars();
            afterInitVars(_name, _menu_config);

            setMenuClass(BaseExClass);
        }

        MenuBaseEx(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_config = NuMenu::Custom)
        {
            if(!isClient()) { return; }

            initVars();
            afterInitVars(_name, _menu_config, _upper_left, _lower_right);

            setMenuClass(BaseExClass);
        }

        void initVars() override
        {
            MenuBase::initVars();

            draw_images = true;
            reposition_images = false;

            initial_press = false;
        
            images = array<Nu::NuImage@>(Nu::POSPositionsCount);

            menu_sounds_on = array<string>(ButtonStateCount, "");
            menu_volume = 1.0f;
            play_sound_on_world = false;
        }



        //
        //Overrides
        //

        void setMenuJustMoved(bool value) override
        {   
            MenuBase::setMenuJustMoved(value);
            if(value)//Menu just moved.
            {
                if(reposition_images)
                {
                    RepositionAllImages(getSize());
                }
            }
        }

        void setButtonState(u8 _button_state) override
        {
            MenuBase::setButtonState(_button_state);

            if(menu_sounds_on[_button_state].size() != 0)
            {
                if(play_sound_on_world)
                {
                    if(!isWorldPos())
                    {
                        warning("Tried to play sound on world while isWorldPos() was false.");
                    }
                    Sound::Play(menu_sounds_on[_button_state], getPos(), menu_volume, 1.0f);
                }
                else
                {
                    Sound::Play2D(menu_sounds_on[_button_state], menu_volume, 1.0f);
                }
            }
        }
        
        //
        //Overrides
        //

        //
        //SFX
        //
            array<string> menu_sounds_on;//[Insert state]
            float menu_volume;
            bool play_sound_on_world;
        //
        //SFX
        //


        //
        //Logic
        //

        bool initial_press;

        u8 getPressingState(Vec2f point, u8 _button_state, bool left_button, bool left_button_release, bool left_button_just)
        {
            if(isPointInMenu(point))//Is the mouse within the menu?
            {
                if(_button_state == Released//If the button is Released.
                || (_button_state == AfterRelease && left_button))//Or if the button is AfterRelease and left_button is still true.
                {
                    _button_state = AfterRelease;//The button is AfterRelease.
                }
                else if(initial_press)//If the button was initially pressed.
                {
                    if(left_button)//Left button held?
                    {
                        _button_state = Pressed;//Button is pressed
                    }
                    else if(left_button_release)//Left button released?
                    {
                        _button_state = Released;//Button was released on.
                        initial_press = false;//No longer pressed.
                    }
                }
                else if(left_button_just)//Mouse button just pressed?
                {
                    if(left_button_release)//Same tick press and release.
                    {
                        _button_state = Released;//Button was released
                        initial_press = false;//No longer pressed.
                    }
                    else//Normal behavior
                    {
                        initial_press = true;//This button was initially pressed.
                        _button_state = JustPressed;//It was also just pressed.
                    }
                }//Only buttons with "initial_press" equal to true will have their button logic working.
                
                else if(!left_button)//If the button was not initially pressed and left mouse button is not being held
                {
                    if(_button_state == Hover)//If we are currently hovering.
                    {
                        _button_state = Hover;//Continue hovering.
                    }
                    else if(_button_state == JustHover)//If this button was just being hovered above
                    {
                        _button_state = Hover;//Continue hovering.
                    }
                    else if(_button_state != JustHover)//If we aren't hovering, we should be.
                    {
                        _button_state = JustHover;//Button is being hovered over.
                    }
                }
            }
            else//Not in menu
            {
                if(initial_press)//If this mouse was initailly pressed.
                {
                    if(!left_button)//If the left button is no longer being pressed.
                    {
                        _button_state = FalseRelease;//Mouse was released while not over the button.

                        initial_press = false;//This button is no longer initially pressed.
                    }
                    else if(_button_state != Selected)//If the mouse is not selected
                    {
                        _button_state = Selected;//Select it.
                    }
                }
                else if(_button_state == JustHover || _button_state == Hover)//If the position is not in the menu, and the button was not initailly pressed and the button was hovering.
                {
                    _button_state = UnHover;//Hover release.
                }
                else if(_button_state != Idle)//If the position is in the button, was not initially pressed, is not hovering, and is not idle.
                {
                    _button_state = Idle;//Make the mouse button idle.
                }
            }

            return _button_state;
        }

        //Always change positions AFTER this method.
        bool Tick() override
        {
            if(!MenuBase::Tick())
            {
                return false;
            }

            return true;//Everything worked out correctly.
        }

        //
        //Logic
        //


        //
        //Image stuff
        //
        
        bool draw_images;
        bool reposition_images;//If this is true, the images's positions will be reassigned every time the menu moves based on what image position it is in. top will be put back on the top every movement.
        
        
        private array<Nu::NuImage@> images;

        
        Nu::NuImage@ setImage(string image_name, Vec2f image_frame_size, u16 image_frame_default, u16 image_frame_hover, u16 image_frame_press, u16 position = 0)
        {
            if(images.size() <= position){ error("In setImage : tried to get past the highest element in the images array. Attempted to get image " + position ); return @null; }
            
            string render_name = image_name;
            //render_name = render_name.substr(render_name.findLast("/"));
            //print("render_name = " + render_name);

            Nu::NuImage@ image = Nu::NuImage(ButtonStateCount);
            
            //image.CreateImage("_i", image_name);//Debug later
            image.CreateImage(render_name, image_name);

            image.setScale(0.75f);

            image.setFrameSize(image_frame_size);

            image.setDefaultFrame(image_frame_default);
            
            image.setFourTwoFrames(JustHover, Hover, JustPressed, Pressed,
                image_frame_hover, image_frame_press);
            
            Vec2f image_offset;
            
            if(!Nu::getPosOnSizeFull(position, getSize(), image_frame_size, image_offset, getDefaultBuffer()))//Move that pos.
            {
                error("setImage position was an unknown position");
                return @null;
            }
            
            image.offset = image_offset;// + getSize() / 2 - image.frame_size;


            @images[position] = @image;
        
            return image;
        }
        
        Nu::NuImage@ getImage(u16 position = 0)
        {
            if(images.size() <= position){ error("In getImage : tried to get past the highest element in the images array. Attempted to get image " + position); return @null; }

            return images[position];
        }

        u16 getImageCount()
        {
            return images.size();
        }

        void setImageOffset(Vec2f image_offset, u16 position = 0)
        {
            if(images.size() <= position){ error("In setImageOffset : tried to get past the highest element in the images array. Attempted to get image " + position); return; }

            images[position].offset = image_offset;

        }

        void RepositionAllImages(Vec2f size)
        {
            for(u16 i = 0; i < Nu::POSPositionsCount; i++)
            {
                Nu::NuImage@ image = getImage(i);
                    
                if(image == @null)
                {
                    continue;
                }

                Vec2f image_offset;
                
                if(!Nu::getPosOnSizeFull(i, size, image.getFrameSize(), image_offset, getDefaultBuffer()))//Move that pos.
                {
                    error("Image position went above the images array max size");
                    return;
                }
                
                image.offset = image_offset;
            }
        }

        //
        //Image stuff
        //


        //
        //Rendering
        //
        
        bool Render() override
        {
            if(!MenuBase::Render())
            {
                return false;
            }
            
            if(draw_images)
            {
                DrawImages();
            }

            return true;
        }

        void DrawImages()
        {
            //Reposition icons.
            if(reposition_images && isInterpolated()//If this menu is interpolated
            && didMenuJustMove())//And the menu just moved.
            {
                RepositionAllImages(getLowerRightInterpolated() - getUpperLeftInterpolated());
            }

            for(u16 i = 0; i < images.size(); i++)
            {
                if(images[i] == @null)
                {
                    continue;
                }

                images[i].Render(images[i].frame_on[getButtonState()], getUpperLeftInterpolated(), getButtonState());
                //GUI::DrawRectangle(getUpperLeftInterpolated(), getLowerRightInterpolated(), rec_color);
                
                //GUI::DrawIcon(images[i].name,//Icon name
                //images[i].frame_on[button_state],//Icon frame
                //images[i].getFrameSize(),//Icon size
                //getUpperLeftInterpolated() + (images[i].pos - Vec2f(0,0)),//Icon position//TODO, FIX.  (probably when rendering is done)
                //0.5f,//Icon scale
                //images[i].color_on[button_state]);//Color
            }
        }

        //
        //Rendering
        //

    }
    
    //Base of all menus + previous ex + this. Includes text, and a titlebar (can be hidden and simply used for dragging the menu.)
    class MenuBaseExEx : MenuBaseEx
    {
        MenuBaseExEx(string _name, u8 _menu_config = NuMenu::Custom)
        {
            if(!isClient()) { return; }

            initVars();
            afterInitVars(_name, _menu_config);

            setMenuClass(BaseExExClass);
        }

        MenuBaseExEx(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_config = NuMenu::Custom)
        {
            if(!isClient()) { return; }

            initVars();
            afterInitVars(_name, _menu_config, _upper_left, _lower_right);

            setMenuClass(BaseExExClass);
        }

        void initVars() override
        {
            MenuBaseEx::initVars();
            
            titlebar_ignore_press = false;
            draw_titlebar = true;
            titlebar_size = Vec2f_zero;
            titlebar_press_pos = Vec2f_zero;
        
        
            draw_text = true;
            reposition_text = false;

            text = array<NuText@>(Nu::POSPositionsCount, @null);
            text_positions = array<Vec2f>(Nu::POSPositionsCount);
        }

        //
        //Overrides
        //
        void setMenuJustMoved(bool value) override
        {
            //print("repos2 = " + reposition_text + " resize = " + resize_text + " draw_text = " + draw_text + " text_used = " + text_used);//Debug
            
            MenuBaseEx::setMenuJustMoved(value);
            if(value)//Menu just moved.
            {
                //Optimize me, this will be done twice a tick if both top left and bottom right are moved. That is no goodo. TODO
                if(reposition_text)
                {
                    RepositionText(getSize());
                }
            }
        }
        //
        //Overrides
        //



        //
        //Text stuff
        //

        //Text settings
        //

        private array<NuText@> text;//NuText used.
        array<NuText@> getTexts()
        {
            return text;
        }

        private array<Vec2f> text_positions;

        NuText@ getText(u16 element = Nu::PosCenter)
        {
            if(element >= text.size()) { Nu::Error("Tried to get text out of array bounds. Attempted to get text at the position " + element); return NuText(); }
            //if(text[element] == @null){Nu::Error("text at element " + element + " was null"); }
            
            return @text[element];
        }
        void setText(NuText@ _text, u16 element = Nu::PosCenter)
        {
            if(element >= text.size()) { Nu::Error("Tried to set text out of array bounds. Attempted to get text at the position " + element); return; }
            if(_text == @null) { Nu::Error("Input parameter text was null."); return; }

            Vec2f text_pos;
            
            Vec2f text_dimensions = _text.string_size_total;
            
            if(!Nu::getPosOnSizeFull(element, getSize(), text_dimensions, text_pos, getDefaultBuffer()))//Move that pos.
            {
                error("Text position went above the text_positions array max size");
                return;
            }

            text_positions[element] = text_pos;
            
            @text[element] = @_text;
        }
        NuText@ setText(string _text, string font_name, u16 element = Nu::PosCenter)
        {
            NuText@ _nuText = NuText(font_name, _text);//Create text with font and text.
            
            setText(_nuText, element);//Set the text to this menu.
        
            return @_nuText;//Return the text.
        }
        NuText@ setText(string _text, u16 element = Nu::POSCenter)
        {
            NuText@ _nuText = NuText();//Create text
            
            _nuText.setString(_text);//Set the string inside

            setText(_nuText, element);//Set it to this menu.

            return @_nuText;//Return it.
        }


        
        NuFont@ setFont(string font_name, u16 element = -1, bool repos = true)
        {
            NuHub@ hub;
            if(!getRules().get("NuHub", @hub)) { error("Failed to get NuHub. Make sure NuHubLogic is before anything else that tries to use it."); return @null; }
            NuFont@ _font = hub.getFont(font_name);
            if(_font == @null){ warning("Could not find font with font_name = " + font_name); return hub.getFont("Arial"); }

            setFont(@_font, element, repos);
            return @_font;
        }
        void setFont(NuFont@ _font, u16 element = -1, bool repos = true)
        {
            if(_font == @null){ Nu::Error("Font was null."); return; }
            if(element == u16(-1))//No element specified.
            {
                for(u16 i = 0; i < text.size(); i++)
                {
                    if(text[i] == @null) { continue; }
                    text[i].setFont(_font);
                    if(repos) { RepositionText(getSize(), i); }
                }
            }
            else if(element < text.size())
            {
                if(text[element] != @null)
                {
                    text[element].setFont(_font);
                    if(repos) { RepositionText(getSize(), element); }
                }
               else { Nu::Error("Element specified " + element + " was null."); }
            }
            else { Nu::Error("Attempted to set text above text array at " + element); }
        }


        SColor getTextColor(u16 element = -1)
        {
            if(element == u16(-1))
            {
                for(u16 i = 0; i < text.size(); i++)
                {
                    if(text[i] == @null) { continue; }
                    return text[i].getColor();
                }
            }
            else if(element < text.size())
            {
                if(text[element] != @null)
                {
                    return text[element].getColor();
                }
                else { Nu::Error("Element specified " + element + " was null."); }
            }
            else { Nu::Error("Attempted to set text above text array at " + element); }

            return SColor(255, 255, 255, 255);//Not found.
        }
        void setTextColor(SColor value, u16 element = -1)
        {
            if(element == u16(-1))
            {
                for(u16 i = 0; i < text.size(); i++)
                {
                    if(text[i] == @null) { continue; }
                    text[i].setColor(value);
                }
            }
            else if(element < text.size())
            {
                if(text[element] != @null)
                {
                    text[element].setColor(value);
                }
                else { Nu::Error("Element specified " + element + " was null."); }
            }
            else { Nu::Error("Attempted to set text above text array at " + element); }
        }

        Vec2f getTextScale(u16 element = -1)
        {
            if(element == u16(-1))
            {
                for(u16 i = 0; i < text.size(); i++)
                {
                    if(text[i] == @null) { continue; }
                    return text[i].getScale();
                }
            }
            else if(element < text.size())
            {
                if(text[element] != @null)
                {
                    return text[element].getScale();
                }
                else { Nu::Error("Element specified " + element + " was null."); }
            }
            else { Nu::Error("Attempted to set text above text array at " + element); }

            return Vec2f(0,0);
        }
        void setTextScale(Vec2f value, u16 element = -1, bool repos = true)
        {
            if(element == u16(-1))
            {
                for(u16 i = 0; i < text.size(); i++)
                {
                    if(text[i] == @null) { continue; }
                    text[i].setScale(value);
                    if(repos) { RepositionText(getSize(), i); }
                }
            }
            else if(element < text.size())
            {
                if(text[element] != @null)
                {
                    text[element].setScale(value);
                    if(repos) { RepositionText(getSize(), element); }
                }
                else { Nu::Error("Element specified " + element + " was null."); }
            }
            else { Nu::Error("Attempted to set text above text array at " + element); }
        }
        void setTextScale(float value, u16 element = -1, bool repos = true)
        {
            setTextScale(Vec2f(value, value), element, repos);
        }

        //
        //Text settings

        bool draw_text;//If this is true, text will be drawn(if the text exists).
        bool reposition_text;//If this is true, the text's position will be reassigned every time the menu moves based on what text it is. top will be put back on the top every movement.
        bool wrap_text;//If this is true, the text will wrap to stay in the menu. (width only)  

        void RepositionText(Vec2f size, u16 element = -1)
        {
            if(element == u16(-1))
            {
                for(u16 i = 0; i < Nu::POSPositionsCount; i++)
                {           
                    if(text[i] == @null)
                    {
                        continue;
                    }

                    Vec2f text_pos;
            
                    Vec2f text_dimensions = text[i].string_size_total;

                    if(!Nu::getPosOnSizeFull(i, size, text_dimensions, text_pos, getDefaultBuffer()))//Move that pos.
                    {
                        Nu::Error("Text position went above the text_positions array max size"); return;
                    }
                    
                    text_positions[i] = text_pos;
                }
            }
            else if(element < text.size())
            {
                if(text[element] != @null)
                {
                    Vec2f text_pos;
            
                    Vec2f text_dimensions = text[element].string_size_total;

                    if(!Nu::getPosOnSizeFull(element, size, text_dimensions, text_pos, getDefaultBuffer()))//Move that pos.
                    {
                        Nu::Error("Text position went above the text_positions array max size"); return;
                    }
                    
                    text_positions[element] = text_pos;
                }
                else { Nu::Error("Element specified " + element + " was null."); }
            }
            else { Nu::Error("Attempted to reposition text above text array at " + element); }
        }


        
        Vec2f getTextPos(u16 array_position)
        {
            if(array_position >= text_positions.size()){ Nu::Error("Tried to get position out of bounds at " + array_position); return Vec2f(0,0); }

            return text_positions[array_position];
        }
        void setTextPos(Vec2f value, u16 array_position)
        {
            if(array_position >= text_positions.size()){ Nu::Error("Tried to get position out of bounds at " + array_position); return; }
            
            text_positions[array_position] = value;
        }

        //
        //Text stuff
        //



        //
        //Titlebar
        //
        
        private Vec2f titlebar_size;
        Vec2f getTitlebarSize()
        {
            return titlebar_size;
        }
        void setTitlebarHeight(float value)
        {
            titlebar_size.y = value;
            if(titlebar_size.x == 0)
            {
                titlebar_size.x = getSize().x;
            }
        }
        bool titlebar_width_is_menu = true;//When this is true the titlebar width will move with the menu
        void setTitlebarWidth(float value)
        {
            titlebar_size.x = value;
            titlebar_width_is_menu = false;
        }

        Vec2f titlebar_press_pos;//Do not edit, this is for the moving menu part of the code.
        

        bool titlebar_ignore_press;//When this is true the titlebar cannot move the menu.

        bool draw_titlebar;//If this is false the titlebar will not be drawn (but will still function)

        bool isPointInTitlebar(Vec2f value)//Is the vec2f value within the titlebar?
        {
            Vec2f _upperleft = getUpperLeft();
            
            if(value.x <= getLowerRight().x - (getSize().x - titlebar_size.x) //If the point is to the left of the titlebar's right side.
            && value.y <= _upperleft.y + titlebar_size.y//If the point is above the titlebar's bottom.
            && value.x >= _upperleft.x//If the point is to the right of the titlebar's left side.
            && value.y >= _upperleft.y)//If the point is below the titlebar's top.
            {
                return true;//Yes
            }
            return false;//No
        }

        //
        //Titlebar
        //

        //Always change positions AFTER this method.
        bool Tick() override
        {
            if(!MenuBaseEx::Tick())
            {
                return false;
            }
            u16 i;

            CControls@ controls = getLocalPlayer().getControls();//This can be done safely as the code to check if client&player&controls is null/false was done in the inherited class.

            Vec2f mouse_pos;
            if(isWorldPos())//World pos
            {
                mouse_pos = controls.getMouseWorldPos();
            }
            else//Screen pos
            {
                mouse_pos = controls.getMouseScreenPos();
            }
            
            
            bool left_button = controls.mousePressed1;
            bool left_button_release = controls.isKeyJustReleased(KEY_LBUTTON);
            bool left_button_just = controls.isKeyJustPressed(KEY_LBUTTON);


            //Titlebar
            if(titlebar_width_is_menu)
            {
                titlebar_size.x = getSize().x;
            }

            if(!titlebar_ignore_press && titlebar_size.y != 0.0f)
            {
                if(left_button)
                {
                    if(left_button_just && isPointInTitlebar(mouse_pos))
                    {
                        titlebar_press_pos = mouse_pos;
                    }
                    
                    if(titlebar_press_pos != Vec2f_zero)
                    {
                        //MenuBaseExEx required to not accidently use the one in MenuHolder which moves their children menu's before the tick methods.
                        MenuBaseExEx::setPos(getUpperLeft() - //Current menu position subtracted by
                         (titlebar_press_pos - mouse_pos));//The positioned the titlebar was pressed minus the current mouse position. (The difference.)
                        titlebar_press_pos = mouse_pos;
                    }
                }

                else if(titlebar_press_pos != Vec2f_zero)
                {
                    titlebar_press_pos = Vec2f_zero;
                }
            }
            //Titlebar

            return true;//Everything worked out correctly.
        }

        bool Render() override
        {
            bool _draw_images = draw_images;//Make a temp value called _draw_images and make it equal to draw_images.

            if(draw_images)//If draw_images is true
            {
                draw_images = false;//Make it false. This is done to prevent the images from being drawn before the titlebar. That would be no good.
            }

            if(!MenuBaseEx::Render())
            {
                draw_images = _draw_images;//Rendering failed, revert draw_images to it's original state.
                return false;
            }
            draw_images = _draw_images;//If MenuBaseEx was going to draw an image, it wouldn't. Revert back draw_image.


            
            if(draw_titlebar)//Draw the titlebar first
            {
                DrawTitlebar();
            }
            
            if(draw_images)//Then draw images
            {
                DrawImages();
            }

            if(draw_text)//If text exists and it is supposed to be drawn.
            {
                DrawTexts();//Too
            }

            return true;
        }

        void DrawTitlebar()
        {
            if(titlebar_size.x == 0 || titlebar_size.y == 0)
            {
                return;
            }
            if(titlebar_width_is_menu)
            {
                Vec2f interpolated_size = getLowerRightInterpolated() - getUpperLeftInterpolated();
                if(titlebar_size.x != interpolated_size.x)
                {
                    titlebar_size.x = interpolated_size.x;
                }
            }


            Vec2f _upperleft = getUpperLeftInterpolated();//Upper left
            
            Vec2f _lowerright = (getUpperLeftInterpolated() + Vec2f(titlebar_size.x, +//Upper left plus titlebar_size.x +
            titlebar_size.y)); //titlebar_size.y

            GUI::DrawRectangle(_upperleft, _lowerright);
        }


        void DrawTexts()
        {
            //For repositionioning text in an interpolated manner. Only works if reposition_text is true.
            if((reposition_text && isInterpolated())//If this menu is interpolated 
            && didMenuJustMove())//and the menu just moved.
            {
                RepositionText(getLowerRightInterpolated() - getUpperLeftInterpolated());
            }

            for(u16 i = 0; i < text.size(); i++)
            {
                if(text[i] == @null)
                {
                    continue;
                }
                
                text[i].Render(getUpperLeftInterpolated() + text_positions[i], getButtonState());
            }
        }
    }

    //In order: caller, params, self.
    funcdef void RELEASE_CALLBACK(CPlayer@, CBitStream, IMenu@);
    //In order: caller, params, self, owner.
    funcdef void RELEASE_CALLBACK_OWNER(CPlayer@, CBitStream, IMenu@, CBlob@);
    //In order: caller, self.
    funcdef void STATE_CHANGED_CALLBACK(CPlayer@, IMenu@);

    //Menu set up to function like a button.
    class MenuButton : MenuBaseExEx
    {
        MenuButton(string _name, u8 _menu_config = NuMenu::Custom)
        {
            if(!isClient())
            {
                return;
            }

            initVars();
            afterInitVars(_name, _menu_config);

            setMenuClass(ButtonClass);
        }

        MenuButton(string _name, CBlob@ blob, u8 _menu_config = NuMenu::Custom)
        {
            if(!isClient())
            {
                return;
            }

            initVars();
            afterInitVars(_name, _menu_config);

            setMenuClass(ButtonClass);
            
            setOwnerBlob(blob);//This is the button's owner. The button will follow this blob (can be disabled).
            setIsWorldPos(true);//The position of the button is in the world, not the screen as the button is following a blob, a thing in the world. Therefor isWorldPos should be true.
        }

        MenuButton(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_config = NuMenu::Custom)
        {
            if(!isClient())
            {
                return;
            }

            initVars();
            afterInitVars(_name, _menu_config, _upper_left, _lower_right);
        
            setMenuClass(ButtonClass);
        }

        void initVars() override
        {
            MenuBaseExEx::initVars();
            send_to_rules = false;
            kill_on_release = false;
            instant_press = false;

            enableRadius = 0.0f;

            @release_func_owner = @null;
            @release_func = @null;
            @state_changed_func = @null;

            command_id = 255;
        }


        //The function called upon being pressed.
        private RELEASE_CALLBACK@ release_func;
        private RELEASE_CALLBACK_OWNER@ release_func_owner;

        //Function called upon the button state being changed.
        private STATE_CHANGED_CALLBACK@ state_changed_func;


        void addReleaseListener(RELEASE_CALLBACK@ value)
        {
            @release_func = @value;
        }
        void addReleaseListener(RELEASE_CALLBACK_OWNER@ value)
        {
            @release_func_owner = @value;
        }
        void addStateChangedListener(STATE_CHANGED_CALLBACK@ value)
        {
            @state_changed_func = @value;
        }

        void setButtonState(u8 _button_state) override
        {
            MenuBaseExEx::setButtonState(_button_state);

            if(state_changed_func != @null)
            {
                state_changed_func(getLocalPlayer(), @this);            
            }
        }


        void setCommandID(u8 cmd)
        {
            command_id = cmd;
        }
        void setCommandID(string value)
        {
            CBlob@ _owner = getOwnerBlob();
            if(!send_to_rules && _owner == @null){ error("owner blob was null when setting command id for blob. Did you want to set send_to_rules to true and send the command to rules instead?"); return; }
            if(send_to_rules)
            {
                command_id = getRules().getCommandID(value);
            }
            else
            {
                command_id = _owner.getCommandID(value);
            }
        }

        u8 command_id;//The command id send out upon being pressed. But an actual id this time.
        bool send_to_rules;//If this is false, it will attempt to send the command_id to the owner blob. Otherwise it will send it to CRules.
        CBitStream params;//The params to accompany above


        bool kill_on_release;//Does nothing. Just holds a value in case someone wants to use it.

        bool instant_press;//If this is true, the button will trigger upon being just pressed.

        float enableRadius;//The radius at which the button can be pressed


        bool Tick() override
        {
            if(!MenuBaseExEx::Tick())
            {
                return false;
            }

            CControls@ controls = getLocalPlayer().getControls();

            Vec2f pos;

            if(isWorldPos())
            {
                pos = controls.getMouseWorldPos();
            }
            else
            {
                pos = controls.getMouseScreenPos();
            }

            array<u16> key_codes(2);
            key_codes[0] = KEY_LBUTTON;
            key_codes[1] = KEY_RBUTTON; 
            
            return Update(key_codes, pos);
        }

        bool Tick(Vec2f position)
        {
            if(!MenuBaseExEx::Tick())
            {
                return false;
            }
            
            CControls@ controls = getLocalPlayer().getControls();

            Vec2f pos;

            if(isWorldPos())
            {
                pos = controls.getMouseWorldPos();
            }
            else
            {
                pos = controls.getMouseScreenPos();
            }

            array<u16> key_codes(2);
            key_codes[0] = KEY_LBUTTON;
            key_codes[1] = KEY_RBUTTON; 
            
            return Update(key_codes, pos, position);
        }

        bool Tick(u16 key_code, Vec2f point, Vec2f position = Vec2f_zero)
        {
            if(!MenuBaseExEx::Tick())
            {
                return false;
            }
            return Update(array<u16>(1, key_code), point, position);
        }

        //Examples: point parameter for the mouse position, the position parameter is for the blob. position parameter only really useful when it comes to radius stuff.
        bool Update(array<u16> key_codes, Vec2f point, Vec2f position = Vec2f_zero)
        {
            CPlayer@ player = getLocalPlayer();

            CControls@ controls = player.getControls();
            
            if(key_codes.size() == 0)
            {
                Nu::Error("Input key codes size was equal to 0");
            }

            bool key_button = false;
            bool key_button_release = false;
            bool key_button_just = false;

            //Assign true if any of the input keys are being pressed.
            for(u16 i = 0; i < key_codes.size(); i++)
            {
                if(!key_button){
                    key_button = controls.isKeyPressed(key_codes[i]);//Pressing
                }
                if(!key_button_release){
                    key_button_release = controls.isKeyJustReleased(key_codes[i]);//Just released
                }
                if(!key_button_just){
                    key_button_just = controls.isKeyJustPressed(key_codes[i]);//Just pressed
                }
            }
            
            u8 _button_state = getButtonState();//Get the button state.

            if(enableRadius == 0.0f || position == Vec2f_zero ||//Provided both these values have been assigned, the statement below will check.
            Nu::getDistance(position, getMiddle()) < enableRadius)//The button is within enable(interact) distance.
            {
                _button_state = getPressingState(point, _button_state, key_button, key_button_release, key_button_just);//Get the pressing state. That pun in intentional.
            }
            else//enableRadius and position were assigned, and the button was out of range.
            {
                _button_state = Disabled;//The button is disabled
            }

            //Anti swinging.
            if(_button_state == JustPressed || _button_state == Pressed || _button_state == Released || _button_state == AfterRelease)
            {
                CBlob@ player_blob = player.getBlob();
                if(player_blob != @null)
                {
                    player_blob.set_bool("no_swing", true);
                }
            }

            //Instant press.
            if(instant_press && _button_state == JustPressed)//If the button is supposed to be released instantly upon press.
            {
                _button_state = Released;//The button was basically released, so tell it to actually release. To prevent it from sending the command twice.
            }

            //Command sending.
            if(_button_state == Released)//If the button was released.
            {
                sendReleaseCommand();//Send the command.
            }

            //Set state.
            if(_button_state != getButtonState())//Was the button state changed.
            {
                setButtonState(_button_state);//Set the button state.
            }
            return true;
        }

        bool Render() override
        {
            if(!MenuBaseExEx::Render())
            {
                return false;
            }
        
            return true;
        }

        void sendReleaseCommand()
        {
            if(kill_on_release)//If this button is suppose to be killed on release.
            {
                KillMenu();//Tell the menu to die.
            }

            //Send command.
            if(command_id != 255)//If there is a command_id to send.
            {
                if(send_to_rules)//if send_to_rules is true.
                {
                    CRules@ _rules = getRules();

                    _rules.SendCommand(command_id, params);
                }
                else if(getOwnerBlob() != @null)//If send_to_rules is false, send it to the owner_blob. Provided it exists.
                {
                    CBlob@ _owner = getOwnerBlob();

                    _owner.SendCommand(command_id, params);
                }
            }

            //Call function.
            if(release_func != @null)
            {
                release_func(getLocalPlayer(), params, @this);
            }

            //Call function and include the owner blob.
            if(release_func_owner != @null)
            {
                if(getOwnerBlob() != @null)
                {
                    CBlob@ _owner = getOwnerBlob();
                    release_func_owner(getLocalPlayer(), params, @this, _owner);
                }
                else
                {
                    error("Owner of button was null");
                }
            }
        }
    }









    //This menu is designed to hold other menu's and keep them attached to it.
    class MenuHolder : MenuBase
    {
        MenuHolder(string _name, u8 _menu_config = NuMenu::Custom)
        {
            if(!isClient())
            {
                return;
            }
            
            initVars();
            afterInitVars(_name, _menu_config);
        
            setMenuClass(HolderClass);
        }

        MenuHolder(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_config = NuMenu::Custom)
        {
            if(!isClient())
            {
                return;
            }
            
            initVars();
            afterInitVars(_name, _menu_config, _upper_left, _lower_right);

            setMenuClass(HolderClass);
        }

        void initVars() override
        {
            MenuBase::initVars();
        }

        

        //This allows someone to += an IMenu into MenuHolder. It's mostly just for looks, and it looks nice, so I added it. 
        MenuHolder@ opAddAssign(IMenu@ menu)
        {
            //TODO - Put menu in MenuHolder
            
            return this;//Handle to self for chaining assignments.
        }

        IMenu@ get_opIndex(int idx) const       { return @null; }//Return IMenu at the position.
        void set_opIndex(int idx, IMenu@ value) { }//Set IMenu at position. (stop if out of bounds)


        //
        //Overrides
        //

        void setMenuJustMoved(bool value) override
        {
            MenuBase::setMenuJustMoved(value);
            if(value)
            {
                moveHeldMenus();
            }
        }
        
        void setInterpolated(bool value) override
        {
            MenuBase::setInterpolated(value);
            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(optional_menus[i] == @null)
                {
                    continue;
                }

                optional_menus[i].setInterpolated(value);
            }
        }

        void setIsWorldPos(bool value) override
        {
            MenuBase::setIsWorldPos(value);
            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(optional_menus[i] == @null)
                {
                    continue;
                }

                optional_menus[i].setIsWorldPos(value);
            }
            
            moveHeldMenus();
        }

        //
        //Overries
        //


        //
        //Optional Menus
        //

        private IMenu@[] optional_menus;
        IMenu@[] getOptionalMenuArray()
        {
            return optional_menus;
        }
        bool findElementPos(IMenu@ _menu, u16 &out pos)//returning false means it did not find it in the array.
        {
            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(@_menu == @optional_menus[i])
                {
                    pos = i;
                    return true;
                }
            }
            return false;
        }

        Vec2f getOptionalMenuPos(u16 option_menu = 0)//In relation to this menu
        {
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != @null)
            {
                return optional_menus[option_menu].getOffset();
            }
            return Vec2f_zero;
        }
        Vec2f getOptionalMenuPos(IMenu@ _menu)
        {
            u16 pos;
            if(!findElementPos(_menu, pos))
            {
                return Vec2f_zero;
            }
            return getOptionalMenuPos(pos);
        }
        
        bool setOptionalMenuPos(Vec2f value, u16 option_menu = 0)//Sets it in relation to this menu
        {
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != @null)
            {
                IMenu@ _menu = @optional_menus[option_menu];
                _menu.setOffset(value);
                
                if(_menu.getMoveToOwner())
                {
                    _menu.setPos(getPos() + _menu.getOffset());
                }
                
                return true;
            }
            
            return false;
        }
        bool setOptionalMenuPos(Vec2f value, IMenu@ _menu)
        {
            u16 pos;
            if(!findElementPos(_menu, pos))
            {
                return false;
            }
            
            setOptionalMenuPos(value, pos);
            return true;
        }

        u8 getOptionalMenuState(u16 option_menu = 0)//Param refers to specific menu in array
        {
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != @null)
            {
                return optional_menus[option_menu].getMenuState();
            }
            
            return 255;
        }
    
        IMenu@ getOptionalMenu(u16 option_menu = 0)//Param refers to specific menu in array
        {
            if(optional_menus.size() > option_menu)
            {
                return @optional_menus[option_menu];
            }
            return @null;
        }

        void clearMenuOptions()
        {
            optional_menus.clear();
        }

        u16 optional_menu_id_count = 0;//Goes up every time an optional menu is made. This is better than using optional_menus.size(), as an element can be removed from that array.
        //                      Type                Size of type                  Button name
        IMenu@ addMenuOption(u8 value, Vec2f optional_menu_size = Vec2f(32, 32), string _name = "")
        {
            //by default the button name is ((Holder button's name) + ("_" + ID of button) + ("_" + Button type())) Note that the (Button type) will always be at the end even with a name.
            //Button = "but"; CheckBox = "chk";
            if(_name == "")
            {
                _name = getName() + "_" + optional_menu_id_count;
            }

            switch(value)
            {
                case ButtonClass:
                {
                    MenuButton@ _menu = MenuButton(_name + "_but");


                    optional_menus.push_back(@_menu);
                    break;
                }
                default:
                    error("Menu option " + value + " not found.");
                    break;
            }

            optional_menu_id_count++;


            if(optional_menus.size() != 0 && optional_menus[optional_menus.size() - 1] != @null)
            {
                IMenu@ added_menu = @optional_menus[optional_menus.size() - 1];

                added_menu.setIsWorldPos(isWorldPos());
                added_menu.setSize(optional_menu_size);
                added_menu.setInterpolated(isInterpolated());

                //added_menu.setOffset(Vec2f(getSize().x - optional_menu_size.x - getDefaultBuffer(), getSize().y/2 - optional_menu_size.y/2));

                added_menu.setOwnerMenu(this);


                added_menu.setPos(getPos() + added_menu.getOffset());

                return @added_menu;
            }
            
            return @null;
        }


        void moveHeldMenus()
        {
            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(optional_menus[i] == @null)
                {
                    error("optional_menu was null");
                    continue;
                }

                if(!optional_menus[i].getMoveToOwner())
                {
                    continue;
                }
                
                optional_menus[i].setPos(getPos() + optional_menus[i].getOffset());
            }
        }

        //
        //Optional Menus
        //


        bool Tick() override
        {
            
            if(!MenuBase::Tick())
            {
                return false;
            }

            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(optional_menus[i] != @null)
                {
                    optional_menus[i].Tick();
                }
            }
            return true;
        }

        bool Render() override
        {
            if(!MenuBase::Render())
            {
                return false;
            }

            /*if(!GUI::isFontLoaded(font))
            {
                error("Font " + font + " is not loaded.");
                return;
            }*/

            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                /*switch(optional_menus[i].getMenuClass())
                {
                    case CheckBox:
                    {
                        optional_menus[i].Render();
                        break;
                    }

                    default:
                    error("Menu option not found in render\n menu option is " + optional_menus[i].getMenuClass());
                    //GUI::DrawRectangle(upper_left + optional_menus[i].getUpperLeftRelation(), upper_left + optional_menus[i].getLowerRightRelation());
                    break;
                }*/
                RENDER_CALLBACK@ func = optional_menus[i].getRenderFunction();
                if(func == @null)
                {
                    error("rendercallback function was null."); return true;
                }
                func();
            }


            return true;
        }
    }


    /*class ListMenu
    {
        bool is_horizontal = false;
        
        float buffer_size;//Space between two buttons
    
        array<Menu> buttons();
    
        void onTick( CRules@ rules )
        {

        }

        void onRender( CRules@ rules )
        {

        }
    }*/









    NuHub@ transporter;

    void onInit(CRules@ rules)
    {
        if(!isClient())
        {
            return;
        }

        rules.get("NuHub", @transporter);
        
    }

    void onTick(CRules@ rules)
    {
        if(!isClient())
        {
            return;
        }

        if(transporter == @null)
        {
            error("transporter was null"); return;
        }

        transporter.FRAME_TIME = 0.0f;
    }

    void MenuTick()
    {
        if(!isClient())
        {
            return;
        }

        if(transporter == @null)
        {
            error("transporter was null"); return;
        }
        
        u16 i;
        for(i = 0; i < transporter.getMenuListSize(); i++)
        {
            if(transporter.menus[i] == @null)
            {
                error("menu should not be null."); continue;
            }
            
            transporter.menus[i].Tick();
        
            if(transporter.menus[i].getMenuClass() == NuMenu::ButtonClass && transporter.buttons[i] == @null)//Debug check only. TODO remove.
            {
                error("Button desync somewhere."); continue;
            }

            if(transporter.menus[i].getKillMenu())//Kill the menu?
            {
                transporter.removeMenuFromList(i);//Remove it.
                i--;//One step back.
            }
        }

    }

    void onRender(CRules@ rules)
    {
        if(transporter == @null)
        {
            error("transporter was null"); return;
        }

        transporter.FRAME_TIME += getRenderDeltaTime() * getTicksASecond();
    }

    void MenuRender(NuHub@ transporter, Render::ScriptLayer layer)
    {
        Render::SetAlphaBlend(true);
        
        u16 menu_count = transporter.menus.size();

        for(u16 i = 0; i < menu_count; i++)
        {
            if(transporter[i] == @null)
            {
                error("Menu was somehow null in rendering. This should not happen."); continue;
            }
            if(transporter[i].getRenderLayer() != layer)//Current layer is not equal?
            {
                continue;//Skip
            }
            RENDER_CALLBACK@ func = transporter[i].getRenderFunction();
            if(func == @null)
            {
                error("rendercallback function was null."); return;
            }
            func();
        }

        Render::SetTransformWorldspace();//Have to do this or kag gets cranky as it forgot to do it itself.
    }
}

NuHub@ o_transporter = @null;//Outer transporter.

bool TransporterInit()
{
    if(o_transporter == @null)//Init.
    {
        getRules().get("NuHub", @o_transporter);
        print("NuMenu rendering transporter got.");
        if(o_transporter == @null)//Still equal to null?
        {
            error("Render function failed to get things to render.");
            return false;
        }
    }
    return true;
}

void MenusPostHud(int id)
{
    if(!TransporterInit()) { return; }

    NuMenu::MenuRender(o_transporter, Render::layer_posthud);
}

void MenusPreHud(int id)
{
    if(!TransporterInit()) { return; }
    
    NuMenu::MenuRender(o_transporter, Render::layer_prehud);
}

void MenusPostWorld(int id)
{
    if(!TransporterInit()) { return; }
    
    NuMenu::MenuRender(o_transporter, Render::layer_postworld);
}

void MenusObjects(int id)
{
    if(!TransporterInit()) { return; }
    
    NuMenu::MenuRender(o_transporter, Render::layer_objects);
}

void MenusTiles(int id)
{
    if(!TransporterInit()) { return; }
    
    NuMenu::MenuRender(o_transporter, Render::layer_tiles);
}

void MenusBackground(int id)
{
    if(!TransporterInit()) { return; }
    
    NuMenu::MenuRender(o_transporter, Render::layer_background);
}