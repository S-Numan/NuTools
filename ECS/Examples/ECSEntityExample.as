#include "ECSComponentCommon.as"

namespace EnT
{
    //Return's the entity's id.
    u32 AddEnemy(CRules@ rules, itpol::Pool@ it_pol, Vec2f pos, Vec2f velocity, f32 health)
    {
        array<u16> com_type_array = 
        {
            SType::POS,
            SType::VELOCITY,
            SType::IMAGE,
            SType::HEALTH
        };

        u32 ent_id = EType::CreateEntity(rules, it_pol, com_type_array,//Creates the entity with the specified components. Returns the entity id.
        false);//If this is true, every component will be defaulted. If this is false, components will retain their previous values. Whatever they may be.

        //Default params.
        EType::Entity@ ent = @it_pol.getEnt(ent_id);
        
        cast<SType::CPos@>(ent[0]).pos = pos;
        cast<SType::CVelocity@>(ent[1]).velocity = velocity;
        cast<SType::CImage@>(ent[2]).Default();//.image = image;
        cast<SType::CHealth@>(ent[3]).health = health;


        return ent_id;
    }
}