#include "NuLib.as";
#include "ECSSystemCommon.as";
#include "ECSEntityCommon.as";

//Could one use CBitStream as a replacement to a Component class? Seems possible.
//Problem is one cannot tell the type of a class. And honestly, there should be structs.
//CBitStream is just DATA right? It's also an engine side class. It should be faster in many ways right?
//Maybe not though, as you'd need to read and write to the cbitstream very often. That might be slow?
//Would require an enum that gives the bit index to every variable in the cbitstream, so it's probably not worth it.





funcdef CType::IComponent@ GetComByType(u16);//Type

namespace CType//Component type
{
    //1. Rules
    //2. Desired component by type
    //Returns a component that is of the given type. It does this by looking through a funcdef array that contains functions with switch statements that can create types.
    CType::IComponent@ getComByType(CRules@ rules, u16 type)
    {
        CType::IComponent@ com;
        
        array<GetComByType@>@ get_com_by_type;
        if(!rules.get("com_by_type", @get_com_by_type)) { Nu::Error("Failed to get get_com_by_type."); return @null; }//Get functions

        for(u16 q = 0; q < get_com_by_type.size(); q++)
        {
            @com = @get_com_by_type[q](type);
            if(com != @null)//If com was found
            {
                com.setType(type);
                return @com;
            }
        }

        return @null;
    }

    shared interface IComponent
    {
        //void Deserialize(CBitStream@ params);
        void Default();

        u16 getType();
        void setType(u16 _type);
        u32 getID();
        void setID(u32 _id);
    }
    //struct
    shared class Component : IComponent//Holds DATA only.
    {
        u32 id;//Stores it's own id in the pool.
        u16 type;//Stores type of class. The type is currently the hash of the class name.

        //Serialize
        
        //void Deserialize(CBitStream@ params)
        //{
            
        //}
        void Default()
        {
            
        }
        u16 getType()
        {
            return type;
        }
        void setType(u16 _type)
        {
            type = _type;
        }
        u32 getID()
        {
            return id;
        }
        void setID(u32 _id)
        {
            id = _id;
        }
    }
    //By the way, it would be possible to have a funcdef that calls a Default() function passing itself instead of having the Default() function in the Component itself. Would this be worthwhile?


    shared enum ComponentType
    {
        Nothing = 0,
        Null = 1,
        TypeCount
    }
}