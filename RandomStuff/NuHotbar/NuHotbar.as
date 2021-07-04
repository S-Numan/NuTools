#include "NuMenuCommon.as";//For menus.
#include "NumanLib.as";//For misc usefulness.
#include "NuTextCommon.as";//For text and fonts.
#include "NuHub.as";//For hauling around menus and fonts.

u16 temp_hotbarsize = 8;
NuMenu::GridMenu@ hotbar = @null;

void onInit( CBlob@ blob )
{
    if(!isClient()) { return; }

    setHotbar(blob, temp_hotbarsize);
}

void setHotbar(CBlob@ blob, u8 hotbar_length)
{
    if(!isClient()) { return; }

    NuHub@ hub;//First we make the hub variable.
    if(!getHub(@hub)) { return; }

    @hotbar = @NuMenu::GridMenu(//This menu is a GridMenu. The GridMenu inherits from BaseMenu, and is designed to hold other menus in an array in a grid fashion.
        "hb_" + blob.getNetworkID());//Name of the menu which you can get later.

    hotbar.die_when_no_owner = true;

    //Some useful functions.
    //hotbar.setUpperLeft(Vec2f(0,0));
    //hotbar.setLowerRight(Vec2f(0,0));
    //hotbar.setPos(Vec2f(0,0));
    //hotbar.getMiddle();

    hotbar.setIsWorldPos(false);//At any time you can swap a menu to be on world position, or screen position. This tells the menu to work on the screen.

    hotbar.clearBackgrounds();//Here we wipe the GridMenu's background.

    Nu::NuStateImage@ grid_image = Nu::NuStateImage(Nu::POSPositionsCount);//Here we create a state image with POSPositionCount states (for color and frames and stuff) 

    grid_image.CreateImage("hotbar_image", "RenderExample.png");//Creates an image from a png

    grid_image.setFrameSize(Vec2f(32, 32));//Here we set the frame size of the image.

    grid_image.setDefaultFrame(3);//Sets the default frame to frame 3.

    hotbar.addBackground(grid_image);//And here we add the grid_image as the background. The background image streches to meet the upper left and lower right.



    hotbar.top_left_buffer = Vec2f(8.0f, 8.0f);//This allows you to change the distance of all the buttons from the top left of the menu

    hotbar.setBuffer(Vec2f(32.0f, 32.0f));//This sets the buffer between buttons on the menu

    for(u16 x = 0; x < temp_hotbarsize; x++)//Grid width
    {
        NuMenu::MenuButton@ button = NuMenu::MenuButton(Vec2f(32, 32), Vec2f(32 * 2, 32 * 2), "" + x);  

        button.addReleaseListener(@ButtonPressed);//A function.

        hotbar.setMenu(x,//Set the position on the width of the grid
            0,//The position on the height of the grid
            @button);//And add the button
    }










    hub.addMenuToList(hotbar);//This tells the hotbar to be ticked. It also stores it for other places to easily grab it.
}

void ButtonPressed(CPlayer@ caller, CBitStream@ params, NuMenu::IMenu@ button, u16 key_code)
{
    if(!isClient()) { return; }
    print("function: button was pressed. Button had name " + button.getName());

    string button_name = button.getName();
    
    u16 BPOS = button_name.findFirst("B");

    u16 num = parseInt(button_name.substr(0, BPOS));

    print("num = " + num);

    string blob;

    //Read params for blob.
    if(!params.saferead_string(blob)) { blob = ""; }//If no blob is found in params, make the blob string blank. Otherwise make blob be the blob
    
    print("blob = " + blob);


    print("key_code = " + key_code);

    if(key_code == KEY_RBUTTON)
    {
        params.Clear(); //Clear params

        CBlob@ caller_blob = caller.getBlob();
        CBlob@ carried_blob = @null;
        if(caller_blob != @null) 
        {
            @carried_blob = @caller_blob.getCarriedBlob();
        }
        if(carried_blob != @null)
        {
            print("carried_blob name = " + carried_blob.getName());
            params.write_string(carried_blob.getName());
            blob = params.read_string();
            print("blob= " + blob);
        }
    }
}

void onTick( CBlob@ blob )
{
    if(!isClient()) { return; }
    
}
void onRender( CSprite@ sprite )
{
    if(!isClient()) { return; }
}


void onReload( CBlob@ blob )
{
    onDie(blob);
}

void onDie( CBlob@ blob )
{
    if(!isClient()) { return; }
    
    NuHub@ hub;//First we make the hub variable.
    if(!getHub(@hub)) { return; }

    hub.removeMenuFromList("hb_" + blob.getNetworkID());//Remember to remove the hotbar from the list.
}