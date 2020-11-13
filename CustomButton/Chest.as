// Chest.as

#include "LootCommon.as";
#include "GenericButtonCommon.as";
#include "NuMenuCommon.as";

void onInit(CBlob@ this)
{
	// Activatable.as adds the following
	// this.Tag("activatable");
	// this.addCommandID("activate");

	// used by RunnerMovement.as & ActivateHeldObject.as
	this.Tag("medium weight");

	AddIconToken("$chest_open$", "InteractionIcons.png", Vec2f(32, 32), 20);
	AddIconToken("$chest_close$", "InteractionIcons.png", Vec2f(32, 32), 13);

	if (getNet().isServer())
	{
		// todo: loot based on gamemode
		CRules@ rules = getRules();

		if (rules.gamemode_name == TDM)
		{
			addLoot(this, INDEX_TDM, 2, 0);
		}
		else if (rules.gamemode_name == CTF)
		{
			addLoot(this, INDEX_CTF, 2, 0);
		}
		addCoin(this, 40 + XORRandom(40));
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		u8 team_color = XORRandom(5);
		this.set_u8("team_color", team_color);

		sprite.SetZ(-10.0f);
		sprite.ReloadSprites(team_color, 0);

		if (this.hasTag("_chest_open"))
		{
			sprite.SetAnimation("open");
			sprite.PlaySound("ChestOpen.ogg", 3.0f);
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if(this.exists(DROP)){ return; }//Chest only


	if (!canSeeButtons(this, caller)) { return; }

	const f32 DISTANCE_MAX = this.getRadius() + caller.getRadius() + 8.0f;
    if (this.getDistanceTo(caller) > DISTANCE_MAX) { return; }

	CBitStream params;
	params.write_u16(caller.getNetworkID());

	NuMenu::MenuButton@ button = NuMenu::MenuButton("");
    
    button.setIsWorldPos(true);
    button.setOwnerBlob(this);
    button.kill_on_press = true;
    button.instant_press = true;

    button.setSize(Vec2f(8, 8));
    button.setRelationPos(-(button.getSize() / 2));
    
    button.setImage("GUI/PartyIndicator.png",//Image name
            4,//Image frame
            5,//Image frame while pressed
            Vec2f(16, 16),//Image frame size
            Vec2f(0.0f, 0.0f));//Image position

    //button.image_pos = -button.image_frame_size - button.getSize() / 2;
    button.image_pos = -(button.getSize() / 2) - button.image_frame_size / 4;

    button.command_string = "activate";
    button.params = params;
            
	//getTranslatedString("Open"),                                     // description

	button.enableRadius = 200.0f;

    array<NuMenu::MenuButton@>@ buttons;
    getRules().get("CustomButtons", @buttons);
 
    button.Tick(caller.getPosition());
    buttons.push_back(button);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		this.AddForce(Vec2f(0, -800));

		if (getNet().isServer())
		{
			u16 id;
			if (!params.saferead_u16(id)) return;

			CBlob@ caller = getBlobByNetworkID(id);
			if (caller is null) return;

			// add guaranteed piece of loot from your class index
			const string NAME = caller.getName();
			if (NAME == "archer")
			{
				addLoot(this, INDEX_ARCHER, 1, 0);
			}
			else if (NAME == "builder")
			{
				addLoot(this, INDEX_BUILDER, 1, 0);
			}
			else if (NAME == "knight")
			{
				addLoot(this, INDEX_KNIGHT, 1, 0);
			}

			server_CreateLoot(this, this.getPosition(), caller.getTeamNum());
		}

		this.Tag("_chest_open");
		this.Sync("_chest_open", true);
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.SetAnimation("open");
			sprite.PlaySound("ChestOpen.ogg", 3.0f);
		}
	}
}

void onDie(CBlob@ this)
{
	if (getNet().isServer() && !this.exists(DROP))
	{
		addLoot(this, INDEX_TDM, 1, 0);
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.Gib();

		makeGibParticle(
		sprite.getFilename(),               // file name
		this.getPosition(),                 // position
		getRandomVelocity(90, 2, 360),      // velocity
		0,                                  // column
		3,                                  // row
		Vec2f(16, 16),                      // frame size
		1.0f,                               // scale?
		0,                                  // ?
		"",                                 // sound
		this.get_u8("team_color"));         // team number
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}