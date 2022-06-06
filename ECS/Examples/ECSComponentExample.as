#include "ECSComponentCommon.as";
#include "NuLib.as";

namespace SType//Standard type.
{
    shared enum ComponentType
    {
        POS = CType::TypeCount,
        VELOCITY,
        HEALTH,
        IMAGE,
        TypeCount
    }

    shared CType::IComponent@ getStandardComByType(u32 type)//DO NOT USE! use CType::getComByType instead
    {
        CType::IComponent@ com;
        switch(type)
        {
            case POS:
                @com = CPos();

            break;
            case VELOCITY:
                @com = CVelocity();
            break;
            case HEALTH:
                @com = CHealth();
            break;
            case IMAGE:
                @com = CImage();
            break;

            default:
                @com = @null;
        }
        return com;
    }

    shared class CPos : CType::Component
    {
        void Default() override
        {
            pos.x = 0.0f;
            pos.y = 0.0f;
            old_pos.x = 0.0f;
            old_pos.y = 0.0f;
        }

        Vec2f pos;
        Vec2f old_pos;
    }
    namespace CPos {
        //Should be called first. At least, as first as possible
        void SystemOldPosIsNewPos(itpol::Pool@ it_pol, EType::Entity@ ent, CType::IComponent@ start_com)
        {
            SType::CPos@ CPos = cast<SType::CPos@>(start_com);//Cast it to the type desired.
            if(CPos.old_pos != CPos.pos)//If the old pos is not equal to the current pos.
            {
                CPos.old_pos = CPos.pos;//Set the old pos to the current pos.
            }
        }
    }

    shared class CVelocity : CType::Component
    {
        void Default() override
        {
            velocity.x = 0;
            velocity.y = 0;
            old_velocity.x = 0;
            old_velocity.y = 0;
        }
        Vec2f velocity;
        Vec2f old_velocity;
    }
    namespace CVelocity {
        void SystemApplyVelocity(itpol::Pool@ it_pol, EType::Entity@ ent, CType::IComponent@ start_com)
        {
            u16 CPos_pos;

            if(EType::EntityHasType(ent, SType::POS, CPos_pos))//If this entity has a POS component. Get it's position on CPos_pos.
            {
                //Entity has POS component.
                SType::CVelocity@ CVelocity = cast<SType::CVelocity@>(start_com);//Cast it to the type desired.
            
                if(CVelocity.velocity != Vec2f_zero)
                {
                    SType::CPos@ CPos = cast<SType::CPos@>(ent[CPos_pos]);//Get this component. Cast it to the type desired.
                    CPos.pos += CVelocity.velocity;
                }   
            }
        }
    }

    shared class CHealth : CType::Component
    {
        void Default() override
        {
            health = 0.0f;
        }
        f32 health;
    }
    namespace CHealth {

    }

    shared class CImage : CType::Component
    {
        CImage()
        {//Only happens on creation.
            @image = @Nu::NuImage();//Give the "image" variable a NuImage class.
        }
        void Default() override
        {
            image.CreateImage("ExampleImage.png");//Image that is rendered
            image.setFrameSize(Vec2f(32, 32));
        
            interpolate = true;
            is_world_pos = false;
        }

        Nu::NuImage@ image;
        bool interpolate;
        bool is_world_pos;
    }
    namespace CImage {
        //
        //System
        //
        NuRend@ i_rend = @null;

        bool RendInit()
        {
            if(i_rend == @null)//If we don't have i_rend
            {
                if(!getRend(@i_rend, false)) { return false; }//Try and get it
            }
            return true;//We got it if it got here
        }

        void SystemRenderImage(itpol::Pool@ it_pol, EType::Entity@ ent, CType::IComponent@ start_com)
        {
            if(!RendInit()) { return; }

            SType::CImage@ CImage = cast<SType::CImage@>(start_com);
            if(CImage.image == @null) { Nu::Error("CImage had no image. Don't let this happen please and thank you."); return; }

            if(CImage.is_world_pos)
            {
                Render::SetTransformWorldspace();
            }
            else
            {
                Render::SetTransformScreenspace();
            }

            u16 CPos_pos;

            if(EType::EntityHasType(ent, SType::POS, CPos_pos))//If this entity has a POS component. Get it's position on CPos_pos.
            {
                //Entity has POS component.
                SType::CPos@ CPos = cast<SType::CPos@>(ent[CPos_pos]);//Get this component. Cast it to the type desired.
                
                Vec2f render_pos;

                if(CImage.interpolate)//If should interpolate
                {
                    render_pos = Vec2f_lerp(CPos.old_pos, CPos.pos, i_rend.FRAME_TIME);
                }
                else//No interpolation?
                {
                    render_pos = CPos.pos;
                }
                if(CImage.image.v_raw_c) { CImage.image.CalculateVRaw(); CImage.image.v_raw_c = false; }//Terribly unoptimized, don't do this.
                
                CImage.image.Render(render_pos);
                //print("x = " + CPos.pos.x + " y = " + CPos.pos.y + " image_ent is " + image_ent + " CPos_pos is " + CPos_pos + " ");
            }
            else//Entity does not have a POS component.
            {
                CImage.image.Render();//Render anyway at position (0,0)
            }
        }
        //
        //System
        //
    }



    //Should be called last.
    void SystemTagDieOffScreen(itpol::Pool@ it_pol, EType::Entity@ ent, CType::IComponent@ start_com)
    {
        if(!EType::HasTag(ent, "dieoffscreen".getHash()))
        {
            return;
        }
        
        SType::CPos@ CPos = cast<SType::CPos@>(start_com);//Cast it to the type desired.
        if(CPos.pos.x > getScreenWidth() 
        || CPos.pos.y > getScreenHeight()
        || CPos.pos.x < 0
        || CPos.pos.y < 0 )
        {
            it_pol.RemoveEntity(ent);   
        }
    }

}