// OneClassAvailable.as

#include "StandardRespawnCommand.as";
#include "GenericButtonCommon.as";

const string req_class = "required class";

void onInit(CBlob@ this)
{
	this.Tag("change class drop inventory");
	if (!this.exists("class offset"))
		this.set_Vec2f("class offset", Vec2f_zero);

	if (!this.exists("class button radius"))
	{
		CShape@ shape = this.getShape();
		if (shape !is null)
		{
			this.set_u8("class button radius", Maths::Max(this.getRadius(), (shape.getWidth() + shape.getHeight()) / 2));
		}
		else
		{
			this.set_u8("class button radius", 16);
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (!canSeeButtons(this, caller,
    false,//Team only //Make true later todo numan notice remove this
    9999.0f)//Max distance
    || !this.exists(req_class))
    {
        return;
    }

    Vec2f _offset = this.get_Vec2f("class offset");//Quick fix for bad offsets.
    if(Maths::Abs(_offset.x) == 6)
    {
        _offset.x *= 2;
    }


    string cfg = this.get_string(req_class);

    if (canChangeClass(this, caller) && caller.getName() != cfg)
	{
		CBitStream params;
		write_classchange(params, caller.getNetworkID(), cfg);

		NuMenu::MenuButton@ button = NuMenu::MenuButton("", this);//Name of the button, and the button's owner. The button will automatically follow the owner unless specified not to.
        initButton(button);//Sets up things easily.

        button.setRelationPos(_offset);
        
        button.setText(getTranslatedString("Swap Class"), NuMenu::POSUnder);//The text on the button.

        //Icon
        NuMenu::MenuImage@ icon = button.setIcon("GUI/InteractionIcons.png",//Image name
            Vec2f(32, 32),//Icon frame size
            14,//Default frame
            14,//Hover frame 
            14,//Pressing frame
            NuMenu::POSCenter);//Image position
        icon.color_on[NuMenu::Disabled].setAlpha(80);//Get the color of the icon when it is disabled, and change it to fade out when disabled.

        button.params = params;
        button.setCommandID(SpawnCmd::changeClass);//This command will be sent to this blob when this button is pressed.

        addButton(caller, button);

		button.enableRadius = this.get_u8("class button radius");
	}


}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
}