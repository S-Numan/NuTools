#include "NuMenuCommon.as";

bool canSeeButtons(CBlob@ this, CBlob@ caller, bool team_only = false, f32 max_distance = 9999.0f)
{
	if ((this is null || caller is null)) { return false; }

    max_distance = this.getRadius() + caller.getRadius()//The radius of the blob plus the player's blob. (basically both their sizes)
    + max_distance;//Plus max_distance

    if ((team_only && caller.getTeamNum() != this.getTeamNum()) ||//return false if not equal to this team.
        this.getDistanceTo(caller) > max_distance) { return false; }//return false if the distance is further than distance_max.

    CInventory@ inv = this.getInventory();

	return (
		//is attached to this or not attached at all (applies to vehicles and quarters)
		(caller.isAttachedTo(this) || !caller.isAttached()) &&
		//is inside this inventory or not inside an inventory at all (applies to crates)
		((inv !is null && inv.isInInventory(caller)) || !caller.isInInventory())
	);
}

void initButton(NuMenu::MenuButton@ button)
{
    button.kill_on_press = true;//The button will be removed on press. (logic for this happens outside the button class)
    button.instant_press = true;//Button is Pressed when hovering over. Button is instantly released upon pressing.
    button.draw_text = false;//Don't initially draw text.
    button.reposition_text = true;//Make sure the text is constantly under the button in the correct position.

    button.setRelationPos(-(button.getSize() / 2));//Where the button is in relation to it's OwnerBlob. This should center the button directly on the blob.

    button.setTextColor(SColor(255, 255, 255, 255));//The color of the text of the button.

    button.menu_sounds_on[NuMenu::Pressed] = "select.ogg";
    button.menu_sounds_on[NuMenu::Released] = "buttonclick.ogg";
    button.menu_volume = 3.0f;
}

void addButton(CBlob@ caller, NuMenu::MenuButton@ button)
{
    button.Tick(caller.getPosition());//Tick button once to initially set the button state. For example if the button is out of range this will instantly tell the button to be greyed. Without this the button with be normal for a tick.

    array<NuMenu::MenuButton@>@ buttons;//Init array.
    getRules().get("CustomButtons", @buttons);//Grab array.
    buttons.push_back(button);//Put button in CustomButtons array.
}