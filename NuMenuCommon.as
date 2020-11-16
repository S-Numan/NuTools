f32 FRAME_TIME = 0.0f; // last frame time
const float MARGIN = 255.0f; 


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
//TODO fix text/font size changing//Copy and paste several font files and fix text
//TODO don't draw when out of range
//TODO fix things attached to blobs being a tick delayed
//TODO titlebar text? Basically text on the very top middle of the menu. Add it!
//Add sfx for on hover and on justpress then on release.
//Stretchy ends for MenuBasePlus. Drag the menu size around.


    
    enum POSPositions//Stores all positions that stuff can be in.
    {
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


    u8 MenuOptionHolder = 100;

    enum MenuOptions
    {
        Blank,
        Custom,
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
        CBlob@ getOwnerBlob();
        bool setOwnerBlob(CBlob@ _blob);
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
        Vec2f getPosInterpolated();
        Vec2f getUpperLeft(bool get_raw_pos = false);
        void setUpperLeft(Vec2f value);
        Vec2f getPos(bool get_raw_pos = false);
        void setPos(Vec2f value);
        Vec2f getLowerRightInterpolated();
        Vec2f getLowerRight(bool get_raw_pos = false);
        void setLowerRight(Vec2f value);
        Vec2f getSize();
        void setSize(Vec2f value);

        bool didMenuJustMove();
        void setMenuJustMoved(bool value);

        Vec2f getRelationPos();
        void setRelationPos(Vec2f value);

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
            default_buffer = 4.0f;
            is_world_pos = false;
            move_to_owner = true;
            
            button_state = Idle;

            render_background = true;

            did_menu_just_move = false;
        }

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

        bool move_to_owner;//If this is true, this menu will move itself to the position of it's owner with relation added to it. 
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


        u8 button_state;//State of button (being pressed? mouse is hovered over?)
        u8 getMenuState()
        {
            return button_state;
        }

        private bool render_background;//If this is true, the menu will draw a background for the menu button by default.
        bool getRenderBackground()
        {
            return render_background;
        }
        void setRenderBackground(bool value)
        {
            render_background = value;
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

        private array<Vec2f> upper_left(3);//Upper left of menu. [0] is normal; [1] is old; [2] is interpolated 
        Vec2f getUpperLeft(bool get_raw_pos = false)//If this bool is true; even if isWorldPos() is true, it will get the raw position. I.E in most cases the actual world position. not the world to screen pos. does nothing if isWorldPos is false.
        {
            if(isWorldPos() && !get_raw_pos)
            {
                //CCamera@ camera = getCamera();
                Driver@ driver = getDriver();//This might be slow. - Todo numan
                return driver.getScreenPosFromWorldPos(upper_left[0]);
            }
            
            return upper_left[0];
        }
        void setUpperLeft(Vec2f value)
        {
            upper_left[0] = value;
            menu_size = Vec2f(lower_right[0].x - upper_left[0].x, lower_right[0].y - upper_left[0].y);
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

        private array<Vec2f> lower_right(3);//Lower right of menu. [0] is normal; [1] is old; [2] is interpolated
        Vec2f getLowerRight(bool get_raw_pos = false)//If this bool is true; even if isWorldPos() is true, it will get the raw position. I.E in most cases the actual world position. not the world to screen pos. does nothing if isWorldPos is false.
        {
            if(isWorldPos() && !get_raw_pos)
            {
                Driver@ driver = getDriver();
                return driver.getScreenPosFromWorldPos(lower_right[0]);
            }

            return lower_right[0];
        }
        void setLowerRight(Vec2f value)
        { 
            lower_right[0] = value;
            menu_size = Vec2f(lower_right[0].x - upper_left[0].x, lower_right[0].y - upper_left[0].y);
            setMenuJustMoved(true);
        }

        

        private Vec2f menu_size;//The size of the menu. How far it takes for top_left to get to lower_right.
        Vec2f getSize()
        {
            return menu_size;
        }
        void setSize(Vec2f value)//Changes the length of the lower_right pos to make it the correct size.
        {
            setLowerRight(upper_left[0] + value);
        }



        bool getPosOnSize(u16 position, Vec2f size, Vec2f &out vec_pos, bool no_buffer = false)//Insert an enum for a position based on the menu. Note that this only gives you positions based on the size. Not position on screen/world. Add getPos() to this if you want the real position.
        {
            float temp_buffer = default_buffer;
            if(no_buffer)
            {
                temp_buffer = 0;
            }

            switch(position)
            {
                case POSCenter:
                    vec_pos = Vec2f(size.x/2, size.y/2);
                    break;
                case POSTop:
                    vec_pos = Vec2f(size.x/2, temp_buffer);
                    break;
                case POSAbove:
                    vec_pos = Vec2f(size.x/2, -temp_buffer); 
                    break;
                case POSBottom:
                    vec_pos = Vec2f(size.x/2, size.y - temp_buffer);
                    break;
                case POSUnder:
                    vec_pos = Vec2f(size.x/2, size.y + temp_buffer);
                    break;
                case POSLeft:
                    vec_pos = Vec2f(temp_buffer, size.y/2);
                    break;
                case POSLefter:
                    vec_pos = Vec2f(-temp_buffer, size.y/2);
                    break;
                case POSRight:
                    vec_pos = Vec2f(size.x - temp_buffer, size.y/2);
                    break;
                case POSRighter:
                    vec_pos = Vec2f(size.x + temp_buffer, size.y/2);
                    break;
                default://Position out of bounds
                {
                    vec_pos = Vec2f_zero;//Just return 0,0
                    return false;//Nope.
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
                Driver@ driver = getDriver();
                return driver.getScreenPosFromWorldPos(upper_left[1]);
            }
            
            return upper_left[1];
        }
        Vec2f getLowerRightOld(bool get_raw_pos = false)
        {
            if(isWorldPos() && !get_raw_pos)
            {
                Driver@ driver = getDriver();
                return driver.getScreenPosFromWorldPos(lower_right[1]);
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
                    if(getOwnerBlob() != null && getMoveToOwner())
                    {
                        CCamera@ camera = getCamera();
                        Driver@ driver = getDriver();//This might be even slower. - Todo numan
                        CBlob@ _blob = getOwnerBlob();

                        upper_left[2] = driver.getScreenPosFromWorldPos(_blob.getInterpolatedPosition()) + getRelationPos() * (camera.targetDistance * 2);

                        lower_right[2] = upper_left[2] + getSize() * (camera.targetDistance * 2);
                    }
                    else//*/
                    {
                        upper_left[2] = Vec2f_lerp(getUpperLeftOld(), getUpperLeft(), FRAME_TIME);

                        lower_right[2] = Vec2f_lerp(getLowerRightOld(), getLowerRight(), FRAME_TIME);
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
       
        bool Render()//Overwrite this method if you want a different look.
        {
            Driver@ driver = getDriver();

            //If this cannot be seen.
            if(getUpperLeft().x  - MARGIN > driver.getScreenWidth()
            || getUpperLeft().y  - MARGIN > driver.getScreenHeight()
            || getLowerRight().x + MARGIN < 0
            || getLowerRight().y + MARGIN < 0 )
            {
                return false;//Don't draw it then.
            }

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
                
                GUI::DrawRectangle(getUpperLeftInterpolated(), getLowerRightInterpolated(), rec_color);
            }

            return true;
        }

        //
        //Rendering
        //
    }
    
    //Base of all menus + more stuff. Stuff includes text, a titlebar (can be hidden and simply used for dragging the menu.) And a method that allows you to check if this was pressed and the states it can be in. Allows a single icon as well
    class MenuBasePlus : MenuBase
    {
        MenuBasePlus(string _name, u8 _menu_option = Custom)
        {
            if(!isClient())
            {
                return;
            }

            super(_name, _menu_option);
            
            setTextColor(SColor(255, 0, 0, 0));

            setFont("AveriaSerif-Bold.ttf", 4);
        }

        MenuBasePlus(Vec2f _upper_left, Vec2f _lower_right, string _name, u8 _menu_option = Custom)
        {
            if(!isClient())
            {
                return;
            }

            super(_upper_left, _lower_right, _name, _menu_option);
            
            setTextColor(SColor(255, 0, 0, 0));

            setFont("AveriaSerif-Bold.ttf", 4);
        }

        void initVars() override
        {
            MenuBase::initVars();
            draw_text = true;
            reposition_text = false;
            resize_text = false;
            text_used = false;

            titlebar_ignore_press = false;
            titlebar_draw = true;

            initial_press = false;
        }



        //
        //Overrides
        //
        void setUpperLeft(Vec2f value) override
        {
            //print("repos2 = " + reposition_text + " resize = " + resize_text + " draw_text = " + draw_text + " text_used = " + text_used);
            MenuBase::setUpperLeft(value);
            if(reposition_text)
            {
                RepositionAllText(getSize());
            }
        }

        void setPos(Vec2f value) override
        {
            MenuBase::setPos(value);
            if(reposition_text)
            {
                RepositionAllText(getSize());
            }
        }

        void setLowerRight(Vec2f value) override
        { 
            MenuBase::setLowerRight(value);
            if(reposition_text)
            {
                RepositionAllText(getSize());
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
        
        
        private array<string> text_strings(POSPositionsCount, "");
        private array<Vec2f> text_positions(POSPositionsCount);

        string getText(u16 array_position)
        {
            if(array_position >= text_strings.size())
            {
                error("getText : Tried to get text out of array bounds");
                return "";
            }
            return text_strings[array_position];
        }
        void setText(string text, u16 array_position)
        {
            Vec2f text_pos;
            if(!getDesiredTextPosition(text, array_position, getSize(), text_pos))
            {
                warning("Text position went above the text_positions array max size");
                return;
            }


            text_positions[array_position] = text_pos;
            
            text_used = UpdateIsTextUsed();
            
            text_strings[array_position] = text;
        }

        bool getDesiredTextPosition(string text, u16 array_position, Vec2f size , Vec2f &out text_pos, bool no_buffer = false)//Returns the text position of the desired array_position
        {
            GUI::SetFont(font);
            Vec2f text_dimensions;
            GUI::GetTextDimensions(text, text_dimensions);

            if(!getPosOnSize(array_position, size, text_pos))
            {
                return false;
            }

            switch(array_position)
            {
                case POSTop:
                    text_pos = Vec2f(text_pos.x - text_dimensions.x/2, text_pos.y);
                    break;
                case POSAbove:
                    text_pos = Vec2f(text_pos.x - text_dimensions.x/2, text_pos.y - text_dimensions.y); 
                    break;
                case POSBottom:
                    text_pos = Vec2f(text_pos.x - text_dimensions.x/2, text_pos.y - text_dimensions.y);
                    break;
                case POSUnder:
                    text_pos = Vec2f(text_pos.x - text_dimensions.x/2, text_pos.y);
                    break;
                case POSLeft:
                    text_pos = Vec2f(text_pos.x, text_pos.y - text_dimensions.y/2);
                    break;
                case POSLefter:
                    text_pos = Vec2f(text_pos.x - text_dimensions.x, text_pos.y - text_dimensions.y/2);
                    break;
                case POSRight:
                    text_pos = Vec2f(text_pos.x - text_dimensions.x, text_pos.y - text_dimensions.y/2);
                    break;
                case POSRighter:
                    text_pos = Vec2f(text_pos.x, text_pos.y - text_dimensions.y/2);
                    break;
                case POSCenter:
                    text_pos = Vec2f(text_pos.x - text_dimensions.x/2, text_pos.y - text_dimensions.y/2);
                    break;
            }

            return true;
        }

        void RepositionAllText(Vec2f size)
        {
            if(draw_text && isTextUsed())
            {
                for(u16 i = 0; i < POSPositionsCount; i++)
                {
                    string text = getText(i);
                        
                    if(text.size() == 0)
                    {
                        continue;
                    }

                    Vec2f text_pos;

                    getDesiredTextPosition(text, i, size, text_pos);
                    
                    setTextPos(text_pos, i);
                }
            }
        }


        
        Vec2f getTextPos(u16 array_position)
        {
            if(array_position >= text_positions.size())
            {
                error("getTextPos : Tried to get a position out of array bounds");
                return Vec2f_zero;
            }
            return text_positions[array_position];
        }
        void setTextPos(Vec2f value, u16 array_position)
        {
            if(array_position >= text_positions.size())
            {
                error("setTextPos : Tried to set a position out of array bounds");
                return;
            }
            
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

        bool titlebar_draw;//If this is false the titlebar will not be drawn (but will still function)

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

        bool initial_press;

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
                    if(left_button_release)//Same tick press and release.
                    {
                        _button_state = Released;//Button was released
                    }
                    else//Normal behavior
                    {
                        initial_press = true;//This button was initially pressed.
                        _button_state = JustPressed;//It was also just pressed.
                    }
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
            //Titlebar

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

        void setImage(string _image_name, u16 _image_frame, u16 _image_frame_press, Vec2f _image_frame_size, u16 position)
        {
            Vec2f _image_pos;
            
            if(!getPosOnSize(position, getSize(), _image_pos))
            {
                error("setImage position was an unknown position");
                return;
            }

            setImage(_image_name, _image_frame, _image_frame_press, _image_frame_size, _image_pos);
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


                Vec2f _upperleft = getUpperLeftInterpolated();//Upper left
                
                Vec2f _lowerright = (getUpperLeftInterpolated() + Vec2f(titlebar_size.x, +//Upper left plus titlebar_size.x +
                titlebar_size.y * (isWorldPos() ? camera.targetDistance * 2 : 1))); //titlebar_size.y multiplied by the camera distance if isWorldPos() is true.

                GUI::DrawRectangle(_upperleft, _lowerright);
            }
            //
            //Titlebar

            RenderImage(camera);

            //Text Stuff
            //

            if(isTextUsed() && draw_text)//If text exists and it is supposed to be drawn.
            {
                SelectFont();//Sets the font

                //For repositionioning text in an interpolated manner. Only works if reposition_text is true.
                if((reposition_text && isInterpolated())//If this menu is interpolated 
                && didMenuJustMove() || isWorldPos())//and the menu just moved or is on a world position.
                {
                    RepositionAllText(getLowerRightInterpolated() - getUpperLeftInterpolated());
                }
                
                for(u16 i = 0; i < text_strings.size(); i++)
                {
                    GUI::DrawText(text_strings[i], getUpperLeftInterpolated() + text_positions[i], //* (isWorldPos() ? 1 * 1 : 1),//lol what?
                    text_color);
                }
            }
            //
            //Text stuff

            return true;
        }

        void RenderImage(CCamera@ camera)
        {
            if(image_name != "")
            {
                GUI::DrawIcon(image_name,
                button_state == Pressed ? image_frame_press : image_frame,
                image_frame_size,
                getUpperLeftInterpolated() + image_pos * (isWorldPos() ? camera.targetDistance : 1),
                isWorldPos() ? camera.targetDistance : 0.5);
            }
        }

        //
        //Rendering
        //

    }

    //Menu set up to function like a button.
    class MenuButton : MenuBasePlus
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
            
            setOwnerBlob(blob);//This is the button's owner. The button will follow this blob (can be disabled).
            setIsWorldPos(true);//The position of the button is in the world, not the screen as the button is following a blob, a thing in the world. Therefor isWorldPos should be true.

            super(_name, Button);
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
            MenuBasePlus::initVars();
            send_to_rules = false;
            kill_on_press = false;
            instant_press = false;
        }


        string command_string = "";//The command id sent out upon being pressed.
        bool send_to_rules;//If this is false, it will attempt to send the command_string to the owner blob. Otherwise it will send it to CRules.
        CBitStream params;//The params to accompany above


        bool kill_on_press;

        bool instant_press;//If this is true, the button will trigger upon being just pressed.

        float enableRadius = 0.0f;//The radius at which the button can be pressed


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
            if(!MenuBasePlus::Tick())
            {
                return false;
            }

            CPlayer@ player = getLocalPlayer();

            CControls@ controls = player.getControls();
            
            bool key_button = controls.isKeyPressed(key_code);//Pressing
            bool key_button_release = controls.isKeyJustReleased(key_code);//Just released
            bool key_button_just = controls.isKeyJustPressed(key_code);//Just pressed


            float distance_from_button = getDistance(position, getPos(true) + getSize() / 2);
            
            if(enableRadius == 0.0f || position == Vec2f_zero ||
            distance_from_button < enableRadius)//Is within enable(interact) distance
            {
                button_state = getPressingState(point, button_state, key_button, key_button_release, key_button_just);
                if(instant_press)
                {
                    if(button_state == JustPressed)
                    {
                        button_state = Released;
                    }
                    else if(button_state == Hover)
                    {
                        button_state = Pressed;
                    }
                }
                
            }
            else
            {
                button_state = Disabled;
            }


            if(button_state == Released)
            {
                sendCommand();
            }

            return true;
        }

        bool Render() override
        {
            if(!MenuBasePlus::Render())
            {
                return false;
            }
        
            return true;
        }

        void sendCommand()
        {
            if(command_string != "")
            {
                if(send_to_rules)
                {
                    CRules@ _rules = getRules();

                    _rules.SendCommand(_rules.getCommandID(command_string), params);
                }
                else if(getOwnerBlob() != null)
                {
                    CBlob@ _owner = getOwnerBlob();

                    _owner.SendCommand(_owner.getCommandID(command_string), params);
                }
            }
        }

        float getDistance(Vec2f point1, Vec2f point2)
        {
            float dis = (Maths::Pow(point1.x-point2.x,2)+Maths::Pow(point1.y-point2.y,2));
            return Maths::Sqrt(dis);
            //return getDistanceToLine(point1, point1 + Vec2f(0,1), point2);
        }

        void RenderImage(CCamera@ camera) override
        {
            if(image_name != "")
            {
                GUI::DrawIcon(image_name, button_state == Pressed ? image_frame_press : image_frame, image_frame_size, getUpperLeftInterpolated() + image_pos * camera.targetDistance,
                isWorldPos() ? camera.targetDistance : 0.5, button_state == Disabled ? SColor(80, 255, 255, 255) : SColor(255, 255, 255, 255));
            }
        }
    }

    //Menu setup to function like an check box. Click once and it's state changes.
    class MenuCheckBox : MenuBasePlus
    {
        MenuCheckBox(string _name)
        {
            if(!isClient())
            {
                return;
            }

            render_background = false;

            super(_name, CheckBox);
        }
        MenuCheckBox(Vec2f _upper_left, Vec2f _lower_right, string _name)
        {
            if(!isClient())
            {
                return;
            }

            render_background = false;

            super(_upper_left, _lower_right, _name, CheckBox);
        }

        void initVars() override
        {
            MenuBasePlus::initVars();
            menu_checked = false;
        }

        bool menu_checked;

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

        bool Render() override
        {
            if(!MenuBasePlus::Render())
            {
                return false;
            }

            InterpolatePositions();

            if(menu_checked == true)
            {
                GUI::DrawRectangle(getUpperLeftInterpolated(), getLowerRightInterpolated(), SColor(255, 25,127,25));
            }
            else
            {
                GUI::DrawRectangle(getUpperLeftInterpolated(), getLowerRightInterpolated(), SColor(255, 127,25,25));
            }

            return true;
        }
    }









    //This menu is designed to hold other menu's and keep them attached to it.
    class MenuHolder : MenuBasePlus
    {
        MenuHolder(string _name)
        {
            if(!isClient())
            {
                return;
            }
            super(_name, MenuOptionHolder);
        }

        MenuHolder(Vec2f _upper_left, Vec2f _lower_right, string _name)
        {
            if(!isClient())
            {
                return;
            }
            super(_upper_left, _lower_right, _name, MenuOptionHolder);
        }

        void initVars() override
        {
            MenuBasePlus::initVars();
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
                
                if(_menu.getMoveToOwner())
                {
                    _menu.setPos(getPos(true) + _menu.getRelationPos());
                }
                
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

        bool Render() override
        {
            if(!MenuBasePlus::Render())
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



    
    
    void onTick( CRules@ rules )
    {
        FRAME_TIME = 0.0f;
    }

    void onRender( CRules@ rules )
    {
        FRAME_TIME += Render::getRenderDeltaTime() * getTicksASecond();
    }
}