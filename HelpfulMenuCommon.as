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
        Pressed,//Mouse is currently holding down the left mouse button over the button. Good job mouse.
        Released,//Mouse has released while over the button. ( ͡° ͜ʖ ͡°)
        Selected,//Mouse has touched this button first, but is still nervous and is not over the button. Still holding left mouse button though.
        FalseRelease,//Mouse released while not over the button. (when the ButtonState was Selected and the mouse let go)
        Disabled,//The mouse has shown dominance over the button by breaking it's knees with a crowbar
    }
    
    class Menu
    {
        Menu(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option)
        {
            if(!isClient())
            {
                return;
            }
            
            setMenuOption(_menu_option);

            setUpperLeft(_upper_left);
            setLowerRight(_lower_right);

            setInterpolation(true);


            setName(_name);


            setTextColor(SColor(255, 0, 0, 0));

            setFont("menu");
        }

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
        u8 getButtonState()
        {
            return button_state;
        }

        bool initial_press = false;

        bool render_background = true;


        private bool button_interpolation = true;
        bool getInterpolation()
        {
            return button_interpolation;
        }
        void setInterpolation(bool value)
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


        bool isPointInMenu(Vec2f value)//Is the vec2f value within the menu?
        {
            if(value.x <= lower_right.x && value.y <= lower_right.y
            && value.x >= upper_left.x && value.y >= upper_left.y)
            {
                return true;//Yes
            }
            return false;//No
        }

        //Always change positions AFTER this method.
        bool Tick()
        {
            if(!isClient())//This is for clients only.
            {
                error("Menu class Tick method was ran on server. This shouldn't happen.");
                return false;//Inform anything that uses this method that something went wrong.
            }

            CPlayer@ player = getLocalPlayer();
            if(player == null)//The player must exist to get the CControls. (and maybe some other stuff)
            {
                return false;
            }

            //Set the interpolated values to the positions.
            upper_left_interpolated = upper_left;
            lower_right_interpolated = lower_right;
            //And make the old be equal to the new.
            upper_left_old = upper_left;
            lower_right_old = lower_right;

            CControls@ controls = player.getControls();
            if(controls == null)//The controls must exist
            {
                return false;
            }

            if(getMenuOption() != Button)//If this Menu is not a button.
            {
                return true;//This is okay, return true and just don't do any logic for buttons.
            }

            Vec2f mouse_pos = controls.getMouseScreenPos();//Position of mouse on screen.
            bool left_button = controls.mousePressed1;//Pressing
            bool left_button_release = controls.isKeyJustReleased(KEY_LBUTTON);//Just released
            bool left_button_just = controls.isKeyJustPressed(KEY_LBUTTON);//Just pressed

            if(isPointInMenu(mouse_pos))//Is the mouse within the menu?
            {
                if(left_button_just)//Mouse button just pressed?
                {
                    initial_press = true;//This button was initially pressed
                }//Only buttons with "initial_press" equal to true will have their button logic working.

                if(initial_press)//If the button was initially pressed.
                {
                    if(left_button)//Left button held?
                    {
                        button_state = Pressed;//Button is pressed
                    }
                    else if(left_button_release)//Left button released?
                    {
                        button_state = Released;//Button was released on.
                        initial_press = false;//No longer pressed.
                    }
                }
                else if(!left_button)//If the button was not initially pressed and left mouse button is not being held
                {
                    button_state = Hover;//Button is being hovered over
                }
            }
            else//Not in menu
            {
                if(initial_press == true)//If this mouse was initailly pressed.
                {
                    if(!left_button)//If the left button is no longer being pressed.
                    {
                        button_state = FalseRelease;//Mouse was released while not over the button.

                        initial_press = false;//This button is no longer initially pressed.
                    }
                    else if(button_state != Selected)//If the mouse is not selected
                    {
                        button_state = Selected;//Select it.
                    }
                }
                else if(button_state != Idle)//If the mouse button was not initially pressed and is not idle.
                {
                    button_state = Idle;//Make the mouse button idle.
                }
            }

            return true;//Everything worked out correctly.
        }

        //Put in onRender
        void InterpolatePositions()
        {
            if(button_interpolation)
            {
                if(upper_left_old != upper_left || lower_right_old != lower_right)
                {
                    float interpolation_factor = getInterpolationFactor();
                    
                    //print("upper_left = " + upper_left.x);
                    //print("upper_left_old = " + upper_left_old.x);
                    //print("upper_left_interpolated = " + upper_left_interpolated.x);
                    //print("interpolation factor = " + interpolation_factor);

                    upper_left_interpolated = Vec2f_lerp(upper_left_old, upper_left, interpolation_factor);

                    lower_right_interpolated = Vec2f_lerp(lower_right_old, lower_right, interpolation_factor);
                }
            }
            else
            {
                upper_left_interpolated = upper_left;
                lower_right_interpolated = lower_right;
            }
        }
        
        void Render()//Overwrite this method if you want a different look.
        {
            InterpolatePositions();

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

            GUI::SetFont(font);

            if(middle_text.size() != 0)
            {
                GUI::DrawText(middle_text, upper_left_interpolated + middle_text_pos,
                    text_color);
            }
        }
    }

    class FancyMenu : Menu
    {
        FancyMenu(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option)
        {
            if(!isClient())
            {
                return;
            }
            super(_upper_left, _lower_right, _name, _menu_option);
        
            optional_menu_size = Vec2f(32, 32);

            setMenuOption(_menu_option);
        }

        string image_name;//File name of image.
        Vec2f image_frame_size;//The frame size of the image. (for choosing different frames);
        u16 image_frame;//Frame of image in file.
        u16 image_frame_press;//Frame image changes to on press.
        Vec2f image_pos;//Position of image in relation to the menu.

        float default_buffer = 4;

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


        void setImage(string _image_name, u16 _image_frame, u16 _image_frame_press, Vec2f _image_frame_size, Vec2f _image_pos)
        {
            image_name = _image_name;
            image_frame = _image_frame;
            image_frame_press = _image_frame_press;
            image_frame_size = _image_frame_size;
            image_pos = _image_pos;
        }

        //Overrides

        void setUpperLeft(Vec2f value) override
        {
            Menu::setUpperLeft(value);
            moveMenuOption();
        }

        //Changes the upper left position and lower right at the same time. No changes to the size of the menu.
        void setPosition(Vec2f value) override
        {
            Menu::setPosition(value);
            moveMenuOption();
        }

        void setLowerRight(Vec2f value) override
        { 
            Menu::setLowerRight(value);
            moveMenuOption();
        }

        void setSize(Vec2f value) override//Changes the length of the lower_right pos to make it the correct size.
        {
            Menu::setSize(value);
            moveMenuOption();
        }

        //Overries



        private Vec2f optional_menu_pos;//In relation to the menu
        Vec2f getMenuOptionPos()
        {
            return optional_menu_pos;
        }
        void setMenuOptionPos(Vec2f value)//Sets it in relation to the menu
        {
            optional_menu_pos = value;
        }



        Vec2f optional_menu_size;
        private Menu@ optional_menu;

        Menu@ getOptionalMenu()
        {
            return optional_menu;
        }

        void setMenuOption(u8 value) override
        {
            Menu::setMenuOption(value);

            switch(value)
            {
                case CheckBox:
                    print("menusize" + optional_menu_size.x);
                    optional_menu_pos = Vec2f(menu_size.x - optional_menu_size.x - default_buffer, menu_size.y/2 - optional_menu_size.y/2);
                
                    @optional_menu = @Menu(Vec2f(0,0),//Did this in moveMenuOption()
                        Vec2f(0,0),//Really don't feel like doing this manually. Did it in the setSize() thing below.
                        getName() + "_chk",
                        Button);
                    optional_menu.setSize(optional_menu_size);
                    optional_menu.setInterpolation(false);//Done manually

                    moveMenuOption();
                    break;
                default:
                    @optional_menu = @null;
                    break;
            }


            if(optional_menu != null)
            {

            }




        }

        void moveMenuOption()//Using this will move the option menu with the menu holding it to where it should go. (using the upper_left, and optional_menu_pos)
        {
            switch(getMenuOption())
            {
                case CheckBox:
                    if(optional_menu != null)
                    {
                        optional_menu.setPosition(upper_left + optional_menu_pos);
                    }
                    break;
                default:
                    break;
            }
        }

        bool Tick() override
        {
            if(!Menu::Tick())
            {
                return false;
            }

            if(optional_menu != null)
            {
                optional_menu.Tick();
            }

            CControls@ controls = getLocalPlayer().getControls();//This can be done safely as the code to check if client&player&controls is null/false was done in the inherited class.

            Vec2f mouse_pos = controls.getMouseScreenPos();
            bool left_button = controls.mousePressed1;
            bool left_button_release = controls.isKeyJustReleased(KEY_LBUTTON);
            //bool right_button = controls.mousePressed2;
            //bool right_button_release = controls.isKeyJustReleased(KEY_RBUTTON);
            //bool scroll_up = controls.mouseScrollUp;
            //bool scroll_down = controls.mouseScrollDown;


            return true;
        }

        void Render() override
        {
            Menu::Render();

            /*if(!GUI::isFontLoaded(font))
            {
                error("Font " + font + " is not loaded.");
                return;
            }*/

            if(image_name != "")
            {
                GUI::DrawIcon(image_name, button_state == Pressed ? image_frame_press : image_frame, image_frame_size, upper_left_interpolated + image_pos, 0.5f);
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

            switch(menu_option)
            {
                case CheckBox:
                {
                    if(getInterpolation())//If this menu is interpolated.
                    {
                        if(upper_left != upper_left_old || lower_right != lower_right_old)
                        {
                            optional_menu.setPosition(upper_left_interpolated + optional_menu_pos);
                        }
                    }
                    optional_menu.Render();
                    //GUI::DrawRectangle(upper_left + optional_menu.getUpperLeft(), upper_left + optional_menu.getLowerRight());
                    break;
                }
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