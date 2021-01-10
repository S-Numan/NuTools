

//I'm making a public announcement.
class CRulesBad
{
    CRulesBad()
    {
        Setup();
    }
    
    void Setup()
    {
        menus = array<NuMenu::IMenu@>();
        buttons = array<NuMenu::MenuButton@>();
    }

    bool addMenuToList(NuMenu::IMenu@ _menu)
    {
        menus.push_back(_menu);
        buttons.push_back(@null);

        return true;
    }


    bool addMenuToList(NuMenu::MenuButton@ _menu)
    {
        menus.push_back(_menu);
        buttons.push_back(_menu);

        return true;
    }

    bool removeMenuFromList(u16 i)
    {
        if(i >= menus.size())
        {
            error("Tried to remove menu equal to or above the menu size."); return false;
        }

        menus.removeAt(i);
        buttons.removeAt(i);

        return true;
    }
    
    bool removeMenuFromList(string _name)
    {
        int _namehash = _name.getHash();
        for(u16 i = 0; i < menus.size(); i++)
        {
            if(menus[i].getNameHash() == _namehash)
            {
                menus.removeAt(i);
                buttons.removeAt(i);
                i--;
            }
        }

        return true;
    }

    array<NuMenu::IMenu@> getMenusFromList(string _name)
    {   
        array<NuMenu::IMenu@> _menus();
        
        int _namehash = _name.getHash();
        for(u16 i = 0; i < menus.size(); i++)
        {
            if(menus[i].getNameHash() == _namehash)
            {
                _menus.push_back(@menus[i]);
            }
        }

        return _menus;
    }

    u16 getMenuListSize()
    {
        return menus.size();
    }

    NuMenu::IMenu@ getMenuFromList(u16 i)
    {
        if(i >= menus.size())
        {
            error("Tried to get menu equal to or above the menu size."); return @null;
        }

        return @menus[i];
    }

    NuMenu::IMenu@ getMenuFromList(string _name)
    {
        array<NuMenu::IMenu@> _menus();
        _menus = getMenusFromList(_name);
        if(_menus.size() > 0)
        {
            return _menus[0];
        }
        else
        {
            return @null;
        }
    }

    void ClearMenuList()
    {
        menus.clear();
        buttons.clear();
    }

    array<NuMenu::IMenu@> menus;//CRules touching this array makes casting impossible. Save the array from molestation; Remain a wizard!

    array<NuMenu::MenuButton@> buttons;//Since casting is very broken, this is a way to sidestep the issue.
}
//Don't let more of one of this exist at once. This is our class. Communism, not capitalism.
//I think I'm going crazy.


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
//fix things attached to blobs being a tick delayed
//Stretchy ends for MenuBaseExEx. Drag the menu size around.
//Circular collisions? Collisions atm are too boxy or small. Do distance from point. See bottom of button class.
//Take another look at reposition_text. Optimise perhaps. Perhaps not. Improve it somehow, maybe.
//Make more things in MenuBase methods for IMenu.
//Stop button spazz when pushed against terrain with owner blob. Blob pos freaks out when attached to user while pushing against wall. Try an attachment point? Maybe try making your own with nothing on it to see if it smooths it. Use CShape pos?
//Seperate draw and collision positions?
//Add top right, bottom left, and bottom right to POSPositions
//Confirm the distance calculation with buttons isn't that wonky. It feels wonky. Something has to be wonky
//Rotate value. Only for if I'm really bored. Since it probably wont ever get used. Plus you cannot rotate GUI.
//Editable text while the game is running. Think naming something.
//See if the icon repositioning is actually required for CustomButton.as stuff. Figure out how to not make it required if it is. It shouldn't be.
//Test does not reposition when not interpolated. Look into this

//Option list for debugging blobs.
//Surround blobs in a red box.
//Clicking a blob selects it and shows it's info. OR always show info.
//Type in tags to show details of those tags.



//1. Switch to Render:: instead of gui draw.
//With this, have values for the first part of a sprite. The middle part. And the end part. Modify MenuImage for this.
//Useful things to note:
//Render::SetTransformScreenspace(); Render::SetTransformWorldspace();
//UV is the scale/offset of the image or something? Like saying xy but for texture matrixes. 0.5 would be half image size?
//
//2. Easier menu adding. Just make the menu and add it somewhere and it will run on it's own. No fancy code or other things required. Use NuMenuCommonLogic.as for this.
//3. Seperate menu class and menu option. OR add a method to check what class the class is. So you can cast it easier. Maybe add a method that casts it for you.
//4. Fix CustomButton.as
//5. Before the first tick, the checkbox in menuholder runs away from it's owner.
//6. Move repeated constructor stuff to init vars
//7. Remake text. All text. Add shaky text. And different color text for each induvidual letter.

//
//TODO LIST
//
    //Only one of this class should exist at a time.
    class GlobalVariables
    {
        GlobalVariables()
        {
            FRAME_TIME = 0.0f;
            MARGIN = 255.0f;
            MenuOptionHolder = 100;
        }
        f32 FRAME_TIME; // last frame time
        float MARGIN;//How many pixels away will things stop drawing from outside the screen.
        u8 MenuOptionHolder;//Menu holder option. starts at 100 in case you want to add another MenuOptions enum to it to explain that this holder holds these menu types only.
    }


    float getDistance(Vec2f point1, Vec2f point2)//Add to NumanLib later
    {
        float dis = (Maths::Pow(point1.x-point2.x,2)+Maths::Pow(point1.y-point2.y,2));
        return Maths::Sqrt(dis);
        //return getDistanceToLine(point1, point1 + Vec2f(0,1), point2);
    }
    
    enum POSPositions//Stores all positions that stuff can be in.
    {
        POSTopLeft,
        POSTopRight,
        POSBottomLeft,
        POSBottomRight,
        POSCenter,//in the center of the menu
        POSTop,//positioned on the top of the menu
        POSAbove,//above the top of the menu
        POSBottom,//on the bottom of the menu
        POSUnder,//under the bottom of the menu
        POSLeft,//on the left of the menu
        POSLefter,//left of the left side of the menu
        POSRight,//to the right of the menu
        POSRighter,//right of the right side of the menu

        POSPositionsCount,//Always last, this specifies the amount of positions.
    }


    enum MenuOptions
    {
        Blank,//Nothing
        Custom,//Custom button.
        Button,//Press a button. Buttons have many states. Catch em all!
        Slider,//Slide a slider left and right. Choose color of each side. Increments instead of smoothness is possible too. Both vertical and horizontal. Option to act more like the traditional kag heart system instead of a bar.
        //Option to drag if held or only move if pressed once.
        //Left/right top/down buttons. (buttons appaer to the left and right of the slider. Can press to move slider.)
        //Can cut texture in half or other amounts to display exact loss of health.

        //CheckBox,//Remove my class. Replace with button

        TextBox,//Click this box, and you can type in text! Other options for selecting too.
        TextWriter,//Features such as slowly writing in text. Scrollable text is not drawn if it goes under the menu. If this happens, a scrollbar will appear. (Slider basically)

        MenuOptionsCount,//Always last, this specifies the amount of menu options.
    }

    enum MenuConfiguration//Extension to MenuOptions. For example you can have a Slider with the On off configuration or the Statusbar configuration. For more complicated
    {   
        //TODO, figure out how to make an auto-configeration system for slider and other classes. Maybe a global method or something. Make a method that allows you to pick the cofiguration you want too.
        
        StatusBar = MenuOptionsCount,//Slider: Give a max value and current value. Choose color of each side. This works like a Slider but is automatically configured for ease of use. No draggy bit.
        OnOffSwitch,//Slider: 
        TraditionalSlider,//Slider: (E.G choose a circle. 1-5 circles.)
        CheckBox,//Button: Press once and the button is pressed. Press again and the button is unpressed.
    }

    enum ButtonState
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

    class MenuImage
    {
        MenuImage()
        {
            name = "";
            frame_on = array<u16>(ButtonStateCount, Idle);
            color_on = array<SColor>(ButtonStateCount, SColor(255, 255, 255, 255));
            Vec2f pos = Vec2f_zero;
        }

        void setDefaultFrame(u16 frame)//Sets the regular frame for all button states.
        {
            for(u16 i = 0; i < frame_on.size(); i++)
            {
                frame_on[i] = frame;
            }
        }

        void setDefaultColor(SColor color)//Sets the regular color for all button states.
        {
            for(u16 i = 0; i < color_on.size(); i++)
            {
                color_on[i] = color;
            }
        }

        void setHoverAndPressFrames(u16 hover, u16 press)//Sets frame for hover and press button states.
        {
            frame_on[JustHover] = hover;
            frame_on[Hover] = hover;
            frame_on[JustPressed] = press;
            frame_on[Pressed] = press;
        }
        
        string name;//File name of icon.
        Vec2f frame_size;//The frame size of the icon. (for choosing different frames);
        array<u16> frame_on;//Stores what frame the image is on depending on what state the button is in
        array<SColor> color_on;//Color depending on the button state
        Vec2f pos;//Position of image in relation to the menu.
    }

    interface IMenu
    {
        void initVars();

        string getName();
        int getNameHash();
        void setName(string value);

        IMenu@ getOwnerMenu();
        bool setOwnerMenu(IMenu@ _menu);
        CBlob@ getOwnerBlob();
        bool setOwnerBlob(CBlob@ _blob);
        bool getMoveToOwner();
        void setMoveToOwner(bool value);

        u8 getMenuOption();
        void setMenuOption(u8 value);

        u8 getMenuState();
        u8 getButtonState();
        void setButtonState(u8 _button_state);
        void setMenuState(u8 _button_state);

        bool isWorldPos();
        void setIsWorldPos(bool value);

        bool getRenderBackground();
        void setRenderBackground(bool value);

        bool isInterpolated();
        void setInterpolated(bool value);

        Vec2f getUpperLeftInterpolated();
        Vec2f getPosInterpolated();
        Vec2f getUpperLeft(bool get_raw_pos = false);
        void setUpperLeft(Vec2f value);
        Vec2f getPos(bool get_raw_pos = false);
        void setPos(Vec2f value);
        Vec2f getMiddle(bool get_raw_pos = false);
        Vec2f getLowerRightInterpolated();
        Vec2f getLowerRight(bool get_raw_pos = false);
        void setLowerRight(Vec2f value);
        Vec2f getSize();
        void setSize(Vec2f value);

        Vec2f getUpperLeftOld(bool get_raw_pos = false);
        Vec2f getLowerRightOld(bool get_raw_pos = false);

        bool getPosOnSize(u16 position, Vec2f size, float buffer, Vec2f &out vec_pos);
        bool getDesiredPosOnSize(u16 position, Vec2f size, Vec2f dimensions, float buffer, Vec2f &out pos);

        bool didMenuJustMove();
        void setMenuJustMoved(bool value);

        Vec2f getRelationPos();
        void setRelationPos(Vec2f value);

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
        
        bool Render();

    }

    //Base of all menus.
    class MenuBase : IMenu
    {
        MenuBase(string _name, u8 _menu_option = Custom)// add default option for world pos/screen pos? - Todo numan
        {
            if(!isClient())
            {
                return;
            }

            initVars();
            
            setMenuOption(_menu_option);

            setUpperLeft(Vec2f_zero);
            setLowerRight(Vec2f_zero);

            setInterpolated(true);

            setName(_name);
        }
        
        MenuBase(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option = Custom)// add default option for world pos/screen pos? - Todo numan
        {
            if(!isClient())
            {
                return;
            }

            initVars();
            
            setMenuOption(_menu_option);

            setUpperLeft(_upper_left);
            setLowerRight(_lower_right);

            setInterpolated(true);

            setName(_name);
        }

        void initVars()
        {
            if(!getRules().get("NuGlobalVars", @globalvars))
            {
                error("NuMenuCommonLogic.as must be before anything else that uses NuMenu in gamemode.cfg");
            }

            default_buffer = 4.0f;
            is_world_pos = false;

            name = "";
            name_hash = 0;

            @owner_menu = @null;
            @owner_blob = @null;
            move_to_owner = true;

            button_state = Idle;

            render_background = true;

            did_menu_just_move = true;

            upper_left = array<Vec2f>(4);
            lower_right = array<Vec2f>(4);

            collision_setter = true;

            radius = 0.0f;
        }

        GlobalVariables@ globalvars;

        float default_buffer;

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
        bool setOwnerMenu(IMenu@ _menu)//Be aware, when this menu is moving with it's owner setPos stuff will not do much. You need to change setRelation. As in relation to it's owner.
        {
            if(_menu.getNameHash() == getNameHash())
            {
                error("Tried to make menu its own owner.");
                return false;
            }
            if(_menu.getOwnerMenu() != null && _menu.getOwnerMenu().getNameHash() == getNameHash())
            {
                error("Tried to intertwine ownership of menus.");
                return false;
            }
            if(getOwnerBlob() != null)
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
        bool setOwnerBlob(CBlob@ _blob)//Be aware, when this menu is moving with it's owner setPos stuff will not do much. You need to change setRelation. As in relation to it's owner.
        {
            if(getOwnerMenu() != null)
            {
                error("You cannot have both a menu and blob as an owner at the same time.");
                return false;
            }

            @owner_blob = @_blob;
            return true;
        }

        //Blob
        //

        private bool move_to_owner;//If this is true, this menu will move itself to the position of it's owner with relation added to it. 
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

        private u8 menu_option;//Menu option. (Does this menu has a slider? is it a regular button? does it have a check box?)
        u8 getMenuOption()
        {
            return menu_option;
        }
        void setMenuOption(u8 value)
        {
            menu_option = value;
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
                error("STOP! YOU HAVE VIOLATED THE LAW! PAY THE COURT A FINE OR SERVE YOUR SENTENCE. YOUR HIGHER THAN POSSIBLE BUTTON STATE IS NOW FORFEIT");
                return;
            }
            button_state = _button_state;
        }
        void setMenuState(u8 _button_state)
        {
            setButtonState(_button_state);
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
                upper_left[1] = getUpperLeft(true);//set old
                lower_right[1] = getLowerRight(true);//set old
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
        Vec2f getUpperLeft(bool get_raw_pos = false)//If this bool is true; even if isWorldPos() is true, it will get the raw position. I.E in most cases the actual world position. not the world to screen pos. does nothing if isWorldPos is false.
        {
            if(isWorldPos() && !get_raw_pos)
            {
                //CCamera@ camera = getCamera();
                //This might be slow. - Todo numan
                return getDriver().getScreenPosFromWorldPos(upper_left[0]);
            }
            
            return upper_left[0];
        }
        void setUpperLeft(Vec2f value)
        {
            upper_left[0] = value;
            menu_size = Vec2f(lower_right[0].x - upper_left[0].x, lower_right[0].y - upper_left[0].y);
            if(getCollisionSetter())//If the collision setter is not disabled.
            {
                upper_left[3] = Vec2f_zero;//Reset collisinos
            }

            setMenuJustMoved(true);
        }

        //Changes the upper left position and lower right at the same time. No changes to the size of the menu.
        void setPos(Vec2f value)
        {
            upper_left[0] = value;
            lower_right[0] = upper_left[0] + menu_size;

            setMenuJustMoved(true);
        }
        Vec2f getPos(bool get_raw_pos = false)
        {
            return getUpperLeft(get_raw_pos);
        }

        //Not in relation to the menu
        Vec2f getMiddle(bool get_raw_pos = false)
        {
            Vec2f _upper_left = getUpperLeft(get_raw_pos);//Upper left

            _upper_left += getSize() / 2;//Add the size divided by two.

            return _upper_left;
        }

        private array<Vec2f> lower_right(3);//Lower right of menu. [0] is normal; [1] is old; [2] is interpolated; [3] is collision
        Vec2f getLowerRight(bool get_raw_pos = false)//If this bool is true; even if isWorldPos() is true, it will get the raw position. I.E in most cases the actual world position. not the world to screen pos. does nothing if isWorldPos is false.
        {
            if(isWorldPos() && !get_raw_pos)
            {
                return getDriver().getScreenPosFromWorldPos(lower_right[0]);
            }

            return lower_right[0];
        }
        void setLowerRight(Vec2f value)
        { 
            lower_right[0] = value;
            menu_size = Vec2f(lower_right[0].x - upper_left[0].x, lower_right[0].y - upper_left[0].y);

            if(getCollisionSetter())//If the collision setter is not disabled.
            {
                lower_right[3] = menu_size;//Reset collisinos
            }

            setMenuJustMoved(true);
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



        bool getPosOnSize(u16 position, Vec2f size, float buffer, Vec2f &out vec_pos)//Insert an enum for a position based on the menu. Note that this only gives you positions based on the size. Not position on screen/world. Add getPos() to this if you want the real position.
        {

            switch(position)
            {
                case POSTopLeft:
                    vec_pos = Vec2f(0, 0);
                    break;
                case POSTopRight:
                    vec_pos = Vec2f(size.x, 0);
                    break;
                case POSBottomLeft:
                    vec_pos = Vec2f(0, size.y);
                    break;
                case POSBottomRight:
                    vec_pos = Vec2f(size.x, size.y);
                    break;
                case POSCenter:
                    vec_pos = Vec2f(size.x/2, size.y/2);
                    break;
                case POSTop:
                    vec_pos = Vec2f(size.x/2, buffer);
                    break;
                case POSAbove:
                    vec_pos = Vec2f(size.x/2, -buffer); 
                    break;
                case POSBottom:
                    vec_pos = Vec2f(size.x/2, size.y - buffer);
                    break;
                case POSUnder:
                    vec_pos = Vec2f(size.x/2, size.y + buffer);
                    break;
                case POSLeft:
                    vec_pos = Vec2f(buffer, size.y/2);
                    break;
                case POSLefter:
                    vec_pos = Vec2f(-buffer, size.y/2);
                    break;
                case POSRight:
                    vec_pos = Vec2f(size.x - buffer, size.y/2);
                    break;
                case POSRighter:
                    vec_pos = Vec2f(size.x + buffer, size.y/2);
                    break;
                default://Position out of bounds
                {
                    vec_pos = Vec2f_zero;//Just return 0,0
                    return false;//Nope.
                }
            }

            return true;
        }

        //This method takes details from getPosOnSize, and a dimension to properly center something within (or outside) the menu. For example, this stops text from being displayed outside of the menu, and instead changes the pos to inside just enough.
        //Takes in a enum position, the size of the menu, the dimensions of what you're putting in the menu, a buffer, and an input/output pos. Returns false if the position was not found.
        bool getDesiredPosOnSize(u16 position, Vec2f size, Vec2f dimensions, float buffer, Vec2f &out pos)
        {
            if(!getPosOnSize(position, size, buffer, pos))
            {
                return false;
            }
            
            switch(position)
            {
                case POSTopLeft:
                    pos = Vec2f(pos.x                 , pos.y);
                    break;
                case POSTopRight:
                    pos = Vec2f(pos.x - dimensions.x/2, pos.y);
                    break;
                case POSBottomLeft:
                    pos = Vec2f(pos.x                 , pos.y - dimensions.y);
                    break;
                case POSBottomRight:
                    pos = Vec2f(pos.x - dimensions.x/2, pos.y - dimensions.y);
                    break;
                case POSCenter:
                    pos = Vec2f(pos.x - dimensions.x/2, pos.y - dimensions.y/2);
                    break;
                case POSTop:
                    pos = Vec2f(pos.x - dimensions.x/2, pos.y);
                    break;
                case POSAbove:
                    pos = Vec2f(pos.x - dimensions.x/2, pos.y - dimensions.y); 
                    break;
                case POSBottom:
                    pos = Vec2f(pos.x - dimensions.x/2, pos.y - dimensions.y);
                    break;
                case POSUnder:
                    pos = Vec2f(pos.x - dimensions.x/2, pos.y);
                    break;
                case POSLeft:
                    pos = Vec2f(pos.x                 , pos.y - dimensions.y/2);
                    break;
                case POSLefter:
                    pos = Vec2f(pos.x - dimensions.x  , pos.y - dimensions.y/2);
                    break;
                case POSRight:
                    pos = Vec2f(pos.x - dimensions.x  , pos.y - dimensions.y/2);
                    break;
                case POSRighter:
                    pos = Vec2f(pos.x                 , pos.y - dimensions.y/2);
                    break;
                default:
                {
                    pos = Vec2f_zero;
                    return false;
                }
            }

            return true;
        }

        //
        //Normal Positions


        //Old Positions
        //

        Vec2f getUpperLeftOld(bool get_raw_pos = false)
        {
            if(isWorldPos() && !get_raw_pos)
            {
                return getDriver().getScreenPosFromWorldPos(upper_left[1]);
            }
            
            return upper_left[1];
        }
        Vec2f getLowerRightOld(bool get_raw_pos = false)
        {
            if(isWorldPos() && !get_raw_pos)
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
        }

    

        //
        //Old Positions

        //Relation positions
        //

        private Vec2f relation_pos;//For moving this in relation to something else

        Vec2f getRelationPos()
        {
            return relation_pos;
        }
        void setRelationPos(Vec2f value)
        {
            relation_pos = value;
            //setMenuJustMoved(true);//Not sure if this should be here.
        }

        //
        //Relation positions

        //Collisions
        //
        

        //Not in relation to the menu.
        Vec2f getCollisionUpperLeft(bool get_raw_pos = false)
        {
            if(isWorldPos() && !get_raw_pos)
            {
                return getDriver().getScreenPosFromWorldPos(upper_left[0] + upper_left[3]);
            }

            return upper_left[0] + upper_left[3];//Top left of the menu plus the top left collision position.
        }
        Vec2f getCollisionLowerRight(bool get_raw_pos = false)
        {
            if(isWorldPos() && !get_raw_pos)
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
                if(getDistance(getMiddle(), value) < getRadius() * (isWorldPos() ? getCamera().targetDistance : 1))//If the distance between the middle and value is less than the radius 
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

            if(didMenuJustMove())//If the menu just moved
            {
                setMenuJustMoved(false);//Well it didn't just move anymore.
            }

            //Set the interpolated values to the positions.
            upper_left[2] = getUpperLeft();
            lower_right[2] = getLowerRight();

            //And make the old be equal to the new.
            upper_left[1] = getUpperLeft(true);
            lower_right[1] = getLowerRight(true);


            //Automatically move to blob if there is an owner blob and getMoveToOwner is true.
            CBlob@ _owner_blob = getOwnerBlob();
            if(_owner_blob != null && getMoveToOwner())
            {
                setPos(_owner_blob.getPosition() + getRelationPos());
            }  

            CPlayer@ player = getLocalPlayer();
            if(player == null)//The player must exist to get the CControls. (and maybe some other stuff)
            {
                return false;
            }

            CControls@ controls = player.getControls();
            if(controls == null)//The controls must exist
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
            if(isInterpolated())
            {
                if(didMenuJustMove())
                {
                    CBlob@ _blob = getOwnerBlob();

                    if(_blob != null && getMoveToOwner())//If this menu has an owner blob and it is supposed to move towards it.
                    {
                        CCamera@ camera = getCamera();
                        Driver@ driver = getDriver();//This might be even slower. - Todo numan
                        
                        
                        upper_left[2] = driver.getScreenPosFromWorldPos(_blob.getInterpolatedPosition())//Screen position of the blob plus
                        + getRelationPos() * (camera.targetDistance * 2);//the relation pos times the camera distance times 2

                        lower_right[2] = upper_left[2]//Upper left interpolated plus
                        + (getSize()) * (camera.targetDistance * 2);//The menu size times the camera distance times 2
                    }
                    else//*/
                    {
                        upper_left[2] = Vec2f_lerp(getUpperLeftOld(), getUpperLeft(), globalvars.FRAME_TIME);

                        lower_right[2] = Vec2f_lerp(getLowerRightOld(), getLowerRight(), globalvars.FRAME_TIME);
                    }
                    //print(FRAME_TIME+'');
                
                }
                else if(isWorldPos())//Basically if the camera moved, Move the menu too.
                {
                    upper_left[2] = getUpperLeft();
                    lower_right[2] = getLowerRight();
                }
            }
            else
            {
                upper_left[2] = getUpperLeft();
                lower_right[2] = getLowerRight();
            }
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
       
        bool Render()//Overwrite this method if you want a different look.
        {
            Driver@ driver = getDriver();

            //If this cannot be seen. This is out of range. 
            if(getUpperLeft().x  - globalvars.MARGIN > driver.getScreenWidth()
            || getUpperLeft().y  - globalvars.MARGIN > driver.getScreenHeight()
            || getLowerRight().x + globalvars.MARGIN < 0
            || getLowerRight().y + globalvars.MARGIN < 0 )
            {
                return false;//Don't draw it then.
            }

            InterpolatePositions();//Don't forget this if you want interpolation.

            if(getRenderBackground())
            {
                SColor rec_color;
                switch(getButtonState())
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
                
                GUI::DrawRectangle(getUpperLeftInterpolated(), getLowerRightInterpolated(), rec_color);
            }

            return true;
        }

        //
        //Rendering
        //
    }
    









    class MenuBaseEx : MenuBase
    {
        MenuBaseEx(string _name, u8 _menu_option = Custom)
        {
            if(!isClient()) { return; }

            super(_name, _menu_option);
        }

        MenuBaseEx(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option = Custom)
        {
            if(!isClient()) { return; }

            super(_upper_left, _lower_right, _name, _menu_option);
        }

        void initVars() override
        {
            MenuBase::initVars();

            icons_used = false;
            draw_icons = true;
            reposition_icons = false;

            initial_press = false;
        
            icons = array<NuMenu::MenuImage@>(POSPositionsCount);

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
                if(reposition_icons)
                {
                    RepositionAllIcons(getSize());
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
                    Sound::Play(menu_sounds_on[_button_state], getPos(true), menu_volume, 1.0f);
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
        //Icon stuff
        //
        
        bool draw_icons;
        bool reposition_icons;//If this is true, the icons's position will be reassigned every time the menu moves based on what icon position it is in. top will be put back on the top every movement.
        
        
        private array<NuMenu::MenuImage@> icons;

        
        MenuImage@ setIcon(string icon_name, Vec2f icon_frame_size, u16 icon_frame_default, u16 icon_frame_hover, u16 icon_frame_press, u16 position = 0)
        {
            if(icons.size() <= position){ error("In setIcon : tried to get past the highest element in the icons array."); return @null; }
            
            MenuImage@ icon = MenuImage();
            
            icon.name = icon_name;
            icon.frame_size = icon_frame_size;

            icon.setDefaultFrame(icon_frame_default);
            
            icon.setHoverAndPressFrames(icon_frame_hover, icon_frame_press);
            
            Vec2f icon_pos;
            
            if(!getDesiredPosOnSize(position, getSize(), icon.frame_size, default_buffer /* (isWorldPos() ? getCamera().targetDistance : 1)*/, icon_pos))//Move that pos.
            {
                error("setIcon position was an unknown position");
                return @null;
            }
            
            icon.pos = icon_pos;// + getSize() / 2 - icon.frame_size;


            @icons[position] = @icon;

            icons_used = UpdateAreIconsUsed();
        
            return icon;
        }
        
        MenuImage@ getIcon(u16 position = 0)
        {
            if(icons.size() <= position){ error("In getIcon : tried to get past the highest element in the icons array."); return null; }

            return icons[position];
        }

        u16 getIconCount()
        {
            return icons.size();
        }

        void setIconPos(Vec2f icon_pos, u16 position = 0)
        {
            if(icons.size() <= position){ error("In setIconPos : tried to get past the highest element in the icons array."); return; }

            icons[position].pos = icon_pos;

        }

        void RepositionAllIcons(Vec2f size)
        {
            if(areIconsUsed())
            {
                CCamera@ camera;
                if(isWorldPos())
                {
                    @camera = @getCamera();
                }
                
                for(u16 i = 0; i < POSPositionsCount; i++)
                {
                    MenuImage@ icon = getIcon(i);
                        
                    if(icon == null)
                    {
                        continue;
                    }

                    Vec2f icon_pos;
                    
                    if(!getDesiredPosOnSize(i, size, icon.frame_size, default_buffer /* (isWorldPos() ? getCamera().targetDistance : 1)*/, icon_pos))//Move that pos.
                    {
                        error("Icon position went above the icons array max size");
                        return;
                    }
                    
                    icon.pos = icon_pos;
                }
            }
        }


        
        private bool icons_used;

        private bool UpdateAreIconsUsed()//Updates the text_used bool.
        {
            for(u16 i = 0; i < icons.size(); i++)
            {
                if(icons[i] == null)
                {
                    continue;
                }
                
                return true;
            }
            return false;
        }

        bool areIconsUsed()
        {
            return icons_used;
        }

        //
        //Icon stuff
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
            
            if(draw_icons)
            {
                DrawIcons();
            }

            return true;
        }

        void DrawIcons()
        {
            if(!areIconsUsed())
            {
                return;
            }
            CCamera@ camera;
            if(isWorldPos())
            {
                @camera = @getCamera();
            }

            //Reposition icons.
            if(reposition_icons && isInterpolated()//If this menu is interpolated
            && (didMenuJustMove() || isWorldPos()))//And the menu just moved or is on a world position.
            {
                RepositionAllIcons(getLowerRightInterpolated() - getUpperLeftInterpolated());
            }

            for(u16 i = 0; i < icons.size(); i++)
            {
                if(icons[i] == null)
                {
                    continue;
                }
                

                GUI::DrawIcon(icons[i].name,//Icon name
                icons[i].frame_on[button_state],//Icon frame
                icons[i].frame_size,//Icon size
                getUpperLeftInterpolated() + icons[i].pos * (isWorldPos() ? camera.targetDistance * 2: 1),//Icon position
                isWorldPos() ? camera.targetDistance : 0.5,//Icon scale
                icons[i].color_on[button_state]);//Color
            }
        }

        //
        //Rendering
        //

    }
    
    //Base of all menus + previous ex + this. Includes text, and a titlebar (can be hidden and simply used for dragging the menu.)
    class MenuBaseExEx : MenuBaseEx
    {
        MenuBaseExEx(string _name, u8 _menu_option = Custom)
        {
            if(!isClient()) { return; }

            super(_name, _menu_option);
            
            setTextColor(SColor(255, 0, 0, 0));

            setFont("AveriaSerif-Bold.ttf", 4);
        }

        MenuBaseExEx(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option = Custom)
        {
            if(!isClient()) { return; }

            super(_upper_left, _lower_right, _name, _menu_option);

            setTextColor(SColor(255, 0, 0, 0));

            setFont("AveriaSerif-Bold.ttf", 4);
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
            resize_text = false;
            text_used = false;

            text_strings = array<string>(POSPositionsCount, "");
            text_positions = array<Vec2f>(POSPositionsCount);
            font_size = 4;
            font = "";
            text_color = SColor(255, 0, 0, 0);
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
                //Optimize me, this will be done twice a tick if both top left and bottom right are moved. That is no goodo.
                if(reposition_text)
                {
                    RepositionAllText(getSize());
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

        private u16 font_size;
        private string font;//Font used.
        string getFont()
        {
            return font;
        }
        u16 getFontSize()
        {
            return font_size;
        }
        //This loads a custom font for the menu. This does not pick an existing font.
        void setFont(string _font, u16 size)//TODO - numan : Make text smoothly grow and shrink
        {
            font = _font;
            font_size = size;
            string fontfile = CFileMatcher(_font).getFirst();
            
            
            if (!GUI::isFontLoaded(font))
            {
                GUI::LoadFont(font, fontfile, size, true);
            }
            else if (!GUI::isFontLoaded(font + "_" + (size / 2)))
            {
                GUI::LoadFont(font + "_" + (size / 2), fontfile + "_1", size / 2, true);
            }
            else if (!GUI::isFontLoaded(font + "_" + (size * 2)))
            {
                GUI::LoadFont(font + "_" + (size * 2), fontfile + "_2", size * 2, true);
            }
        }
        
        void SelectFont()
        {
            CCamera@ camera = getCamera();
            if(resize_text && isWorldPos())
            {
                //if(camera.targetDistance < 0.9)
                //{
                //    GUI::SetFont(font + "_" + (getFontSize() / 2));
                //}
                //else if(camera.targetDistance > 0.9 && camera.targetDistance < 1.1)
                //{
                    GUI::SetFont(font);
                //}
                //else//Camera targetDistance more than 1.1
                //{
                //    GUI::SetFont(font + "_" + (getFontSize() * 2));
                //}
            }
            else
            {
                GUI::SetFont(font);
            }
        }


        private SColor text_color;
        SColor getTextColor()
        {
            return text_color;
        }
        void setTextColor(SColor value)
        {
            text_color = value;
        }

        //
        //Text settings

        bool draw_text;
        bool resize_text;
        bool reposition_text;//If this is true, the text's position will be reassigned every time the menu moves based on what text it is. top will be put back on the top every movement.
        
        
        private array<string> text_strings;
        private array<Vec2f> text_positions;

        string getText(u16 array_position)
        {
            if(array_position >= text_strings.size()){error("getText : Tried to get text out of array bounds"); return ""; }

            return text_strings[array_position];
        }
        void setText(string text, u16 array_position)
        {
            if(array_position >= text_strings.size()){error("setText : Tried to get text out of array bounds"); return; }
            
            GUI::SetFont(font);
            Vec2f text_pos;
            
            Vec2f text_dimensions;
            GUI::GetTextDimensions(text, text_dimensions);
            
            if(!getDesiredPosOnSize(array_position, getSize(), text_dimensions, default_buffer, text_pos))//Move that pos.
            {
                error("Text position went above the text_positions array max size");
                return;
            }


            text_positions[array_position] = text_pos;
            
            text_strings[array_position] = text;

            text_used = UpdateIsTextUsed();
        }

        void RepositionAllText(Vec2f size)
        {
            if(isTextUsed())
            {
                GUI::SetFont(font);
                
                for(u16 i = 0; i < POSPositionsCount; i++)
                {
                    string text = getText(i);
                        
                    if(text.size() == 0)
                    {
                        continue;
                    }

                    Vec2f text_pos;
            
                    Vec2f text_dimensions;
                    GUI::GetTextDimensions(text, text_dimensions);

                    if(!getDesiredPosOnSize(i, size, text_dimensions, default_buffer, text_pos))//Move that pos.
                    {
                        error("Text position went above the text_positions array max size");
                        return;
                    }
                    
                    setTextPos(text_pos, i);
                }
            }
        }


        
        Vec2f getTextPos(u16 array_position)
        {
            if(array_position >= text_strings.size()){error("getTextPos : Tried to get text out of array bounds"); return Vec2f_zero; }

            return text_positions[array_position];
        }
        void setTextPos(Vec2f value, u16 array_position)
        {
            if(array_position >= text_strings.size()){error("setTextPos : Tried to get text out of array bounds"); return; }
            
            text_positions[array_position] = value;
        }


        private bool text_used;

        private bool UpdateIsTextUsed()//Updates the text_used bool.
        {
            for(u16 i = 0; i < text_strings.size(); i++)
            {
                if(text_strings[i].size() != 0)
                {
                    return true;
                }
            }
            return false;
        }

        bool isTextUsed()
        {
            return text_used;
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
            Vec2f _upperleft = getUpperLeft(true);
            
            if(value.x <= getLowerRight(true).x - (getSize().x - titlebar_size.x) //If the point is to the left of the titlebar's right side.
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
                titlebar_size.x = getSize().x * (getCamera().targetDistance * 2);
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
                        MenuBaseExEx::setPos(getUpperLeft(true) - //Current menu position subtracted by
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
            bool _draw_icons = draw_icons;//Make a temp value called _draw_icons and make it equal to draw_icons.

            if(draw_icons)//If draw_icons is true
            {
                draw_icons = false;//Make it false. This is done to prevent the icons from being drawn before the titlebar. That would be no good.
            }

            if(!MenuBaseEx::Render())
            {
                draw_icons = _draw_icons;//Rendering failed, revert draw_icons to it's original state.
                return false;
            }
            draw_icons = _draw_icons;//If MenuBaseEx was going to draw an icon, it wouldn't. Revert back draw_icon.


            
            if(draw_titlebar)//Draw the titlebar first
            {
                DrawTitlebar();
            }
            
            if(draw_icons)//Then draw icons
            {
                DrawIcons();
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
            titlebar_size.y * (isWorldPos() ? getCamera().targetDistance * 2 : 1))); //titlebar_size.y multiplied by the camera distance if isWorldPos() is true.

            GUI::DrawRectangle(_upperleft, _lowerright);
        }


        void DrawTexts()
        {
            if(!isTextUsed())
            {
                return;
            }
            SelectFont();//Sets the font

            //For repositionioning text in an interpolated manner. Only works if reposition_text is true.
            if((reposition_text && isInterpolated())//If this menu is interpolated 
            && (didMenuJustMove() || isWorldPos()))//and the menu just moved or is on a world position.
            {
                RepositionAllText(getLowerRightInterpolated() - getUpperLeftInterpolated());
            }

            for(u16 i = 0; i < text_strings.size(); i++)
            {
                if(text_strings[i].size() == 0)
                {
                    continue;
                }
                GUI::DrawText(text_strings[i], getUpperLeftInterpolated() + text_positions[i] * (isWorldPos() && !reposition_text ? getCamera().targetDistance * 2: 1), //* (isWorldPos() ? 1 * 1 : 1),//lol what?
                text_color);
            }
        }
    }

    funcdef void BUTTONCALLBACK(CBitStream);
    //Menu set up to function like a button.
    class MenuButton : MenuBaseExEx
    {
        MenuButton(string _name)
        {
            if(!isClient())
            {
                return;
            }

            super(_name, Button);
        }

        MenuButton(string _name, CBlob@ blob)
        {
            if(!isClient())
            {
                return;
            }

            super(_name, Button);
            
            setOwnerBlob(blob);//This is the button's owner. The button will follow this blob (can be disabled).
            setIsWorldPos(true);//The position of the button is in the world, not the screen as the button is following a blob, a thing in the world. Therefor isWorldPos should be true.
            //Remove this and see what happens for funzies. - TODO Numan
        }

        MenuButton(Vec2f _upper_left, Vec2f _lower_right, string _name)
        {
            if(!isClient())
            {
                return;
            }

            super(_upper_left, _lower_right, _name, Button);
        }

        void initVars() override
        {
            MenuBaseExEx::initVars();
            send_to_rules = false;
            kill_on_release = false;
            instant_press = false;

            enableRadius = 0.0f;

            func = @null;

            command_string = "";
        }

        BUTTONCALLBACK@ func;//The function called upon being pressed.


        string command_string;//The command id sent out upon being pressed.
        bool send_to_rules;//If this is false, it will attempt to send the command_string to the owner blob. Otherwise it will send it to CRules.
        CBitStream params;//The params to accompany above


        bool kill_on_release;//Does nothing. Just holds a value in case someone wants to use it.

        bool instant_press;//If this is true, the button will trigger upon being just pressed.

        float enableRadius;//The radius at which the button can be pressed


        bool Tick() override
        {
            CPlayer@ player = getLocalPlayer();
            if(player == null){return false;}
            CControls@ controls = player.getControls();
            if(controls == null){return false;}
            
            return Tick(KEY_LBUTTON, controls.getMouseScreenPos());
        }

        bool Tick(Vec2f position)
        {
            CPlayer@ player = getLocalPlayer();
            if(player == null){return false;}
            CControls@ controls = player.getControls();
            if(controls == null){return false;}
            
            return Tick(KEY_LBUTTON, controls.getMouseScreenPos(), position);
        }

        //Examples: point parameter for the mouse position, the position parameter is for the blob. position parameter only really useful when it comes to radius stuff.
        bool Tick(u16 key_code, Vec2f point, Vec2f position = Vec2f_zero)
        {
            if(!MenuBaseExEx::Tick())
            {
                return false;
            }

            CPlayer@ player = getLocalPlayer();

            CControls@ controls = player.getControls();
            
            bool key_button = controls.isKeyPressed(key_code);//Pressing
            bool key_button_release = controls.isKeyJustReleased(key_code);//Just released
            bool key_button_just = controls.isKeyJustPressed(key_code);//Just pressed

            
            u8 _button_state = getButtonState();//Get the button state.

            if(enableRadius == 0.0f || position == Vec2f_zero ||//Provided both these values have been assigned, the statement below will check.
            getDistance(position, getMiddle(true)) < enableRadius)//The button is within enable(interact) distance.
            {
                _button_state = getPressingState(point, _button_state, key_button, key_button_release, key_button_just);//Get the pressing state. That pun in intentional.
            }
            else//enableRadius and position were assigned, and the button was out of range.
            {
                _button_state = Disabled;//The button is disabled
            }

            if(_button_state == Released)//If the button was released.
            {
                sendCommand();//Send the command.
            }

            if(instant_press && _button_state == JustPressed)//If the button is supposed to be released instantly upon press.
            {
                sendCommand();//Send the command.
                _button_state = Released;//The button was basically released, so tell it to actually release. To prevent it from sending the command twice.
            }

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

        void sendCommand()
        {
            if(command_string != "")//If there is a command_string to send.
            {
                if(send_to_rules)//if send_to_rules is true.
                {
                    CRules@ _rules = getRules();

                    _rules.SendCommand(_rules.getCommandID(command_string), params);
                }
                else if(getOwnerBlob() != null)//If send_to_rules is false, send it to the owner_blob. Provided it exists.
                {
                    CBlob@ _owner = getOwnerBlob();

                    _owner.SendCommand(_owner.getCommandID(command_string), params);
                }
            }
            if(func != null)
            {
                func(params);
            }
        }
    }

    //Menu setup to function like an check box. Click once and it's state changes.
    class MenuCheckBox : MenuBaseExEx
    {
        string test_name;

        MenuCheckBox(string _name)
        {
            if(!isClient())
            {
                return;
            }

            super(_name, CheckBox);

            render_background = false;
        }
        MenuCheckBox(Vec2f _upper_left, Vec2f _lower_right, string _name)
        {
            if(!isClient())
            {
                return;
            }

            super(_upper_left, _lower_right, _name, CheckBox);

            render_background = false;
        }

        

        void Setup()
        {
            test_name = "_haha_fishy_fish_fishers";
            //ensure texture for our use exists
            if(!Texture::exists(test_name))
            {
                if(!Texture::createBySize(test_name, 8, 8))
                {
                    warn("texture creation failed");
                }
                else
                {
                    ImageData@ edit = Texture::data(test_name);

                    for(int i = 0; i < edit.size(); i++)
                    {
                        edit[i] = SColor((((i + i / 8) % 2) == 0) ? 0xff707070 : 0xff909090);
                    }

                    if(!Texture::update(test_name, edit))
                    {
                        warn("texture update failed");
                    }
                }
            }

            int hud_cb_id = Render::addScript(Render::layer_prehud, "NuMenuCommon.as", "RulesHUDRenderFunction", 0.0f);
        }

        void initVars() override
        {
            MenuBaseExEx::initVars();
            menu_checked = false;

            Setup();
        }

        bool menu_checked;

        bool Tick() override
        {
            if(!MenuBaseExEx::Tick())
            {
                return false;
            }

            CPlayer@ player = getLocalPlayer();

            CControls@ controls = player.getControls();

            Vec2f mouse_pos = controls.getMouseScreenPos();
            
            bool left_button = controls.mousePressed1;//Pressing
            bool left_button_release = controls.isKeyJustReleased(KEY_LBUTTON);//Just released
            bool left_button_just = controls.isKeyJustPressed(KEY_LBUTTON);//Just pressed

            button_state = getPressingState(mouse_pos, button_state, left_button, left_button_release, left_button_just);

            if(button_state == Released)
            {
                menu_checked = !menu_checked;
            }
            
            return true;
        }

        Vec2f[] v_pos;
        Vec2f[] v_uv;
        SColor[] v_col;

        u16[] v_i;

        //this is the highest performance option
        Vertex[] v_raw;

        bool Render() override
        {
            if(!MenuBaseExEx::Render())
            {
                return false;
            }

            //InterpolatePositions();

            v_pos.clear();
            v_uv.clear();
            v_col.clear();
            v_i.clear();
            v_raw.clear();
            Render::SetTransformScreenspace();


            Vec2f p = Vec2f_zero;//getUpperLeftInterpolated();
            CMap@ map = getMap();

            float x_size = 32;
            float y_size = 32;
            
            f32 z = -0.1;



            v_pos.push_back(p + Vec2f(-x_size,-y_size)); v_uv.push_back(Vec2f(0,0));
            v_pos.push_back(p + Vec2f( x_size,-y_size)); v_uv.push_back(Vec2f(1,0));
            v_pos.push_back(p + Vec2f( x_size, y_size)); v_uv.push_back(Vec2f(1,1));
            v_pos.push_back(p + Vec2f(-x_size, y_size)); v_uv.push_back(Vec2f(0,1));

            Render::Quads(test_name, z, v_pos, v_uv);

            /*if(menu_checked == true)
            {
                GUI::DrawRectangle(getUpperLeftInterpolated(), getLowerRightInterpolated(), SColor(255, 25,127,25));
            }
            else
            {
                GUI::DrawRectangle(getUpperLeftInterpolated(), getLowerRightInterpolated(), SColor(255, 127,25,25));
            }*/

            Render::SetTransformWorldspace();//Have to do this or kag gets cranky as it forgot to do it itself.

            return true;
        }
    }









    //This menu is designed to hold other menu's and keep them attached to it.
    class MenuHolder : MenuBaseExEx
    {
        MenuHolder(string _name)
        {
            if(!isClient())
            {
                return;
            }
            super(_name, 100);//TODO MenuOptionHolder global var
        }

        MenuHolder(Vec2f _upper_left, Vec2f _lower_right, string _name)
        {
            if(!isClient())
            {
                return;
            }
            super(_upper_left, _lower_right, _name, 100);//TODO MenuOptionHolder global var
        }

        void initVars() override
        {
            MenuBaseExEx::initVars();
        }

        


        //
        //Overrides
        //

        void setUpperLeft(Vec2f value) override
        {
            MenuBaseExEx::setUpperLeft(value);
            moveHeldMenus();
        }

        void setPos(Vec2f value) override
        {
            MenuBaseExEx::setPos(value);
            moveHeldMenus();
        }
        void setLowerRight(Vec2f value) override
        { 
            MenuBaseExEx::setLowerRight(value);
            moveHeldMenus();
        }

        void setSize(Vec2f value) override
        {
            MenuBaseExEx::setSize(value);
            moveHeldMenus();
        }
        
        void setInterpolated(bool value) override
        {
            MenuBaseExEx::setInterpolated(value);
            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(optional_menus[i] == null)
                {
                    continue;
                }

                optional_menus[i].setInterpolated(value);
            }
        }

        void setIsWorldPos(bool value) override
        {
            MenuBaseExEx::setIsWorldPos(value);
            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(optional_menus[i] == null)
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
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != null)
            {
                return optional_menus[option_menu].getRelationPos();
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
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != null)
            {
                IMenu@ _menu = @optional_menus[option_menu];
                _menu.setRelationPos(value);
                
                if(_menu.getMoveToOwner())
                {
                    _menu.setPos(getPos(true) + _menu.getRelationPos());
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
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != null)
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
                case Button:
                {
                    MenuButton@ _menu = MenuButton(_name + "_but");


                    optional_menus.push_back(@_menu);
                    break;
                }
                case CheckBox:
                {
                    MenuCheckBox@ _menu = MenuCheckBox(_name + "_chk");


                    optional_menus.push_back(@_menu);
                    break;
                }
                default:
                    break;
            }

            optional_menu_id_count++;


            if(optional_menus.size() != 0 && optional_menus[optional_menus.size() - 1] != null)
            {
                IMenu@ added_menu = @optional_menus[optional_menus.size() - 1];

                added_menu.setIsWorldPos(isWorldPos());
                added_menu.setSize(optional_menu_size);
                added_menu.setInterpolated(isInterpolated());

                //added_menu.setRelationPos(Vec2f(getSize().x - optional_menu_size.x - default_buffer, getSize().y/2 - optional_menu_size.y/2));

                added_menu.setOwnerMenu(this);


                added_menu.setPos(getPos(true) + added_menu.getRelationPos());

                return @added_menu;
            }
            
            return @null;
        }


        void moveHeldMenus()
        {
            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(optional_menus[i] == null)
                {
                    error("optional_menu was null");
                    continue;
                }

                if(!optional_menus[i].getMoveToOwner())
                {
                    continue;
                }
                
                optional_menus[i].setPos(getPos(true) + optional_menus[i].getRelationPos());
            }
        }

        //
        //Optional Menus
        //


        bool Tick() override
        {
            
            if(!MenuBaseExEx::Tick())
            {
                return false;
            }

            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(optional_menus[i] != null)
                {
                    optional_menus[i].Tick();
                }
            }
            if(titlebar_press_pos != Vec2f_zero)
            {
                moveHeldMenus();
            }
            return true;
        }

        bool Render() override
        {
            if(!MenuBaseExEx::Render())
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
                /*switch(optional_menus[i].getMenuOption())
                {
                    case CheckBox:
                    {
                        optional_menus[i].Render();
                        break;
                    }

                    default:
                    error("Menu option not found in render\n menu option is " + optional_menus[i].getMenuOption());
                    //GUI::DrawRectangle(upper_left + optional_menus[i].getUpperLeftRelation(), upper_left + optional_menus[i].getLowerRightRelation());
                    break;
                }*/
                optional_menus[i].Render();
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



    //This adds a menu to the list on the end.
    bool addMenuToList(NuMenu::IMenu@ _menu)
    {
        CRules@ rules = getRules();

        CRulesBad@ rulesbad;
        if(!rules.get("NuMenus", @rulesbad))
        {
            error("Failed to get menu. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return false;
        }
        return rulesbad.addMenuToList(_menu);
    }
    //If this is a button, add it to the button array to.
    bool addMenuToList(NuMenu::MenuButton@ _menu)
    {
        CRules@ rules = getRules();

        CRulesBad@ rulesbad;
        if(!rules.get("NuMenus", @rulesbad))
        {
            error("Failed to get menu. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return false;
        }
        return rulesbad.addMenuToList(_menu);
    }

    //This removes the menu on a certain position in the list.
    bool removeMenuFromList(u16 i)
    {
        CRules@ rules = getRules();

        CRulesBad@ rulesbad;
        if(!rules.get("NuMenus", @rulesbad))
        {
            error("Failed to get menu. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return false;
        }
        return rulesbad.removeMenuFromList(i);
    }
    //This removes all menus with the same name as the argument on the list.
    bool removeMenuFromList(string _name)
    {
        CRules@ rules = getRules();

        CRulesBad@ rulesbad;
        if(!rules.get("NuMenus", @rulesbad))
        {
            error("Failed to get menu. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return false;
        }

        return rulesbad.removeMenuFromList(_name);
    }
    
    IMenu@ getMenuFromList(u16 i)
    {
        CRules@ rules = getRules();

        CRulesBad@ rulesbad;
        if(!rules.get("NuMenus", @rulesbad))
        {
            error("Failed to get menu. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return @null;
        }
        if(i >= rulesbad.menus.size())
        {
            error("Tried to get menu equal to or above the menu size."); return @null;
        }

        return @rulesbad.menus[i];
    }

    IMenu@ getMenuFromList(string _name)
    {
        array<NuMenu::IMenu@> _menus();
        _menus = getMenusFromList(_name);
        if(_menus.size() > 0)
        {
            return _menus[0];
        }
        else
        {
            return @null;
        }
    }

    array<NuMenu::IMenu@> getMenusFromList(string _name)
    {
        CRules@ rules = getRules();
        
        array<NuMenu::IMenu@> _menus();

        CRulesBad@ rulesbad;
        if(!rules.get("NuMenus", @rulesbad))
        {
            error("Failed to get menu. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return _menus;
        }
        
        return rulesbad.getMenusFromList(_name);
    }

    u16 getMenuListSize()
    {
        CRules@ rules = getRules();

        CRulesBad@ rulesbad;
        if(!rules.get("NuMenus", @rulesbad))
        {
            error("Failed to get menu. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return 0;
        }

        return rulesbad.getMenuListSize();
    }

    void ClearMenuList()
    {
        CRules@ rules = getRules();

        CRulesBad@ rulesbad;
        if(!rules.get("NuMenus", @rulesbad))
        {
            error("Failed to get menu. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return;
        }

        rulesbad.ClearMenuList();
    }











    void onInit(CRules@ rules)
    {
        if(!isClient())
        {
            return;
        }
        GlobalVariables@ globalvars = GlobalVariables();

        rules.set("NuGlobalVars", @globalvars);
    }

    void onTick(CRules@ rules)
    {
        if(!isClient())
        {
            return;
        }

        GlobalVariables@ globalvars;

        if(!rules.get("NuGlobalVars", @globalvars))
        {
            error("NuMenuCommonLogic.as must be before anything else that uses NuMenu in gamemode.cfg"); return;
        }

        globalvars.FRAME_TIME = 0.0f;
    }

    void MenuTick(CRulesBad@ rulesbad)
    {
        if(!isClient())
        {
            return;
        }
        
        u16 i;
        for(i = 0; i < rulesbad.menus.size(); i++)
        {
            if(rulesbad.menus[i] == null)
            {
                continue;
            }
            
            rulesbad.menus[i].Tick();
        
        
            if(rulesbad.menus[i].getMenuState() == NuMenu::Released)
            {
                if(rulesbad.buttons[i] == null)
                {
                    error("Button desync somewhere."); continue;
                }
                if(rulesbad.buttons[i].kill_on_release)
                {                       
                    rulesbad.menus.removeAt(i);
                    rulesbad.buttons.removeAt(i);
                    i--;
                }
            }
        }

    }

    void onRender(CRules@ rules)
    {
        GlobalVariables@ globalvars;

        if(!rules.get("NuGlobalVars", @globalvars))
        {
            error("NuMenuCommonLogic.as must be before anything else that uses NuMenu in gamemode.cfg"); return;
        }

        globalvars.FRAME_TIME += Render::getRenderDeltaTime() * getTicksASecond();
    }

    void MenuRender(CRulesBad@ rulesbad)
    {
        Render::SetAlphaBlend(true);
        
        for(u16 i = 0; i < rulesbad.menus.size(); i++)
        {
            if(rulesbad.menus[i] == null)
            {
                error("Menu was somehow null in rendering. This should not happen."); continue;
            }

            rulesbad.menus[i].Render();
        }
    }


    /*void RulesHUDRenderFunction(int id)
    {
        CBlob@[] players;
        getBlobsByTag("player", @players);
        for (uint i = 0; i < players.length; i++)
        {
            RenderHUDWidgetFor(players[i]);
        }
    }*/
}