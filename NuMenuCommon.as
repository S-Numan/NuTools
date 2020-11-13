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
    
//TODO add params to Tick? such as Tick(CControls controls)
//TODO fix text/font size changing

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

        IMenu@ getOwnerMenu();
        bool setOwnerMenu(IMenu@ _menu);
        bool getMoveToOwner();
        void setMoveToOwner(bool value);

        u8 getMenuOption();
        void setMenuOption(u8 value);

        u8 getMenuState();

        bool isWorldPos();
        void setIsWorldPos(bool value);

        bool getRenderBackground();
        void setRenderBackground(bool value);

        bool isInterpolated();
        void setInterpolated(bool value);

        Vec2f getUpperLeftInterpolated();
        Vec2f getUpperLeft(bool get_raw_pos = false);
        void setUpperLeft(Vec2f value);
        Vec2f getPos(bool get_raw_pos = false);
        void setPos(Vec2f value);
        Vec2f getLowerRightInterpolated();
        Vec2f getLowerRight(bool get_raw_pos = false);
        void setLowerRight(Vec2f value);
        bool didMenuJustMove();
        Vec2f getSize();
        void setSize(Vec2f value);

        Vec2f getRelationPos();
        void setRelationPos(Vec2f value);

        bool isPointInMenu(Vec2f value);

        bool Tick();

        void InterpolatePositions();
        
        void Render();

    }

    //Base of all menus.
    class MenuBase : IMenu
    {
        MenuBase(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option)// add default option for world pos/screen pos? - Todo numan
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
        //World
        //

        private bool is_world_pos = false;//If this is true, this works on worldpos. If this is false, this works like normal gui (on ScreenPos). I.E move with camera or not. TODO

        bool isWorldPos()
        {
            return is_world_pos;
        }

        void setIsWorldPos(bool value)
        {
            is_world_pos = value;
            setUpperLeft(upper_left);
            setLowerRight(lower_right);
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
        //Owner Menu
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

            @owner_menu = @_menu;
            return true;
        }

        bool move_to_owner = true;//If this is true, this menu will move itself to the position of it's owner with relation added to it. 
        bool getMoveToOwner()
        {
            return move_to_owner;
        }
        void setMoveToOwner(bool value)
        {
            move_to_owner = value;
        }
        

        //
        //Owner menu
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
        bool isInterpolated()
        {
            return button_interpolation;
        }
        void setInterpolated(bool value)
        {
            if(value)
            {
                upper_left_interpolated = getUpperLeft();
                lower_right_interpolated = getLowerRight();
                upper_left_old = getUpperLeft(true);
                lower_right_old = getLowerRight(true);
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

        private Vec2f upper_left;//Upper left of menu
        Vec2f getUpperLeft(bool get_raw_pos = false)//If this bool is true; even if isWorldPos() is true, it will get the raw position. I.E in most cases the actual world position. not the world to screen pos. does nothing if isWorldPos is false.
        {
            if(isWorldPos() && !get_raw_pos)
            {
                //CCamera@ camera = getCamera();
                Driver@ driver = getDriver();//This might be slow. - Todo numan
                return driver.getScreenPosFromWorldPos(upper_left);
            }
            
            return upper_left;
        }
        void setUpperLeft(Vec2f value)
        {
            upper_left = value;
            menu_size = Vec2f(lower_right.x - upper_left.x, lower_right.y - upper_left.y);
        }

        //Changes the upper left position and lower right at the same time. No changes to the size of the menu.
        void setPos(Vec2f value)
        {
            upper_left = value;
            lower_right = upper_left + menu_size;
        }
        Vec2f getPos(bool get_raw_pos = false)
        {
            return getUpperLeft(get_raw_pos);
        }

        private Vec2f lower_right;//Lower right of menu
        Vec2f getLowerRight(bool get_raw_pos = false)//If this bool is true; even if isWorldPos() is true, it will get the raw position. I.E in most cases the actual world position. not the world to screen pos. does nothing if isWorldPos is false.
        {
            if(isWorldPos() && !get_raw_pos)
            {
                Driver@ driver = getDriver();
                return driver.getScreenPosFromWorldPos(lower_right);
            }

            return lower_right;
        }
        void setLowerRight(Vec2f value)
        { 
            lower_right = value;
            menu_size = Vec2f(lower_right.x - upper_left.x, lower_right.y - upper_left.y);
        }

        

        private Vec2f menu_size;//The size of the menu. How far it takes for top_left to get to lower_right.
        Vec2f getSize()
        {
            return menu_size;
        }
        void setSize(Vec2f value)//Changes the length of the lower_right pos to make it the correct size.
        {
            setLowerRight(upper_left + value);
        }

        //
        //Normal Positions


        //Old Positions
        //

        private Vec2f upper_left_old;
        Vec2f getUpperLeftOld(bool get_raw_pos = false)
        {
            if(isWorldPos() && !get_raw_pos)
            {
                Driver@ driver = getDriver();
                return driver.getScreenPosFromWorldPos(upper_left_old);
            }
            
            return upper_left_old;
        }
        private Vec2f lower_right_old;
        Vec2f getLowerRightOld(bool get_raw_pos = false)
        {
            if(isWorldPos() && !get_raw_pos)
            {
                Driver@ driver = getDriver();
                return driver.getScreenPosFromWorldPos(lower_right_old);
            }
            
            return lower_right_old;
        }

        //Checks if the button just moved. If the old position is not equal to the new position, the button just moved. The button growing counts as moving.
        bool didMenuJustMove()
        {
            return (upper_left_old != upper_left || lower_right_old != lower_right);
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
        }

        //
        //Relation positions

        //
        //Positions
        //


        //
        //Checks
        //

        bool isPointInMenu(Vec2f value)//Is the vec2f value within the menu?
        {
            if(value.x <= getLowerRight().x && value.y <= getLowerRight().y
            && value.x >= getUpperLeft().x && value.y >= getUpperLeft().y)
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
            upper_left_interpolated = getUpperLeft();
            lower_right_interpolated = getLowerRight();
            //And make the old be equal to the new.
            upper_left_old = getUpperLeft(true);
            lower_right_old = getLowerRight(true);

            

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
        private Vec2f upper_left_interpolated;

        Vec2f getUpperLeftInterpolated()
        {
            return upper_left_interpolated;
        }

        private Vec2f lower_right_interpolated;
        Vec2f getLowerRightInterpolated()
        {
            return lower_right_interpolated;
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
                    float interpolation_factor = getInterpolationFactor();
                    
                    //print("upper_left = " + getUpperLeft().x);
                    //print("upper_left_old = " + getUpperLeftOld().x);
                    //print("upper_left_interpolated = " + upper_left_interpolated.x);
                    //print("interpolation factor = " + interpolation_factor);

                    upper_left_interpolated = Vec2f_lerp(getUpperLeftOld(), getUpperLeft(), interpolation_factor);

                    lower_right_interpolated = Vec2f_lerp(getLowerRightOld(), getLowerRight(), interpolation_factor);
                
                    //menu_size = lower_right_interpolated - upper_left_interpolated;
                }
                else if(isWorldPos())//Basically if the camera moved. Move the menu too.
                {
                    upper_left_interpolated = getUpperLeft();
                    lower_right_interpolated = getLowerRight();
                }
            }
            else
            {
                upper_left_interpolated = getUpperLeft();
                lower_right_interpolated = getLowerRight();
            
                //menu_size = lower_right_interpolated - upper_left_interpolated;
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
            InterpolatePositions();//Don't forget this if you want interpolation.

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
                
                GUI::DrawRectangle(upper_left_interpolated, lower_right_interpolated, rec_color);
            }
        }

        //
        //Rendering
        //
    }
    
    //Base of all menus + more stuff. Stuff includes text, a titlebar (can be hidden and simply used for dragging the menu.) And a method that allows you to check if this was pressed and the states it can be in. Allows a single icon as well
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

            setFont("AveriaSerif-Bold.ttf", 8);
        }

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
            
            if (!GUI::isFontLoaded(font + "_" + (size / 2)))
            {
                GUI::LoadFont(font + "_" + (size / 2), fontfile, size / 2, true);
            }
            else if (!GUI::isFontLoaded(font))
            {
                GUI::LoadFont(font, fontfile, size, true);
            }
            else if (!GUI::isFontLoaded(font + "_" + (size * 2)))
            {
                GUI::LoadFont(font + "_" + (size * 2), fontfile, size * 2, true);
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
            
            middle_text_pos = Vec2f(getSize().x/2 - middle_text_dimensions.x/2, getSize().y/2 - middle_text_dimensions.y/2);
            
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
            
            left_text_pos = Vec2f(default_buffer, getSize().y/2 - left_text_dimensions.y/2);
            
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
            
            right_text_pos = Vec2f(getSize().x - right_text_dimensions.x - default_buffer, getSize().y/2 - right_text_dimensions.y/2);
            
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
        

        bool titlebar_ignore_press = false;//When this is true the titlebar cannot move the menu.

        bool titlebar_draw = true;//If this is false the titlebar will not be drawn (but will still function)

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
                if(initial_press)//If this mouse was initailly pressed.
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
            //bool right_button = controls.mousePressed2;
            //bool right_button_release = controls.isKeyJustReleased(KEY_RBUTTON);
            //bool scroll_up = controls.mouseScrollUp;
            //bool scroll_down = controls.mouseScrollDown;

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
                        //MenuBasePlus required to not accidently use the one in MenuHolder which moves their children menu's before the tick methods.
                        MenuBasePlus::setPos(getUpperLeft(true) - //Current menu position subtracted by
                         (titlebar_press_pos - mouse_pos));//The positioned the titlebar was pressed minus the current mouse position. (The difference.)
                        titlebar_press_pos = mouse_pos;
                    }
                }

                else if(titlebar_press_pos != Vec2f_zero)
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

            CCamera@ camera;
            if(isWorldPos())
            {
                @camera = @getCamera();
            }

            //Titlebar
            //
            
            if(titlebar_draw && titlebar_size.y != 0.0f)
            {
                if(titlebar_width_is_menu)
                {
                    Vec2f interpolated_size = getLowerRightInterpolated() - getUpperLeftInterpolated();
                    if(titlebar_size.x != interpolated_size.x)
                    {
                        titlebar_size.x = interpolated_size.x;
                    }
                }


                Vec2f _upperleft = upper_left_interpolated;//Upper left
                
                Vec2f _lowerright = (upper_left_interpolated + Vec2f(titlebar_size.x, +//Upper left plus titlebar_size.x +
                titlebar_size.y * (isWorldPos() ? camera.targetDistance * 2 : 1))); //titlebar_size.y multiplied by the camera distance if isWorldPos() is true.

                GUI::DrawRectangle(_upperleft, _lowerright);
            }
            //
            //Titlebar

            RenderImage(camera);

            //Text Stuff
            //

            if(middle_text.size() != 0 || left_text.size() != 0 || right_text.size() != 0)//If text exists
            {
                if(isWorldPos())
                {
                    if(camera.targetDistance < 0.9)
                    {
                        GUI::SetFont(font + "_" + (getFontSize() / 2));
                    }
                    else if(camera.targetDistance > 0.9 && camera.targetDistance < 1.1)
                    {
                        GUI::SetFont(font);
                    }
                    else//Camera targetDistance more than 1.1
                    {
                        GUI::SetFont(font + "_" + (getFontSize() * 2));
                    }
                }
                else
                {
                    GUI::SetFont(font);
                }

                if(middle_text.size() != 0)
                {
                    GUI::DrawText(middle_text, upper_left_interpolated + middle_text_pos * (isWorldPos() ? camera.targetDistance : 1),
                    text_color);
                }
                
                if(left_text.size() != 0)
                {
                    GUI::DrawText(left_text, upper_left_interpolated + left_text_pos * (isWorldPos() ? camera.targetDistance : 1),
                    text_color);//Left text
                }

                if(right_text.size() != 0)
                {
                    GUI::DrawText(right_text, upper_left_interpolated + right_text_pos * (isWorldPos() ? camera.targetDistance : 1),
                    text_color);//Right text
                }
            }
            //
            //Text stuff

        }

        void RenderImage(CCamera@ camera)
        {
            if(image_name != "")
            {
                GUI::DrawIcon(image_name, button_state == Pressed ? image_frame_press : image_frame, image_frame_size, upper_left_interpolated + image_pos, isWorldPos() ? camera.targetDistance : 0.5);
            }
        }

        //
        //Rendering
        //
    }

    //Menu set up to function like a button.
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

    //Menu setup to function like an check box. Click once and it's state changes.
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
                GUI::DrawRectangle(upper_left_interpolated, lower_right_interpolated, SColor(255, 25,127,25));
            }
            else
            {
                GUI::DrawRectangle(upper_left_interpolated, lower_right_interpolated, SColor(255, 127,25,25));
            }
        }
    }









    //This menu is designed to hold other menu's and keep them attached to it.
    class MenuHolder : MenuBasePlus
    {
        MenuHolder(Vec2f _upper_left, Vec2f _lower_right, string _name)
        {
            if(!isClient())
            {
                return;
            }
            super(_upper_left, _lower_right, _name, MenuOptionHolder);
        }


        //
        //Overrides
        //

        void setUpperLeft(Vec2f value) override
        {
            MenuBasePlus::setUpperLeft(value);
            moveHeldMenus();
        }

        void setPos(Vec2f value)
        {
            MenuBasePlus::setPos(value);
            moveHeldMenus();
        }
        void setLowerRight(Vec2f value) override
        { 
            MenuBasePlus::setLowerRight(value);
            moveHeldMenus();
        }

        void setSize(Vec2f value) override
        {
            MenuBasePlus::setSize(value);
            moveHeldMenus();
        }
        
        void setInterpolated(bool value) override
        {
            MenuBasePlus::setInterpolated(value);
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
            MenuBasePlus::setIsWorldPos(value);
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

        Vec2f getOptionalMenuPos(u16 option_menu = 0)//In relation to this menu
        {
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != null)
            {
                return optional_menus[option_menu].getRelationPos();
            }
            return Vec2f_zero;
        }
        bool setOptionalMenuPos(Vec2f value, u16 option_menu = 0)//Sets it in relation to this menu
        {
            if(optional_menus.size() > option_menu && optional_menus[option_menu] != null)
            {
                IMenu@ _menu = @optional_menus[option_menu];
                _menu.setRelationPos(value);
                return true;
            }
            
            return false;
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
                    MenuButton@ _menu = MenuButton(Vec2f(0,0),
                        Vec2f(0,0),
                        _name + "_but");


                    optional_menus.push_back(@_menu);
                    break;
                }
                case CheckBox:
                {
                    MenuCheckBox@ _menu = MenuCheckBox(Vec2f(0,0),
                        Vec2f(0,0),
                        _name + "_chk");


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
            if(titlebar_press_pos != Vec2f_zero)
            {
                moveHeldMenus();
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