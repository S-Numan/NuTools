#include "NuMenuCommon.as";
#include "NuTextCommon.as";

void onInit( CRules@ this )
{
    if(!isClient())
    {
        return;
    }
    
    init = true;

    NuHub@ hub;
    if(!this.get("NuHub", @hub)) { error("Failed to get NuHub. Make sure NuHubLogic is before anything else that tries to use it."); return; }

    //hub.addFont("Arial_font.png");

    print("Text AAAA Creation");

    array<NuText@> screaming();
}

void onReload( CRules@ this )
{
    onInit(this);
}

//TODO, remove those that get too far away from the end of the map.

void onTick( CRules@ this )
{
    if(getGameTime() % 1 == 0)
    {
        CPlayer@ player = getLocalPlayer();
        if(player != null)
        {
            CControls@ controls = getControls();
            if(controls.isKeyPressed(KEY_KEY_E))
            {
                CBlob@ blob = player.getBlob();
                if(blob != null)
                {
                    NuText@ txt = NuText("Arial", "A");
                    txt.setIsWorldPos(true);
                    txt.setScale(Vec2f(0.25f, 0.25f));
                    screaming.push_back(@txt);
                
                    //screaming_direction.push_back(RandomDirection());    
                    screaming_direction.push_back(getRandomVelocity(0, 12.0f, 360));

                    screaming_pos.push_back(blob.getPosition() - txt.string_size_total / 2);
                
                    screaming_angle_vel.push_back(XORRandom(32));
                }
            }
        }
    }

    for(u16 i = 0; i < screaming.size(); i++)
    {
        screaming[i].setColor(SColor(255, 255, 0, 0));

        screaming[i].setAngle(screaming[i].getAngle() + screaming_angle_vel[i]);

        screaming_pos[i] += screaming_direction[i];
    }
}

array<NuText@> screaming;
array<Vec2f> screaming_pos;
array<Vec2f> screaming_direction;
array<float> screaming_angle_vel;


bool init;

void onRender(CRules@ this)
{
    if(!init){ return; }//If the init has not yet happened.
    for(u16 i = 0; i < screaming.size(); i++)
    {
        screaming[i].Render(screaming_pos[i]);
    }
}



Vec2f RandomDirection()
{
    u8 rnd = XORRandom(7);

    if(rnd == 0){
        return Vec2f(-1, 0);
    }
    else if(rnd == 1){
        return Vec2f(1, 0);
    }
    else if(rnd == 2){
        return Vec2f(0, 1);
    }
    else if(rnd == 3){
        return Vec2f(0, -1);
    }
    else if(rnd == 4){
        return Vec2f(1, 1);
    }
    else if(rnd == 5){
        return Vec2f(-1, -1);
    }
    else
    {
        return Vec2f(0,0);
    }

}