#include "ECSComponentCommon.as"

namespace EnT
{
    //Return's the entity's id.
    u32 AddEnemy(CRules@ rules, itpol::Pool@ it_pol, Vec2f pos, Vec2f velocity, f32 health)
    {
        array<u32> com_type_array = 
        {
            SType::POS,
            SType::VELOCITY,
            SType::IMAGE,
            SType::HEALTH
        };

        u32 ent_id = EType::CreateEntity(rules, it_pol, com_type_array,//Creates the entity with the specified components. Returns the entity id.
        true);//If this is true, every component will be defaulted. If this is false, components will retain their previous values. Whatever they may be.

        //TODO, add (remove on position outside of screen tag)
        //TODO, add system that calls AddEnemy when one gets removed.

        //Default params.
        EType::Entity@ ent = @it_pol.getEnt(ent_id);

        EType::AddTag(ent, "dieoffscreen".getHash());


        SType::CPos@ CPos = cast<SType::CPos@>(ent[0]);
        CPos.pos = pos;
        CPos.old_pos = pos;

        SType::CVelocity@ CVelocity = cast<SType::CVelocity@>(ent[1]);
        CVelocity.velocity = velocity;
        CVelocity.old_velocity = velocity;

        //cast<SType::CImage@>(ent[2]).Default();//.image = image;
        cast<SType::CHealth@>(ent[3]).health = health;


        return ent_id;
    }
}