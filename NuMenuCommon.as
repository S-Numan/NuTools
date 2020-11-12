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



Optional send command option. Adding it will have it send a command to either everything or just the server upon the button being pressed*/
    
//TODO add params to Tick such as Tick(CControls controls)

    u8 MenuOptionHolder = 100;

    enum MenuOptions
    {
        Blank,
        Button,
        Slider,
        LeftAndRight,
        CheckBox,
    }

    enum ButtonState
    {
        Idle,//Mouse is scared of button. Is not near and has not touched.
        Hover,//Mouse is hovering over the button without doing anything. Mouse has anxiety of what will happen if it touches the button.
        JustPressed,//Mouse just pressed the button.
        Pressed,//Mouse is currently holding down the left mouse button over the button. Good job mouse.
        Released,//Mouse has released while over the button. ( ͡° ͜ʖ ͡°)
        Selected,//Mouse has touched this button first, but is still nervous and is not over the button. Still holding left mouse button though.
        FalseRelease,//Mouse released while not over the button. (when the ButtonState was Selected and the mouse let go)
        Disabled,//The mouse has shown dominance over the button by breaking it's knees with a crowbar
    }

    interface IMenu
    {
        string getName();
        int getNameHash();
        void setName(string value);

        u8 getMenuOption();
        void setMenuOption(u8 value);

        u8 getMenuState();

        bool getRenderBackground();
        void setRenderBackground(bool value);

        bool getInterpolated();
        void setInterpolated(bool value);

        Vec2f getUpperLeftInterpolated();
        Vec2f getUpperLeft();
        void setUpperLeft(Vec2f value);
        void setPosition(Vec2f value);
        Vec2f getLowerRightInterpolated();
        Vec2f getLowerRight();
        void setLowerRight(Vec2f value);
        bool didButtonJustMove();
        Vec2f getMenuSize();
        void setSize(Vec2f value);
        Vec2f getMenuMiddle();

        Vec2f getUpperLeftRelation();
        void setUpperLeftRelation(Vec2f value);
        Vec2f getLowerRightRelation();
        void setLowerRightRelation(Vec2f value);

        void setRelationPos(Vec2f value);
        void setRelationSize();

        bool isPointInMenu(Vec2f value);

        bool Tick();

        void InterpolatePositions();
        
        void Render();

    }

    class MenuBase : IMenu
    {
        MenuBase(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option)
        {
            if(!isClient())
            {
                return;
            }
            
            setMenuOption(_menu_option);

            setUpperLeft(_upper_left);
            setLowerRight(_lower_right);

            setInterpolated(true);

            setName(_name);
        }

        float default_buffer = 4;

        //
        //TODO
        //

        bool isWorldPos = false;//If this is true, this works on worldpos. If this is false, this works like normal gui (on ScreenPos). I.E move with camera or not. TODO

        //
        //TODO
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


        private u8 button_state = Idle;//State of button (being pressed? mouse is hovered over?)
        u8 getMenuState()
        {
            return button_state;
        }

        private bool render_background = true;//If this is true, the menu will draw a background for the menu button by default.
        bool getRenderBackground()
        {
            return render_background;
        }
        void setRenderBackground(bool value)
        {
            render_background = value;
        }

        private bool button_interpolation = true;
        bool getInterpolated()
        {
            return button_interpolation;
        }
        void setInterpolated(bool value)
        {
            if(value)
            {
                upper_left_interpolated = upper_left;
                lower_right_interpolated = lower_right;
                upper_left_old = upper_left;
                lower_right_old = lower_right;
            }
            button_interpolation = value;
        }

        //
        //Options and States
        //


        //
        //Positions
        //

        private Vec2f upper_left_old;
        private Vec2f upper_left_interpolated;

        Vec2f getUpperLeftInterpolated()
        {
            return upper_left_interpolated;
        }

        private Vec2f upper_left;//Upper left of menu
        Vec2f getUpperLeft()
        {
            return upper_left;
        }
        void setUpperLeft(Vec2f value)
        {
            upper_left = value;
            menu_size = Vec2f(lower_right.x - upper_left.x, lower_right.y - upper_left.y);
            menu_middle = upper_left + menu_size / 2;
        }

        //Changes the upper left position and lower right at the same time. No changes to the size of the menu.
        void setPosition(Vec2f value)
        {
            upper_left = value;
            lower_right = upper_left + menu_size;
            menu_middle = upper_left + menu_size / 2;
        }


        private Vec2f lower_right_old;
        private Vec2f lower_right_interpolated;
        Vec2f getLowerRightInterpolated()
        {
            return lower_right_interpolated;
        }

        private Vec2f lower_right;//Lower right of menu
        Vec2f getLowerRight()
        {
            return lower_right;
        }
        void setLowerRight(Vec2f value)
        { 
            lower_right = value;
            menu_size = Vec2f(lower_right.x - upper_left.x, lower_right.y - upper_left.y);
            menu_middle = upper_left + menu_size / 2;
        }

        //Checks if the button just moved. If the old position is not equal to the new position, the button just moved. The button growing counts as moving.
        bool didButtonJustMove()
        {
            return (upper_left_old != upper_left || lower_right_old != lower_right);
        }

        private Vec2f menu_size;//The size of the menu. How far it takes for top_left to get to lower_right.
        Vec2f getMenuSize()
        {
            return menu_size;
        }
        void setSize(Vec2f value)//Changes the length of the lower_right pos to make it the correct size.
        {
            lower_right = upper_left + value;
            menu_size = value;
            menu_middle = upper_left + menu_size / 2;
        }

        private Vec2f menu_middle;//The point on screen the middle of the menu is.
        Vec2f getMenuMiddle()
        {
            return menu_middle;
        }

        ///Relation stuff

        private Vec2f upper_left_relation;//For the inherited classes for less pain.
        Vec2f getUpperLeftRelation()
        {
            return upper_left_relation;
        }
        void setUpperLeftRelation(Vec2f value)
        {
            upper_left_relation = value;
        }
        private Vec2f lower_right_relation;//See above
        Vec2f getLowerRightRelation()
        {
            return lower_right_relation;
        }
        void setLowerRightRelation(Vec2f value)
        {
            lower_right_relation = value;
        }

        void setRelationPos(Vec2f value)
        {
            upper_left_relation = value;
            setRelationSize();
        }

        void setRelationSize()
        {
            lower_right_relation = upper_left_relation + menu_size;
        }

        ///Relation stuff

        //
        //Positions
        //


        //
        //Checks
        //

        bool isPointInMenu(Vec2f value)//Is the vec2f value within the menu?
        {
            if(value.x <= lower_right.x && value.y <= lower_right.y
            && value.x >= upper_left.x && value.y >= upper_left.y)
            {
                return true;//Yes
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

            //Set the interpolated values to the positions.
            upper_left_interpolated = upper_left;
            lower_right_interpolated = lower_right;
            //And make the old be equal to the new.
            upper_left_old = upper_left;
            lower_right_old = lower_right;

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

        //Put in onRender
        void InterpolatePositions()
        {
            if(getInterpolated())
            {
                if(didButtonJustMove())
                {
                    float interpolation_factor = getInterpolationFactor();
                    
                    //print("upper_left = " + upper_left.x);
                    //print("upper_left_old = " + upper_left_old.x);
                    //print("upper_left_interpolated = " + upper_left_interpolated.x);
                    //print("interpolation factor = " + interpolation_factor);

                    upper_left_interpolated = Vec2f_lerp(upper_left_old, upper_left, interpolation_factor);

                    lower_right_interpolated = Vec2f_lerp(lower_right_old, lower_right, interpolation_factor);
                
                    menu_size = lower_right_interpolated - upper_left_interpolated;
                }
            }
            else
            {
                upper_left_interpolated = upper_left;
                lower_right_interpolated = lower_right;
            
                menu_size = lower_right - upper_left;
            }
        }

        //
        //Interpolation
        //


        //
        //Rendering
        //
        
        void Render()//Overwrite this method if you want a different look.
        {
            InterpolatePositions();//Don't forget this if you do this ^

            if(render_background)
            {
                SColor rec_color;
                switch(button_state)
                {
                    case Idle:
                        rec_color = SColor(255, 200, 200, 200);
                        break;
                    case Hover:
                        rec_color = SColor(255, 70, 50, 0);
                        break;
                    case Selected:
                        rec_color = SColor(255, 30, 50, 0);
                        break;
                    case FalseRelease:
                        rec_color = SColor(255, 30, 50, 255);
                        break;
                    case Pressed:
                        rec_color = SColor(255, 255, 0, 0);
                        break;
                    case Released:
                        rec_color = SColor(255, 0, 255, 0);
                        break;
                    case Disabled:
                        rec_color = SColor(255, 5, 5, 5);
                        break;
                    default:
                        rec_color = SColor(255, 255, 255, 255);
                        break;
                }

                GUI::DrawRectangle(upper_left_interpolated, lower_right_interpolated, rec_color);
            }
        }

        //
        //Rendering
        //
    }
    
    class MenuBasePlus : MenuBase
    {
        MenuBasePlus(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option)
        {
            if(!isClient())
            {
                return;
            }

            super(_upper_left, _lower_right, _name, _menu_option);
            
            setTextColor(SColor(255, 0, 0, 0));

            setFont("menu");
        }

        //
        //Text stuff
        //

        //Text settings
        //

        private string font;//Font used.
        string getFont()
        {
            return font;
        }
        void setFont(string value)
        {
            font = value;
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

        //Middle
        private string middle_text;
        string getMiddleText()
        {
            return middle_text;
        }
        void setMiddleText(string value)
        {
            GUI::SetFont(font);
            Vec2f middle_text_dimensions;
            GUI::GetTextDimensions(value, middle_text_dimensions);
            
            middle_text_pos = Vec2f(menu_size.x/2 - middle_text_dimensions.x/2, menu_size.y/2 - middle_text_dimensions.y/2);
            
            middle_text = value;
        }
        
        private Vec2f middle_text_pos;
        Vec2f getMiddleTextPos()
        {
            return middle_text_pos;
        }
        void setMiddleTextPos(Vec2f value)
        {
            middle_text_pos = value;
        }
        //Middle

        //Left
        private string left_text;//Text starting on the left of the menu (usually)
        string getLeftText()
        {
            return left_text;
        }
        
        void setLeftText(string value)
        {
            GUI::SetFont(font);
            Vec2f left_text_dimensions;
            GUI::GetTextDimensions(value, left_text_dimensions);
            
            left_text_pos = Vec2f(default_buffer, menu_size.y/2 - left_text_dimensions.y/2);
            
            left_text = value;
        }

        private Vec2f left_text_pos;
        Vec2f getLeftTextPos()
        {
            return left_text_pos;
        }
        void setLeftTextPos(Vec2f value)
        {
            left_text_pos = value;
        }
        //Left
    
        //Right
        private string right_text;//Text starting on the right of the menu (usually)
        string getRightText()
        {
            return right_text;
        }
        
        void setRightText(string value)
        {
            GUI::SetFont(font);
            Vec2f right_text_dimensions;
            GUI::GetTextDimensions(value, right_text_dimensions);
            
            right_text_pos = Vec2f(menu_size.x - right_text_dimensions.x - default_buffer, menu_size.y/2 - right_text_dimensions.y/2);
            
            right_text = value;
        }

        private Vec2f right_text_pos;
        Vec2f getRightTextPos()
        {
            return right_text_pos;
        }
        void setRightTextPos(Vec2f value)
        {
            right_text_pos = value;
        }
        //Right

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
                titlebar_size.x = menu_size.x;
            }
        }
        bool titlebar_width_is_menu = true;//When this is true the titlebar width will move with the menu
        void setTitlebarWidth(float value)
        {
            titlebar_size.x = value;
            titlebar_width_is_menu = false;
        }

        private Vec2f titlebar_press_pos;//Do not edit, this is for the moving menu part of the code.

        bool titlebar_ignore_press = false;//When this is true the titlebar cannot move the menu.

        bool titlebar_draw = true;//If this is false the titlebar will not be drawn (but will still function)

        bool isPointInTitlebar(Vec2f value)//Is the vec2f value within the titlebar?
        {
            if(value.x <= lower_right.x - (menu_size.x - titlebar_size.x)&& value.y <= upper_left.y + titlebar_size.y
            && value.x >= upper_left.x && value.y >= upper_left.y)
            {
                return true;//Yes
            }
            return false;//No
        }

        //
        //Titlebar
        //


        //
        //Logic
        //

        bool initial_press = false;

        u8 getPressingState(Vec2f point, u8 _button_state, bool left_button, bool left_button_release, bool left_button_just)
        {
            if(isPointInMenu(point))//Is the mouse within the menu?
            {
                if(initial_press)//If the button was initially pressed.
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
                    initial_press = true;//This button was initially pressed.
                    _button_state = JustPressed;//It was also just pressed.
                }//Only buttons with "initial_press" equal to true will have their button logic working.
                
                else if(!left_button)//If the button was not initially pressed and left mouse button is not being held
                {
                    _button_state = Hover;//Button is being hovered over
                }
            }
            else//Not in menu
            {
                if(initial_press == true)//If this mouse was initailly pressed.
                {
                    if(!left_button)//If the left button is no longer being pressed.
                    {
                        _button_state = FalseRelease;//Mouse was released while not over the button.

                        initial_press = false;//This button is no longer initially pressed.
                    }
                    else if(button_state != Selected)//If the mouse is not selected
                    {
                        _button_state = Selected;//Select it.
                    }
                }
                else if(button_state != Idle)//If the mouse button was not initially pressed and is not idle.
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

            CControls@ controls = getLocalPlayer().getControls();//This can be done safely as the code to check if client&player&controls is null/false was done in the inherited class.

            Vec2f mouse_pos = controls.getMouseScreenPos();
            bool left_button = controls.mousePressed1;
            bool left_button_release = controls.isKeyJustReleased(KEY_LBUTTON);
            bool left_button_just = controls.isKeyJustPressed(KEY_LBUTTON);
            //bool right_button = controls.mousePressed2;
            //bool right_button_release = controls.isKeyJustReleased(KEY_RBUTTON);
            //bool scroll_up = controls.mouseScrollUp;
            //bool scroll_down = controls.mouseScrollDown;

            if(titlebar_width_is_menu)
            {
                titlebar_size.x = menu_size.x;
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
                        setPosition(upper_left - (titlebar_press_pos - mouse_pos));
                        titlebar_press_pos = mouse_pos;
                    }
                }

                if(!left_button && titlebar_press_pos != Vec2f_zero)
                {
                    titlebar_press_pos = Vec2f_zero;
                }
            }

            return true;//Everything worked out correctly.
        }

        //
        //Logic
        //


        //
        //Image stuff
        //

        string image_name;//File name of image.
        Vec2f image_frame_size;//The frame size of the image. (for choosing different frames);
        u16 image_frame;//Frame of image in file.
        u16 image_frame_press;//Frame image changes to on press.
        Vec2f image_pos;//Position of image in relation to the menu.

        void setImage(string _image_name, u16 _image_frame, u16 _image_frame_press, Vec2f _image_frame_size, Vec2f _image_pos)
        {
            image_name = _image_name;
            image_frame = _image_frame;
            image_frame_press = _image_frame_press;
            image_frame_size = _image_frame_size;
            image_pos = _image_pos;
        }

        //
        //Image stuff
        //


        //
        //Rendering
        //
        
        void Render() override
        {
            MenuBase::Render();

            //Titlebar
            //
            if(titlebar_draw && titlebar_size.y != 0.0f)
            {
                if(titlebar_width_is_menu)
                {
                    titlebar_size.x = menu_size.x;
                }

                GUI::DrawRectangle(upper_left_interpolated,//Upper left to
                upper_left_interpolated +//Upper left plus 
                titlebar_size);//Titlebar size
            }
            //
            //Titlebar

            //Text Stuff
            //
            GUI::SetFont(font);

            if(middle_text.size() != 0)
            {
                GUI::DrawText(middle_text, upper_left_interpolated + middle_text_pos,
                text_color);
            }
            
            if(left_text.size() != 0)
            {
                GUI::DrawText(left_text, upper_left_interpolated + left_text_pos,
                text_color);//Left text
            }

            if(right_text.size() != 0)
            {
                GUI::DrawText(right_text, upper_left_interpolated + right_text_pos,
                text_color);//Right text
            }
            //
            //Text stuff

        }

        void RenderImage()
        {
            if(image_name != "")
            {
                GUI::DrawIcon(image_name, button_state == Pressed ? image_frame_press : image_frame, image_frame_size, upper_left_interpolated + image_pos, 0.5f);
            }
        }

        //
        //Rendering
        //
    }


    class MenuButton : MenuBasePlus
    {
        MenuButton(Vec2f _upper_left, Vec2f _lower_right, string _name)
        {
            if(!isClient())
            {
                return;
            }

            super(_upper_left, _lower_right, _name, Button);
        }

        bool Tick() override
        {
            if(!MenuBasePlus::Tick())
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

            return true;
        }

        void Render() override
        {
            MenuBasePlus::Render();
        }
    }

    class MenuCheckBox : MenuBasePlus
    {
        MenuCheckBox(Vec2f _upper_left, Vec2f _lower_right, string _name)
        {
            if(!isClient())
            {
                return;
            }

            super(_upper_left, _lower_right, _name, CheckBox);
        }

        bool menu_checked = false;

        bool Tick() override
        {
            if(!MenuBasePlus::Tick())
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

        void Render() override
        {
            //Temp
            //MenuBasePlus::Render();

            InterpolatePositions();

            if(menu_checked == true)
            {
                GUI::DrawRectangle(upper_left_interpolated, lower_right_interpolated, SColor(255, 255, 0, 0));
            }
            else
            {
                GUI::DrawRectangle(upper_left_interpolated, lower_right_interpolated, SColor(255, 0, 255, 0));
            }
        }
    }










    class MenuHolder : MenuBasePlus
    {
        MenuHolder(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option)
        {
            if(!isClient())
            {
                return;
            }
            super(_upper_left, _lower_right, _name, _menu_option);

            setMenuOption(MenuOptionHolder + _menu_option);

            addMenuOption(_menu_option);
        }


        //
        //Overrides
        //

        void setUpperLeft(Vec2f value) override
        {
            MenuBasePlus::setUpperLeft(value);
            moveMenuAttachments();
        }

        //Changes the upper left position and lower right at the same time. No changes to the size of the menu.
        void setPosition(Vec2f value) override
        {
            MenuBasePlus::setPosition(value);
            moveMenuAttachments();
        }

        void setLowerRight(Vec2f value) override
        { 
            MenuBasePlus::setLowerRight(value);
            moveMenuAttachments();
        }

        void setSize(Vec2f value) override//Changes the length of the lower_right pos to make it the correct size.
        {
            MenuBasePlus::setSize(value);
            moveMenuAttachments();
        }
        
        //
        //Overries
        //


        //
        //Optional Menus
        //

        private IMenu@[] optional_menus;

        Vec2f getMenuOptionalPos(u16 option_menu = 0)//In relation to this menu
        {
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != null)
            {
                return optional_menus[option_menu].getUpperLeftRelation();
            }
            return Vec2f_zero;
        }
        bool setMenuOptionalPos(Vec2f value, u16 option_menu = 0)//Sets it in relation to this menu
        {
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != null)
            {
                IMenu@ _menu = @optional_menus[option_menu];
                _menu.setRelationPos(value);
                return true;
            }
            
            return false;
        }

        u8 getOptionalState(u16 option_menu = 0)//Param refers to specific menu in array
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

        IMenu@ addMenuOption(u8 value, Vec2f optional_menu_size = Vec2f(32, 32))
        {
            switch(value)
            {
                case Button:
                {
                    MenuButton@ _menu = MenuButton(Vec2f(0,0),
                        Vec2f(0,0),
                        getName() + "_but_" + optional_menus.size());

                    _menu.setSize(optional_menu_size);
                    _menu.setInterpolated(false);//Done manually

                    _menu.setRelationPos(Vec2f(menu_size.x - optional_menu_size.x - default_buffer, menu_size.y/2 - optional_menu_size.y/2));

                    optional_menus.push_back(@_menu);
                    break;
                }
                case CheckBox:
                {
                    MenuCheckBox@ _menu = MenuCheckBox(Vec2f(0,0),
                        Vec2f(0,0),
                        getName() + "_chk_" + optional_menus.size());

                    _menu.setSize(optional_menu_size);
                    _menu.setInterpolated(false);//Done manually

                    _menu.setRelationPos(Vec2f(menu_size.x - optional_menu_size.x - default_buffer, menu_size.y/2 - optional_menu_size.y/2));

                    optional_menus.push_back(@_menu);
                    break;
                }
                default:
                    break;
            }

            moveMenuAttachments();


            if(optional_menus.size() != 0 && optional_menus[optional_menus.size() - 1] != null)
            {
                return @optional_menus[optional_menus.size() - 1];
            }
            
            return @null;
        }

        //Using this will move the menu attachments (optional_menus) with the menu holding it to where it should go. (using upper_left of this menu, and upper_left_relation of the optional menu)
        void moveMenuAttachments(bool useInterpolatedValue = false)//When this is true it uses the interpolated values. This only matters in Render functions.
        {
            for(u16 i = 0; i < optional_menus.size(); i++)
            {
                if(optional_menus[i] == null)//Should never happen, but check anyway to have less pain in case it does.
                {
                    error("Menu was equal to null."); continue;
                }

                //switch(optional_menus[i].getMenuOption())
                //{
                    //case CheckBox:
                optional_menus[i].setPosition((useInterpolatedValue ? upper_left_interpolated : upper_left) + optional_menus[i].getUpperLeftRelation());
                        //break;
                    //default:
                        //break;
                //}
            }
        }

        //
        //Optional Menus
        //


        bool Tick() override
        {
            if(!MenuBasePlus::Tick())
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
            return true;
        }

        void Render() override
        {
            MenuBasePlus::Render();

            /*if(!GUI::isFontLoaded(font))
            {
                error("Font " + font + " is not loaded.");
                return;
            }*/

            RenderImage();

            if(getInterpolated())//If this menu is interpolated.
            {
                if(didButtonJustMove())
                {
                    moveMenuAttachments(true);
                }
            }

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

        }
    }


    /*class ListMenu
    {
        bool is_horizontal = false;
        
        float buffer_size;//Space between two buttons
    
        array<Menu> buttons();
    
        void onTick( CRules@ this )
        {

        }

        void onRender( CRules@ this )
        {

        }
    }*/


    void onTick( CRules@ this )
    {

    }

    void onRender( CRules@ this )
    {

    }

}