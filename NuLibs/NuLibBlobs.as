#include "NuLibCore.as"; 

namespace Nu
{
    //1: The blob that both has it's inventory checked, and item held.
    //2: The blob to be held by pblob.
    //3: Controls if the blob held by pblob is put in the inventory of pblob instead of dropped on the ground to make space for get_blob.
    //Takes get_blob from pblob's inventory and makes it held by pblob. 
    shared void SwitchFromInventory(CBlob@ pblob, CBlob@ get_blob, bool inventorise_held = true)
    {
        if(pblob == @null) { return; Nu::Error("pblob was null"); }
        if(get_blob == @null) { return; Nu::Error("get_blob was null"); }

        CInventory@ inv = pblob.getInventory();
        if(inv == @null) { return; }

        CBlob@ carried_blob = pblob.getCarriedBlob();

        if(!inv.isInInventory(get_blob) && @get_blob != @carried_blob) { return; }//get_blob has to either be in the inventory of pblob or be held by pblob

        if(inventorise_held && carried_blob != @null && !inv.canPutItem(carried_blob))//Supposed to put the currently not null held item in the inventory but it isn't possible?
        {
            return;//CEASE
        }

        CRules@ rules = getRules();
        CBitStream params;

        params.write_bool(inventorise_held);
        params.write_u16(pblob.getNetworkID());
        params.write_u16(get_blob.getNetworkID());

        rules.SendCommand(rules.getCommandID("switchfrominventory"), params, false);//Send command to server only
    }
    //Exact same as above, except takes a string in place of the get_blob and converts it to a blob.
    shared void SwitchFromInventory(CBlob@ pblob, string s_get_blob, bool inventorise_held = true)
    {
        CInventory@ inv = pblob.getInventory();
        if(inv == @null) { return; }

        CBlob@ get_blob = inv.getItem(s_get_blob);
        if(get_blob == @null) { return; }

        SwitchFromInventory(pblob, get_blob, inventorise_held);
    }

    //TODO, not tested
    shared CBlob@ getHolder(CBlob@ held)
    {
        if(!held.isAttached()) { return @null; }
        
        AttachmentPoint@ point = held.getAttachments().getAttachmentPointByName("PICKUP");
        if(point == @null) { return @null; }
        
        return point.getOccupied();
    }

    //Parameters
    //1: A point.
    //2: The radius around that point to get the blobs from. Any blob outside the radius will not be put in the array.
    //3: The array of blobs that are sorted.
    //4: If this array should skip both blobs in inventories, and unactive blobs. This is by default false.
    //Returns an array of blobs sorted by distance taken from the blob_array parameter. Blobs outside the radius, blobs that don't exist, and other cases will not be added to the array.
    shared array<CBlob@> SortBlobsByDistance(Vec2f point, f32 radius, array<CBlob@> blob_array, bool skip_unactive_and_inventory = false)
    {
        u16 i, j;

        array<CBlob@> sorted_array(blob_array.size());

        array<f32> blob_dist(blob_array.size());

        u16 non_null_count = 0;

        for (i = 0; i < blob_array.size(); i++)//Make an array that contains the distance that each blob is from the point.
        {
            if(blob_array[i] == @null//If the blob does not exist
            || (skip_unactive_and_inventory && (blob_array[i].isActive() == false || blob_array[i].isInInventory())))//Or skip_unactive is true and the blob is not active or in an inventory
            {
                continue;//Do not add this to the array
            }

            f32 dist = (blob_array[i].getPosition() - point).getLength();//Find the distance from the point to the blob
            
            if(dist > radius) //If the distance to the blob from the point is greater than the radius.
            {
                continue;//Do not add this to the array
            }

            @sorted_array[non_null_count] = blob_array[i];

            blob_dist[non_null_count] = dist;
            
            non_null_count++;
        }

        sorted_array.resize(non_null_count);//Resize to remove nulls
        blob_dist.resize(non_null_count);//This too. Null things don't have positions to calculate the distance between it and the point given.
        
        for (j = 1; j < non_null_count; j++)//Insertion sort each blob.
        {
            for(i = j; i > 0 && blob_dist[i] < blob_dist[i - 1]; i--)
            {
                //Swap
                float _dist = blob_dist[i - 1];
                blob_dist[i - 1] = blob_dist[i];
                blob_dist[i] = _dist;
                //Swap
                CBlob@ _blob = sorted_array[i - 1];
                @sorted_array[i - 1] = sorted_array[i];
                @sorted_array[i] = _blob;
            }
        }

        //for(i = 0; i < non_null_count; i++)
        //{
        //    print("blob_dist[" + i + "] = " + blob_dist[i]);
        //}

        return sorted_array;
    }
}