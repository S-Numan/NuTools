//This file handles misc logic and rendering related things in this mod. This file should go before all other files that use NuHub in gamemode.cfg.
//TODO, swap the sending command system from CRules to a single NuTools blob. The command will only send to the blob and cause less max commands issues and be more performant hopfully. Use a method to send a command.

#include "NuMenuCommon.as";
#include "NuTextCommon.as";
#include "NuHub.as";
#include "NuToolsRendering.as";

bool init;
NuHub@ hub;

void onInit( CRules@ rules )//First time start only.
{
    @hub = @LoadStuff(rules);
    
    if(isClient())
    {
        hub.SetupRendering();
    }

    NumanLib::onInit(rules);
}

NuHub@ LoadStuff( CRules@ rules)//Every reload and restart
{
    //NuMenu::addMenuToList(buttonhere);//Add buttons like this
    NuHub@ _hub = NuHub();

    rules.set("NuHub", @_hub);
    
    print("NuHub Loaded");

    if(isClient())
    {
        NuRender::onInit(rules, _hub);

        NuMenu::onInit(rules, _hub);

        addFonts(rules, _hub);
    }
    

    if(!init &&//First time init.
        sv_gamemode == "Testing")//Provided the gamemode name is Testing.
    {
        print("=====NuButton.as attempt to add=====");
        rules.AddScript("NuButton.as");//Add the NuButton script to the gamemode.
        print("=====If an error is above, ignore it.=====");
    }

    init = true;

    return @_hub;
}

void onReload( CRules@ rules )
{
    LoadStuff(rules);
}

void onRestart( CRules@ rules)
{
    NumanLib::onRestart(rules);
}

void onTick( CRules@ rules )
{
    NuRender::onTick(rules);

    NuMenu::MenuTick();//Run logic for the menus.
}

void onRender( CRules@ rules )
{
    if(!init) { return; }//Kag renders before onInit. Stop this.

    NuRender::onRender(rules);

    NumanLib::onRender(rules);
}





void addFonts( CRules@ rules, NuHub@ hub)
{
    hub.addFont("Arial", "Arial.png");
    hub.addFont("Calibri", "Calibri-48.png");
    hub.addFont("Calibri-Bold", "Calibri-48-Bold.png");
}





void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
{
    NumanLib::onCommand(rules, cmd, params);
}

namespace NumanLib
{
    void onInit(CRules@ rules)
    {
        rules.addCommandID("clientmessage");
        rules.addCommandID("teleport");
        rules.addCommandID("enginemessage");
        rules.addCommandID("announcement");
        rules.addCommandID("switchfrominventory");

    }

    void onRestart(CRules@ rules)
    {
        rules.set_u32("announcementtime", 0);
    }


    void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
    {
        if(cmd == rules.getCommandID("switchfrominventory"))
        {
            if(!isServer()) { return; }

            bool inventorise_held;
            u16 blob_id;
            u16 getblob_id;

            if(!params.saferead_bool(inventorise_held)) { Nu::Error("bool get was null"); return; }
            if(!params.saferead_u16(blob_id)) { Nu::Error("ID get was null"); return; }
            if(!params.saferead_u16(getblob_id)) { Nu::Error("ID get was null"); return; }

            CBlob@ pblob = getBlobByNetworkID(blob_id);
            if(pblob == @null) { return; }

            CInventory@ inv = pblob.getInventory();
            if(inv == @null) { return; }

            CBlob@ getblob = getBlobByNetworkID(getblob_id);
            if(getblob == @null) { return; }

            CBlob@ carried_blob = pblob.getCarriedBlob();

            if(!inv.isInInventory(getblob) && @getblob != @carried_blob) { return; }//If getblob is not in pblob's inventory or being held by pblob
            
            if(carried_blob != @null)
            {
                if(inventorise_held)//Supposed to put the currently held item in the inventory?
                {
                    if(!inv.canPutItem(carried_blob))//If it can't be put in the inventory
                    {
                        return;//CEASE
                    }
                    else//It is possible?
                    {
                        if(!pblob.server_PutInInventory(carried_blob)) { Nu::Error("Failed to put blob in inventory."); return; }//Put it in
                    }
                    
                    //if(carried_blob.getName() == getblob.getName())//If the getblob is the same type as the carried_blob
                    if(@carried_blob == @getblob)//If the getblob is the exact same blob
                    {
                        return;//Do nothing more.
                    }
                }
                else//No inventorizing
                {
                    pblob.DropCarried();//Just drop it
                }
            }
            //From this point onwards, pblob is no longer holding a blob. 

            
            if(!pblob.server_PutOutInventory(getblob)) { Nu::Error("Failed to put blob out inventory."); return; }//Take it out

            if(!pblob.server_Pickup(getblob)) { Nu::Error("Failed to pickup blob taken out of inventory."); return; }//Pick it up

            //Mission success
        }
        else if(cmd == rules.getCommandID("clientmessage") )//sends message to a specified client
        {
            if(!isClient()) { return; }

            string text = params.read_string();
            u8 alpha = params.read_u8();
            u8 red = params.read_u8();
            u8 green = params.read_u8();
            u8 blue = params.read_u8();

            client_AddToChat(text, SColor(alpha, red, green, blue));//Color of the text
        }
        else if(cmd == rules.getCommandID("teleport") )//teleports player to position
        {
            CPlayer@ target_player = getPlayerByNetworkId(params.read_u16());//Player 1
            
            if(target_player == @null) { return; }

            CBlob@ target_blob = target_player.getBlob();
            if(target_blob != @null)
            {
                Vec2f pos = params.read_Vec2f();
                target_blob.setPosition(pos);
                ParticleZombieLightning(pos);
            }	
        }
        else if(cmd == rules.getCommandID("enginemessage") )
        {
            if(!isClient()) { return; }
            string text = params.read_string();
            EngineMessage(text);
        }
        else if(cmd == rules.getCommandID("announcement"))
        {
            rules.set_string("announcement", params.read_string());
            rules.set_u32("announcementtime",30 * 15 + getGameTime());//15 seconds
        }
    }


    void onRender(CRules@ rules)
    {
        GUI::SetFont("menu");

        CPlayer@ localplayer = getLocalPlayer();
        if(localplayer == @null)
        {
            return;
        }

        if(rules.get_u32("announcementtime") > getGameTime())
        {
            GUI::DrawTextCentered(rules.get_string("announcement"), Vec2f(getScreenWidth()/2,getScreenHeight()/2), SColor(255,255,127,60));
        }
    }

}