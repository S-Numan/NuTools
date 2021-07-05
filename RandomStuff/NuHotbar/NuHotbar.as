#include "NuMenuCommon.as";//For menus.
#include "NumanLib.as";//For misc usefulness.
#include "NuTextCommon.as";//For text and fonts.
#include "NuHub.as";//For hauling around menus and fonts.

u16 temp_hotbarsize = 10;
NuMenu::GridMenu@ hotbar = @null;

void onInit( CBlob@ blob )
{
    if(!isClient()) { return; }

    setHotbar(blob, temp_hotbarsize);
}

void setHotbar(CBlob@ blob, u8 hotbar_length)
{
    if(!isClient()) { return; }

    NuHub@ hub;
    if(!getHub(@hub)) { return; }

    @hotbar = @NuMenu::GridMenu(//This menu is a GridMenu. The GridMenu inherits from BaseMenu, and is designed to hold other menus in an array in a grid fashion.
        "hb_" + blob.getNetworkID());//Name of the menu which you can get later.

    //hotbar.setPos(Vec2f(0,0));


    hotbar.die_when_no_owner = true;


    hotbar.top_left_buffer = Vec2f(0.0f, 0.0f);//This allows you to change the distance of all the buttons from the top left of the menu

    hotbar.setBuffer(Vec2f(32.0f, 32.0f));//This sets the buffer between buttons on the menu

    hotbar.StretchArray(hotbar_length, 0);

    for(u16 x = 0; x < hotbar_length; x++)//Grid width
    {
        NuMenu::MenuButton@ button = NuMenu::MenuButton("" + x);
        button.setSize(Vec2f(32, 32));  

        button.addReleaseListener(@ButtonPressed);//A function.

        if(x < 10)//Caps hotkeys to the 0-9 keys
        {
            button.addFreeCode(KEY_KEY_0 + ((x + 1) % 10));//Equation that does that 1-10 + 0 hotbar layout for the buttons. button0 gets KEY_KEY_1, and button9 gets KEY_KEY_0.
        }
        
        hotbar.setMenu(x,//Set the position on the width of the grid
            0,//The position on the height of the grid
            @button);//And add the button
    }










    hub.addMenuToList(hotbar);//This tells the hotbar to be ticked. It also stores it for other places to easily grab it.
}

void ButtonPressed(CPlayer@ caller, CBitStream@ params, NuMenu::IMenu@ button, u16 key_code)
{
    if(!isClient()) { return; }
    
    //u16 num = parseInt(button.getName().substr(0, BPOS));

    string blob;//Blob name in hotbar button
    u16 blob_id;//Blob id in hotbar button

    //Read params for blob.
    if(!params.saferead_string(blob)) { blob = ""; }//If no blob is found in params, make the blob string blank.
    if(!params.saferead_u16(blob_id)) { blob_id = 0; }//If no blob_id is found in params, make the blob_id int 0.
    if(blob != "" && blob_id != 0){ params.write_string(blob); params.write_u16(blob_id); params.ResetBitIndex(); }//Rewrite the parameters that were removed


    CBlob@ caller_blob = caller.getBlob();//blob that blob's and stuff are based around
    CBlob@ carried_blob = @null;//Blob the caller_blob is holding
    if(caller_blob != @null) 
    {
        @carried_blob = @caller_blob.getCarriedBlob();
    }

    if(key_code == KEY_RBUTTON)
    {
        params.Clear(); //Clear params
        button.resizeBackgrounds(1);

        
        if(carried_blob != @null)
        {
            params.write_string(carried_blob.getName());
            params.write_u16(carried_blob.getNetworkID());

            CSprite@ carried_sprite = carried_blob.getSprite();
            if(carried_sprite != @null)
            {//Assign sprite as image on button

                Nu::NuStateImage@ _background = Nu::NuStateImage(NuMenu::ButtonStateCount);

                _background.CreateImage(carried_sprite.getFilename(), @carried_sprite);

                for(u16 i = 0; i < NuMenu::ButtonStateCount; i++)
                {
                    _background.color_on[i] = NuMenu::DebugColor(i);
                }

                button.addBackground(@_background);
            }
            
            params.ResetBitIndex();
        }
    }
    else if(caller_blob != @null && blob != "" && blob_id != 0)//Key code is probably LButton(or 0-10). Thus, get the item out of the inventory or put it in if it exists.
    {
        CInventory@ inv = caller_blob.getInventory();
        if(inv == @null) { return; }
        
        CBlob@ hotbar_blob = getBlobByNetworkID(blob_id);
        if(hotbar_blob != @null && hotbar_blob.getName() == blob)//Confirm they are the same type of blobs.
        {
            //While this may normally seem like it could possibly grab a random same named item from across the map and jam it into caller_blob's hands, keep in mind it must be in the caller_blob's inventory.
            //The worst that could happen is accidently getting the wrong blob of the same type from the inventory, which would both be very rare and unlikely to make any difference.
            Nu::SwitchFromInventory(caller_blob, hotbar_blob);
        }
        else//It doesn't exist or isn't the same exact blob?
        {
            Nu::SwitchFromInventory(caller_blob, blob);//Just get any.
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