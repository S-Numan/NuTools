#include "ECSComponentCommon.as"

funcdef void SystemFuncs(itpol::Pool@, EType::Entity@, CType::IComponent@);//Pool

namespace SYS//System
{
    void CreateSystem(CRules@ rules, array<SystemFuncs@>@ &out sys_funcs, array<u32>@ &out sys_funcs_type, string sys_name)
    {
        @sys_funcs = array<SystemFuncs@>();
        @sys_funcs_type = array<u32>();
        rules.set(sys_name, @sys_funcs);
        rules.set(sys_name + "_type", @sys_funcs_type);
    }
    
    //TODO, test if you can add functions to a system from a different module. If it isn't possible, clarify that it isn't possible in a comment. Or even print something to the console when it's tried.
    void AddToSystem(CRules@ rules, string sys_name, SystemFuncs@ func, u32 com_type)
    {
        array<SystemFuncs@>@ sys_funcs;
        array<u32>@ sys_funcs_type;

        if(!rules.exists(sys_name)) { Nu::Error("system " + sys_name + " did not exist"); return; }
        if(!rules.exists(sys_name + "_type")) { Nu::Error("system_type " + sys_name + "_type did not exist"); return; }
        
        rules.get(sys_name, @sys_funcs);
        rules.get(sys_name + "_type", @sys_funcs_type);

        sys_funcs.push_back(func);
        sys_funcs_type.push_back(com_type);
    }

    void TickSystem(itpol::Pool@ it_pol, array<SystemFuncs@>@ sys_funcs, array<u32>@ sys_funcs_type)
    {
        u16 i;
        u16 q;
        u16 sys_funcs_size = sys_funcs.size();
        for(i = 0; i < sys_funcs_size; i++)
        {
            u16 com_type_count = it_pol.getComTypeCount(sys_funcs_type[i]);//Get the amount of components of this type

            for(q = 0; q < com_type_count; q++)//For every component of this type
            {
                u32 com_ent = it_pol.getComEnt(sys_funcs_type[i], q, false);//false for, don't print errors.
                if(com_ent == 0) { continue; }//If this component doesn't have an entity, skip it.

                EType::Entity@ ent = it_pol.getEnt(com_ent);

                sys_funcs[i](it_pol, ent, it_pol.com_array[sys_funcs_type[i]][q]);
            }
        }
    }

    array<GetComByType@>@ GetComByTypeArray(CRules@ rules)
    {
        array<GetComByType@>@ get_com_by_type;
        if(!rules.exists("com_by_type"))
        {
            @get_com_by_type = array<GetComByType@>@();
            rules.set("com_by_type", @get_com_by_type);
        }
        rules.get("com_by_type", @get_com_by_type);
        return get_com_by_type;
    }
}
//I : The system contains funcdefes for each bit of logic.
//So when you want things to be removed when no health, you give the system a funcdef that handles that.
//sys.addfunc(NoHealthDie(entity)) Something like this? Then in NoHealthDie it checks if that entity has a health component, and kills the ent on it's health reaching 0.
//Probably doesn't work between modules. Thus, cannot use.

//How about, each script that implements it's own components also implements the system logic adjacent to them. In which they get the pool themselves and do ent logic themselves too.
//Makes components not do logic in order? So that's not good. Also might be slow with having to recheck for types constantly in each file.






//Maybe require components that require other components to hold an array that contains the id of the component needed.
//And not allow the component to be added if the required component isn't in the entity. (optional? E.G if an entity has an image but no POS component, the image just draws at 0,0? Somehow?)

//Consider somehow making getting components via id's only. Somehow. Like a seperate array of handles that contains every in order by their id (don't do this. just an example).

//Perhaps re-add the Entity class, and clean up things that involve it?

funcdef void OnEntity(itpol::Pool@, EType::Entity@);//Pool, entity

namespace itpol//Item Pool
{
    class Pool
    {
        Pool()
        {
            com_array = array<array<CType::IComponent@>>();

            ent_array = array<EType::Entity@>(1, @null);//First entity is null, should never be used.
        
            on_entity_die = array<OnEntity@>();
        }

        array<array<CType::IComponent@>> com_array;

        array<EType::Entity@> ent_array;

        array<OnEntity@> on_entity_die;//Calls all functions in this array when an entity dies, provides entity dying.

        //Find open position in the ent array. Returns the ent_array size if no free positions were found.
        u32 getEntID()
        {
            //Skip first entity.
            for(u32 i = 1; i < ent_array.size(); i++)
            {
                if(ent_array[i].open)
                {
                    return i;
                }
            }

            return ent_array.size();
        }

        //Returns existing free entity. If no free entity found, makes new entity and returns it.
        EType::Entity@ NewEntity()
        {
            u32 ent_id = getEntID();//Entity id
            if(ent_id == ent_array.size())//No free position found?
            {
                EType::Entity@ ent = EType::Entity();
                ent.components = array<CType::IComponent@>();
                ent.tags = array<u32>();
                ent.id = ent_id;

                ent_array.push_back(@ent);//Create and add new entity
                ent_array[ent_id].open = false;//Entity is in use.
            }
            else//Free pos found
            {
                if(getEnt(ent_id).size() != 0) { Nu::Error("Entity has components, yet is tagged free. ent_id = " + ent_id); }

                ent_array[ent_id].open = false;//Entity is now in use.
            }

            return ent_array[ent_id];
        }

        void RemoveEntity(u32 ent_id)
        {
            if(ent_id >= ent_array.size())
            {
                Nu::Error("Attempted to reach beyond array bounds"); return;
            }
            u16 i;
            
            for(i = 0; i < on_entity_die.size(); i++)
            {
                on_entity_die[i](@this, @ent_array[ent_id]);
            }
            //Clear components in array as free to use for other entities.
            for(i = 0; i < ent_array[ent_id].size(); i++)
            {
                if(ent_array[ent_id][i] == @null) { continue; }//Skip if null
                
                u32 com_type = ent_array[ent_id][i].getType();
                u32 com_id = ent_array[ent_id][i].getID();//Fetch position of component in com_array.

                com_array[com_type][com_id].setEnt(0);//This component is free for use
            }
            ent_array[ent_id].components.resize(0);

            
            ent_array[ent_id].open = true;//This entity is free to use.
        }

        void RemoveEntity(EType::Entity@ ent)
        {
            RemoveEntity(ent.id);
        }

        //Get entity by id
        EType::Entity@ getEnt(u32 id)
        {
            if(id >= ent_array.size())
            {
                Nu::Error("Attempted to reach beyond array bounds"); return @null;
            }
            if(id == 0) { Nu::Error("Attempted to get ent 0. End 0 is reserved. Do not try getting or setting it."); return @null; }
            
            return @ent_array[id];
        }

        u32 EntCount()
        {
            return ent_array.size();
        }

        CType::IComponent@ getCom(u32 type, u32 id, bool print_error = true)
        {
            if(type >= com_array.size())
            {
                if(print_error) { Nu::Error("Attempted to reach beyond array bounds. type is " + type + " Array size is " + com_array.size()); } return @null;
            }
            if(id >= com_array[type].size())
            {
                if(print_error) { Nu::Error("Attempted to reach beyond array bounds. id is " + id + " Array size is " + com_array[type].size()); } return @null;
            }
            return com_array[type][id];
        }

        //Returns id of entity using this component. Returns 0 if this component is free.
        u32 getComEnt(u32 type, u32 id, bool print_error = true)
        {
            if(type >= com_array.size())
            {
                if(print_error) { Nu::Error("Attempted to reach beyond array bounds. type is " + type + " Array size is " + com_array.size()); } return 0;
            }
            if(id >= com_array[type].size())
            {
                if(print_error) { Nu::Error("Attempted to reach beyond array bounds. id is " + id + " Array size is " + com_array[type].size()); } return 0;
            }
            return com_array[type][id].getEnt();
        }


        u32 getComTypeCount(u32 type)
        {
            if(type >= com_array.size())
            {
                return 0;
            }
            return com_array[type].size();
        }

        u32 TotalComCount()
        {
            u32 q;
            u32 com_count = 0;
            for(u16 i = 0; i < com_array.size(); i++)//For every type
            {
                for(q = 0; q < com_array[i].size(); q++)//For every id of this type
                {
                    com_count++;//Add one to the com_count.
                }
                //Replacing com_count++ with com_count += com_array[i].size() . this might be a good idea.
            }

            return com_count;
        }

        //Finds a free component in the com_array with the given type. returns u32_max if none have been found.
        //Return's id of the component.
        u32 getFreeComByType(u32 type)
        {
            if(com_array.size() <= type) { return Nu::u32_max(); }//If the type doesn't exist.

            for(u32 id = 0; id < com_array[type].size(); id++)//For every id of this type
            {
                if(com_array[type][id].getEnt() == 0)//If this position is free
                {
                    //Found a component for use.
                    return id;//Return its id
                }
            }
            //No component found.
            return Nu::u32_max();
        }



        
        //Returns bool array that corresponds with component type array.
        //Positions that are true in this array were already found in the pool, positions that are false need to be created.
        //Assigns pre existing component(s) to the given entity(id). Returns bool array of which components were correctly added.
        array<bool> AssignByType(u32 ent_id, array<u32> com_type_array, bool default_coms = true)
        {
            u16 i;
            u32 q;
            
            array<bool> added_array = array<bool>(com_type_array.size(), false);

            EType::Entity@ ent = getEnt(ent_id);


            u16 original_ent_size = ent.size();
            u16 skip_components = 0;
            //Check for duplicates. Set com_type_array to null if duplicate.
            for(q = 0; q < original_ent_size; q++)
            {
                if(ent[q] == @null) { skip_components++; continue; }//Skip null component.

                for(i = 0; i < com_type_array.size(); i++)
                {
                    if(ent[q].getType() == com_type_array[i] && com_type_array[i] != CType::Null)//If duplicate found
                    {
                        com_type_array[i] = CType::Null;//Set to null
                        //print("duplicate tallied. " + " type was " + com_type_array[i] + " pos in ent was " + q + " TODO, remove this later. It's just to check if this feature works");
                        skip_components++;//Tally duplicate component.
                    }
                }
            }
            ent.components.resize(original_ent_size + com_type_array.size() - skip_components);


            u16 components_added = 0;
            for(i = 0; i < com_type_array.size(); i++)
            {
                if(com_type_array[i] == CType::Nothing) { Nu::Warning("com_type_array[" + i + "] was 0. as in, Nothing."); continue; }
                if(com_type_array[i] == CType::Null) { continue; }

                u32 com_id = getFreeComByType(com_type_array[i]);//Try finding a free component with this type.
                if(com_id == Nu::u32_max()) { continue; }//Skip if no free component was found.
                
                u16 com_pos = original_ent_size + i; //EType::getFreePosInEntity(ent);//Find first free pos.


                AssignByID(ent_id, com_type_array[i], com_id, com_pos, default_coms);//Assign component

                added_array[i] = true;//Component in this position successfully added.

                components_added++;//Tally another component added.
            }

            return added_array;
        }

        bool AssignByType(u32 ent_id, u32 com_type, bool default_coms = true)
        {
            //Nu::Warning("Uninplemented");

            return AssignByType(ent_id, array<u32>(1, com_type), default_coms)[0];
        }

        void UnassignByType(u32 ent_id, u32 com_type)
        {
            EType::UnassignByType(getEnt(ent_id), com_type);
        }


        //1. ent_id, the position the entity is in the pool
        //2. com_type the type the component is in the pool
        //3. com_id, the position the component is in the pool.
        //4. com_pos, the position the component goes into the component array in the entity.
        //Assign a specific existing component in pool into a specific position into a specific entity's component array.
        bool AssignByID(u32 ent_id, u32 com_type, u32 com_id, u16 com_pos, bool default_coms = true)
        {
            EType::Entity@ ent = getEnt(ent_id);//Get entity by id
            if(ent == @null) { Nu::Error("ent was null"); return false; }//Complain if the entity is null (it should never be null)

            if(com_pos == Nu::u16_max())//If com_pos is equal to u32 max value, that means something should be pushed back onto the end of the array.
            {
                com_pos = EType::getFreePosInEntity(ent);//set com_pos to be a free pos, if no free pos's, com_pos is the size of the components array
                //Resize component array if needed
                if(com_pos == ent.size())
                {
                    ent.components.resize(com_pos + 1);//Add one to size to allow it to be added.
                }
            }

            return AssignByID(ent, com_type, com_id, com_pos, default_coms);
        }

        bool AssignByID(EType::Entity@ ent, u32 com_type, u32 com_id, u16 com_pos, bool default_coms = true)
        {
            if(ent.size() <= com_pos) { Nu::Error("com_pos out of bounds. com_pos = " + com_pos); return false; }
            if(ent[com_pos] != @null) { Nu::Error("com_pos already has component. com_pos = " + com_pos); return false; }

            CType::IComponent@ com = getCom(com_type, com_id);//Get component
            if(com == @null) { Nu::Error("com was null"); return false; }//Complain if it's null. (it should never be null)

            //Check for duplicates.
            for(u16 i = 0; i < ent.size(); i++)
            {
                //If duplicate found
                if(ent[i] != @null//If the component in the entity is not null
                && ent[i].getType() == com.getType())//If it's type is equal to the component to be added
                {//Don't let there be more than 1 type in 
                    //print("duplicate found. Type was " + com.getType() + " pos was " + i + " TODO, remove this message later, this message only exists to check if preventing duplicate adding works.");
                    return false;
                }
            }

            if(default_coms)//If default_coms
            {
                com.Default();//Default this component's values.
            }
            
            @ent[com_pos] = @com;//Assign component to entity

            ent[com_pos].setEnt(ent.id);//Component is now in use.
            return true;
        }

        //Find first free position in ent.
        bool AssignByID(u32 ent_id, u32 com_type, u32 com_id, bool default_coms = true)
        {
            return AssignByID(ent_id, com_type, com_id, Nu::u16_max(), default_coms);
        }
        //Find first free position in ent.
        bool AssignByID(EType::Entity@ ent, u32 com_type, u32 com_id, bool default_coms = true)
        {
            return AssignByID(ent.id, com_type, com_id, Nu::u16_max(), default_coms);
        }

        bool AddTag(u32 ent_id, u32 tag, u16 &out tag_pos = void)
        {
            return EType::AddTag(getEnt(ent_id), tag, tag_pos);
        }
        
        bool RemoveTag(u32 ent_id, u32 tag, u16 &out tag_pos = void)
        {
            return EType::RemoveTag(getEnt(ent_id), tag, tag_pos);
        }

        bool HasTag(u32 ent_id, u32 tag, u16 &out tag_pos = void)
        {
            return EType::HasTag(getEnt(ent_id), tag, tag_pos);
        }    


        //Adds new component to com_array. Returns the component's id.
        u32 AddComponent(CType::IComponent@ com)
        {
            if(com == @null) { Nu::Error("com was null"); return Nu::u32_max(); }

            u32 type = com.getType();

            u16 com_array_size = com_array.size();

            //Add new type arrays to com_array if it does not have them and needs them.
            if(com_array_size <= type)//If the com_array does not have this type
            {
                com_array.resize(type + 1);//Resize it to fit this type in
                for(u16 i = com_array_size; i < type + 1; i++)//For every newly made array position that can hold a type.
                {
                    com_array[i] = array<CType::IComponent@>();//Give this position an empty array to start with.
                }
            }

            u32 com_id = com_array[type].size();

            com_array[type].push_back(com);//New component in type array

            com.setID(com_id);//This is where the component is in this pool.
            com.setEnt(0);//This component is free to be used.

            return com_id;//Return pos/id
        }
    
    
    }
}








/*
Convert WeaponCommon.as in goldspace to more like ecs? Entity Component system.
1. To be more like components, instead of classes that inherit each other? As in you can remove itemaim from weapon, and the weapon will still work but not have a direction it aims in.
Less overhead in uneeded things. Maybe seperate itemaim into simple aiming, and recoil, and deviation. Keep things the weapon wont use not in the class.
2. To seperate the entities, components, and systems. All the logic is functions. None of them are in a class. 
The system is for holding functions that access or modify components in entities.
Components are for holding data and have no functions. DATA only, no functions to access the data either, that goes in the system.
Entities are for holding components.


https://youtu.be/2rW7ALyHaas
*/