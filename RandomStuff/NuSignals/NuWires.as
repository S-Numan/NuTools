#include "NuSignalsCommon.as";

void onInit(CRules@ rules)
{
    
}

void onTick(CRules@ rules)
{

}

bool CanBuildWire(Vec2f pos, u8 team, bool require_backwall = true)
{
    //Floor pos, then divide pos by tile size. This gets the wire position like it is a tile.
    //If require_backwall is true, check if a backwall/wall is in this tile position. Dirt does not count as a backwall.
    //Check if a wire with same team already exists in the position.
}

void BuildWire(Vec2f pos, u8 team)
{
    //Floor pos, then divide pos by tile size. This gets the wire position like it is a tile.
    //Build wire in position, with specified team. Overwrite any existing wire.
    //Call onWireBuilt
}

bool RemoveWire(Vec2f pos, u8 team)
{
    //Floor pos, then divide pos by tile size. This gets the wire position like it is a tile.
    //Check if a wire with this team is on this position, if not return false
    //If there is a wire on this pos, with this team, call onWireRemoved()
    //Remove the wire then return true.
}

void onWireBuilt()
{
    //Get the adjacent wire (of the same color?), and check what network it is connected to.
    //No adjacent wire of same color? make a new network.
    //If more than 1 wires of different networks (and same colors?) connect, have one network assimalate the others, but before that make all blobs that are connected to each assimalated network switch over networks to the new main network.

    //Get adjacent blobs where the wire was built.
    //Check if they have the SignalConnector class.
    //If they do, add to either input/output or both depending on what the bools in SignalConnector are to the SignalNetwork class.

}

void onWireRemoved()
{
    //Check network of the wire to be removed

    //Check for amount of adjacent connected wires, if there are more than 1, split the networks.
    //Splitting logic: For ease, the inital network will be removed. But before that, make new networks across every adjacent wire that was just cut off. and apply the new network to all connected blobs to those wires as well.

    //Get adjacent blobs where the wire was removed.
    //Check if they have the SignalConnector class.
    //If they do, remove it from the current network both input/output provided it is in that network.
    
    //Remove the current network.
}

//Converts all wires and blobs that are connected by the same wire, to a new network. 
void ConvertConnectedWireNetwork
{
    //Use a stack to go through every connected wire. Think maze algorithm. Unfortunately, I don't know a better way to do this. For each wire, check for adjacent blobs that are connected to the network as well. Only conver the network that is being converted.
}

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{
    //If this tile has a wire behind it
    //If the newTile does not support a wire
    //Remove each wire behind this position   
}