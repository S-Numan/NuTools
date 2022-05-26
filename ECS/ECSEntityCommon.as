#include "ECSComponentCommon.as";
#include "ECSSystemCommon.as";

/*
class Enemy : Entity
{
    CPos
    CVelocity
    CHealth
    CImage
}
*/
//Would doing something like this be faster? Better? Rather than holding an array of components. Just cast the entity into the desired type, then get the components.
//I honestly don't know if this would be better.

namespace EType
{
    //1. Rules
    //2. The pool the entity is being created in
    //3. An array of every type of component to be added to this entity.
    //4. Optional, if components are defaulted on adding it to this entity. If false, the components retain their previous values. Whatever they may be.
    //Creates an entity with the given components and puts it in the given pool. Returns the entity id that was just created in that pool.
    u32 CreateEntity(CRules@ rules, itpol::Pool@ it_pol, array<u32> com_type_array, bool default_coms = true)
    {
        u32 ent_id = it_pol.NewEntity();//Create a new entity, and get it's id
        EType::Entity@ ent = it_pol.getEnt(ent_id);

        array<bool> added_array = it_pol.AssignByType(ent_id, com_type_array, default_coms);//Assign components to the entity. Return the components that failed to be assigned.

        for(u16 i = 0; i < added_array.size(); i++)
        {
            if(added_array[i]) { continue; }//If the position is free, there is no need to make anything as it already exists.
            //No component in pool. Need to make a new component.
            
            CType::IComponent@ com = CType::getComByType(rules, com_type_array[i]);

            if(com == @null) { Nu::Warning("a component with the given type " + com_type_array[i] + " was not found."); continue; }

            u32 com_id = it_pol.AddComponent(com);
            u16 com_pos = i; //getFreePosInEntity(ent);

            it_pol.AssignByID(ent_id, com_type_array[i], com_id, com_pos, default_coms);//entity id, component type, component id, position the com is placed in the entity's component array, if this com should be defaulted.
        }

        return ent_id;
    }
    
    //struct
    shared class Entity//Holds Components. Should be nothing more than an array of ids. preferably, ids that point to the component in the pool. 
    {
        u32 id;
        bool open;//Open for use?
        
        array<CType::IComponent@> components;
        array<u32> tags;

        u16 size()
        {
            return components.size();
        }

        CType::IComponent@ get_opIndex(int idx)
        {
            return @components[idx];
        }
        void set_opIndex(int idx, CType::IComponent@ com)
        {
            if(idx >= components.size()) { Nu::Error("Went beyond array bounds when assigning component to entity"); return; }
            @components[idx] = @com;
        }
    }
    
    //1. Entity
    //2. Desired type of component.
    //3. Position of the component in the entity.
    //Gets the pos of the type requested to find. returns true if found, false if not.
    shared bool EntityHasType(EType::Entity@ ent, u32 type, u16 &out pos)
    {
        u16 com_count = ent.size();
        for(u16 i = 0; i < com_count; i++)
        {
            if(ent[i] == @null) { continue; }//Skip null component
            if(ent[i].getType() == type)
            {
                pos = i;
                return true;
            }
        }
        return false;
    }
    //1. Entity
    //2. Desired type of component.
    //3. Position of the component in the entity.
    //Gets the pos of the type requested to find. returns true if all were found, false if not all were found.
    shared bool EntityHasTypes(EType::Entity@ ent, array<u32> com_type_array, array<u16> &out pos)
    {
        bool all_found = true;

        u16 type_array_size = com_type_array.size();
        pos = array<u16>(type_array_size);

        for(u16 i = 0; i < type_array_size; i++)
        {
            //Get type.
            if(!EntityHasType(ent, com_type_array[i], pos[i]))//If the entity does not have this type
            {
                pos[i] = Nu::u16_max();
                if(all_found) { all_found = false; }//all_found is false.   
            }
        }

        return all_found;
    }

    //1. Entity
    //2. Desired type of component.
    //3. Output containing handle to component.
    //Returns true if a component of the desired type was found in this entity, false if not.
    shared bool EntityGetComponent(EType::Entity@ ent, u16 com_type, CType::IComponent@ &out com)
    {
        u16 com_pos;
        if(EntityHasType(ent, com_type, com_pos))//If the entity has this type/component
        {
            @com = @ent[com_pos];//Return it.
            return true;
        }
        //Entity does not have this component
        return false;
    }

    //1. Entity
    //2. Desired components by type.
    //3. Output containing an array of component handles corresponding with com_type_array. @null if no component was found.
    //Returns true if ALL components of the desired type were found in this entity, false if not.
    shared bool EntityGetComponents(EType::Entity@ ent, array<u32> com_type_array, array<CType::IComponent@> com_array)
    {
        bool all_found = true;

        u16 type_array_size = com_type_array.size();
        com_array = array<CType::IComponent@>(type_array_size);

        for(u16 i = 0; i < type_array_size; i++)
        {
            //Get component
            if(!EntityGetComponent(ent, com_type_array[i], com_array[i]))//If this entity does not have this component
            {
                @com_array[i] = @null;
                if(all_found) { all_found = false; }//all_found is false.
            } 
        }

        return all_found;
    }


    //1. Entity
    //Returns a free u16 position in the given entity that a component can fit into. Will return the entity component array size if no free positions were found (e.g, make a free position yourself)
    shared u16 getFreePosInEntity(EType::Entity@ ent)
    {
        u16 com_count = ent.size();
        for(u16 i = 0; i < com_count; i++)
        {
            if(ent[i] == @null)
            {
                return i;
            }
        }

        return com_count;
    }


    shared bool AddTag(EType::Entity@ ent, u32 tag, u16 &out tag_pos = void)
    {
        if(HasTag(ent, tag))//If ent already has this tag.
        {
            return false;//Don't add duplicate tags
        }

        u16 tags_size = ent.tags.size();
        //Attempt to find a free tagging position
        for(u16 i = 0; i < tags_size; i++)
        {
            if(ent.tags[i] == 0)//Free tagging position?
            {
                ent.tags[i] = tag;//Assign tag.
                tag_pos = i;
                return true;//Done
            }
        }
        //No free tagging position found?
        ent.tags.push_back(tag);//Pushback tag
        tag_pos = tags_size;

        return true;
    }

    shared bool RemoveTag(EType::Entity@ ent, u32 tag, u16 &out tag_pos = void)
    {
        bool tag_exists = HasTag(ent, tag, tag_pos);
        if(tag_exists)
        {
            ent.tags[tag_pos] = 0;//Remove tag.
        }

        return tag_exists;
    }

    shared bool HasTag(EType::Entity@ ent, u32 tag, u16 &out tag_pos = void)
    {
        u16 tags_size = ent.tags.size();
        //Attempt to find tag
        for(u16 i = 0; i < tags_size; i++)
        {
            if(ent.tags[i] != tag) { continue; }//Skip if not desired tag.
            //Desired tag found
            tag_pos = i;
            return true;//Found tag
        }

        return false;//Did not find tag
    }

    shared void UnassignByType(EType::Entity@ ent, u32 com_type)
    {
        u16 com_pos;

        if(EType::EntityHasType(ent, com_type, com_pos))//If the entity has this type
        {
            ent[com_pos].setEnt(0);//component is now free for use by any other entity.
            @ent[com_pos] = @null;//Component is no longer in this entity

            //ent.removeAt(com_pos);
        }
    }
}