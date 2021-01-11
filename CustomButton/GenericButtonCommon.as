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
    //Debug
    //button.setSize(Vec2f(30,30));//Note as the start of a menu is the top left, unless compensated by setRelationPos, this will uncenter the button from the thing it's on.
    //button.setOffset(-(button.getSize() / 2));//Where the button is in relation to it's OwnerBlob. This should center the button directly on the blob.
    //button.setInterpolated(false);

    //MISC
    button.setRenderBackground(false);//Just in case this tries to render, stop it. This is more for preventing legacy code from doing a bad.
    button.kill_on_release = true;//Changes whether the button will be removed when it is pressed.(released) (logic for this happens outside the button class).
    button.instant_press = true;//Button command/script is sent/called upon just pressing.
    button.enableRadius = 36.0f;//How close you have to be to press the button. Out of this distance the button is greyed out and unpressable.

    //Position
    button.setIsWorldPos(true);//This button is on the world.

    //Collision
    button.setRadius(16.0f);//Radius of button. The collision circle of the button.
    button.setCollisionLowerRight(Vec2f(0,0));//Removes the collision box. In most cases.
    button.setCollisionSetter(false);//By default, the button uses a collision box for collisions, not a radius. After changing the collision box, this will prevent the button from changing the collision box back to it's own size again.

    //Text
    button.draw_text = false;//Don't initially draw text.
    button.reposition_text = true;//Make sure the text is constantly under the button in the correct position when drawing.
    button.default_buffer = 12.0f;//Buffer between bottom of the button and the text. Provided there is text.
    button.setTextColor(SColor(255, 255, 255, 255));//The color of the text of the button of the blob of the game of the computer of the screen
    //button.setFont("AveriaSerif-Regular1", 16);//debug todo

    //Sound
    button.menu_sounds_on[NuMenu::JustHover] = "select.ogg";//Button sound played upon just hovering over the button.
    button.menu_sounds_on[NuMenu::Released] = "buttonclick.ogg";//Button sound played upon releasing the button.
    button.menu_volume = 3.0f;//Volume of sound from this button.
    button.play_sound_on_world = false;//This changes whether the sound is 2d or the sound is played on a point in the world.

    //Icon
    NuMenu::MenuImage@ icon = button.setIcon("GUI/InteractionIconsBackground.png",//Image name
        Vec2f(32, 32),//Icon frame size
        0,//Default frame
        1,//Hover frame 
        1,//Pressing frame
        0);//Image position

    Vec2f icon_pos;
    button.getDesiredPosOnSize(NuMenu::POSCenter, button.getSize(), icon.frame_size, button.default_buffer, icon_pos);
    icon.pos = icon_pos;

    icon.color_on[NuMenu::Disabled].setAlpha(80);//Get the color of the icon when it is disabled, and change it to fade out when disabled.
}

void addButton(CBlob@ caller, NuMenu::MenuButton@ button)
{
    button.Tick(caller.getPosition());//Tick button once to initially set the button state. For example if the button is out of range this will instantly tell the button to be greyed. Without this the button with be normal for a tick.

    array<NuMenu::MenuButton@>@ buttons;//Init array.
    getRules().get("CustomButtons", @buttons);//Grab array.
    buttons.push_back(button);//Put button in CustomButtons array.
}