#include "NuLib.as";
#include "ECSSystemCommon.as";
#include "ECSEntityCommon.as";

//Could one use CBitStream as a replacement to a Component class? Seems possible.
//Problem is one cannot tell the type of a class. And honestly, there should be structs.
//CBitStream is just DATA right? It's also an engine side class. It should be faster in many ways right?
//Maybe not though, as you'd need to read and write to the cbitstream very often. That might be slow?
//Would require an enum that gives the bit index to every variable in the cbitstream, so it's probably not worth it.





funcdef CType::IComponent@ GetComByType(u32);//Type

namespace CType//Component type
{
    //1. Rules
    //2. Desired component by type
    //Returns a component that is of the given type. It does this by looking through a funcdef array that contains functions with switch statements that can create types.
    CType::IComponent@ getComByType(CRules@ rules, u32 type)
    {
        CType::IComponent@ com;
        
        array<GetComByType@>@ get_com_by_type;
        if(!rules.get("com_by_type", @get_com_by_type)) { Nu::Error("Failed to get get_com_by_type."); return @null; }//Get functions

        for(u16 q = 0; q < get_com_by_type.size(); q++)
        {
            if(get_com_by_type == @null) { Nu::Error("get_com_by_type was null."); continue; }
            @com = @get_com_by_type[q](type);
            if(com != @null)//If com was found
            {
                com.setType(type);
                return @com;
            }
        }

        return @null;
    }

    funcdef void DefaultFunc(CType::IComponent@);//self

    shared interface IComponent
    {
        //void Deserialize(CBitStream@ params);
        void Default();

        u32 getType();
        void setType(u32 value);
        u32 getID();
        void setID(u32 value);
        u32 getEnt();
        void setEnt(u32 value);
    }
    //struct
    shared class Component : IComponent//Holds DATA only.
    {
        u32 id;//Stores it's own id in the pool.
        u32 type;//Stores type of class. The type is currently the hash of the class name.
        u32 ent;//Stores id of entity this component is being used by.

        //Serialize
        
        //void Deserialize(CBitStream@ params)
        //{
            
        //}

        void Default()
        {

        }
        u32 getType()
        {
            return type;
        }
        void setType(u32 value)
        {
            type = value;
        }
        u32 getID()
        {
            return id;
        }
        void setID(u32 value)
        {
            id = value;
        }
        u32 getEnt()
        {
            return ent;
        }
        void setEnt(u32 value)
        {
            ent = value;
        }
    }

    shared enum ComponentType
    {
        Nothing = 0,
        Null = 1,
        TypeCount
    }
}