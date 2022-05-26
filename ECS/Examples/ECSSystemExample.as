#include "ECSComponentCommon.as"
#include "ECSComponentExample.as"
#include "ECSSystemCommon.as"
#include "ECSEntityExample.as"

itpol::Pool@ it_pol;
void onInit(CRules@ rules)
{
    if(!isClient()) { return; }//Stop if server
    
    print("ecs test start");

    onInitSystem(rules);

    /*
    for(u32 i = 0; i < 1000; i++)
    {
        u32 enemy_id = EnT::AddEnemy(rules, it_pol, Vec2f(0,30), Vec2f(1, 0), 1.0f);

        it_pol.UnassignByType(enemy_id, SType::IMAGE);
    }//*/

    //print("remove ent test");
    u32 remove_ent_id = EnT::AddEnemy(rules, it_pol, Vec2f(0,10), Vec2f(1, 0), 30.0f);
    it_pol.RemoveTag(remove_ent_id, "dieoffscreen".getHash());
    it_pol.RemoveEntity(remove_ent_id);


    //print("use removed ent components test");
    EnT::AddEnemy(rules, it_pol, Vec2f(0,100), Vec2f(2, 0), 30.0f);
    
    
    //print("remove component from ent test");
    u32 remove_com_id = EnT::AddEnemy(rules, it_pol, Vec2f(0,200), Vec2f(3, 0), 30.0f);
    it_pol.UnassignByType(remove_com_id, SType::HEALTH);

    
    EnT::AddEnemy(rules, it_pol, Vec2f(0,300), Vec2f(4, 0), 30.0f);

    //print("check duplicate adding");

    u32 enemy_id3 = EnT::AddEnemy(rules, it_pol, Vec2f(0,400), Vec2f(5, 0), 30.0f);
    array<u32> com_type_array = 
    {
        SType::POS,
        SType::HEALTH
    };

    //print("ByType duplicate test");
    it_pol.AssignByType(enemy_id3, com_type_array);
    
    //print("ByID duplicate test");
    CType::IComponent@ com = CType::getComByType(rules, SType::POS);
    u32 enemy_id3_com_id = it_pol.AddComponent(com);
    it_pol.AssignByID(enemy_id3, com.getType(), enemy_id3_com_id);


    EnT::AddEnemy(rules, it_pol, Vec2f(0,500), Vec2f(6, 0), 9.0f);//extra

}


array<SystemFuncs@>@ sys_logic;
array<u32>@ sys_logic_type;//Starting types for sys_logic. Will loop over every component of this type, and be given as a param.
array<SystemFuncs@>@ sys_render;
array<u32>@ sys_render_type;

void onInitSystem(CRules@ rules)
{
    @it_pol = itpol::Pool();
    rules.set("it_pol", @it_pol);


    array<GetComByType@>@ get_com_by_type = SYS::GetComByTypeArray(rules);
    get_com_by_type.push_back(SType::getStandardComByType);



    SYS::CreateSystem(rules, sys_logic, sys_logic_type, "sys_logic");

    SYS::AddToSystem(rules, "sys_logic", 
    SType::CPos::SystemOldPosIsNewPos, SType::POS);

    SYS::AddToSystem(rules, "sys_logic", 
    SType::CVelocity::SystemApplyVelocity, SType::VELOCITY);

    SYS::AddToSystem(rules, "sys_logic",
    SType::SystemTagDieOffScreen, SType::POS);


    SYS::CreateSystem(rules, sys_render, sys_render_type, "sys_render");

    SYS::AddToSystem(rules, "sys_render", 
    SType::CImage::SystemRenderImage, SType::IMAGE);



    it_pol.on_entity_die.push_back(onEntDie);

}

void onTickSystem(CRules@ rules)
{
    SYS::TickSystem(it_pol, sys_logic, sys_logic_type);
}

void onTick(CRules@ rules)
{
    if(!isClient()) { return; }//Stop if server
    
    //itpol::Pool@ it_pol;
    //if(!rules.get("it_pol", @it_pol)) { Nu::Error("Failed to get it_pol"); return; }//Get the pool

    onTickSystem(rules);
}

void onRenderSystem(CRules@ rules)
{
    SYS::TickSystem(it_pol, sys_render, sys_render_type);

    Render::SetTransformWorldspace();//Kag gets cranky if you don't do this yourself.
}

void onRender(CRules@ rules)
{
    onRenderSystem(rules);
}



void onEntDie(itpol::Pool@ it_pol, EType::Entity@ ent)
{
    u16 CPos_pos;
    u16 CVelocity_pos;
    if(EType::HasTag(ent, "dieoffscreen".getHash()) && EType::EntityHasType(ent, SType::POS, CPos_pos) && EType::EntityHasType(ent, SType::VELOCITY, CVelocity_pos))
    {
        SType::CPos@ CPos = cast<SType::CPos@>(ent[CPos_pos]);
        SType::CVelocity@ CVelocity = cast<SType::CVelocity@>(ent[CVelocity_pos]);
        
        u32 new_ent_id = EnT::AddEnemy(getRules(), it_pol, Vec2f(0.0f, CPos.pos.y), CVelocity.velocity, 9.9f);//extra
        EType::Entity@ new_ent = it_pol.getEnt(new_ent_id);

        //Iterate from by 1.
        u16 CImage_pos;
        u16 new_CImage_pos;
        if(EType::EntityHasType(ent, SType::IMAGE, CImage_pos)
        && EType::EntityHasType(new_ent, SType::IMAGE, new_CImage_pos))
        {
            SType::CImage@ CImage = cast<SType::CImage@>(ent[CImage_pos]);
            SType::CImage@ new_CImage = cast<SType::CImage@>(new_ent[new_CImage_pos]);

            new_CImage.image.setFrame(CImage.image.getFrame() + 1);
        }
    }
}



