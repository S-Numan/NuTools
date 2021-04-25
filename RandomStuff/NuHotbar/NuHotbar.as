#include "NuMenuCommon.as";//For menus.
#include "NumanLib.as";//For misc usefulness.
#include "NuTextCommon.as";//For text and fonts.
#include "NuHub.as";//For hauling around menus and fonts.

void onInit( CBlob@ this )
{
    NuHub@ hub;//First we make the hub variable.
    if(!this.get("NuHub", @hub)) { error("Failed to get NuHub. Make sure NuHubLogic is before anything else that tries to use NuHUb."); return; }


}

void onTick( CBlob@ this )
{
    if(!isClient()) { return; }
    //Add hotbar to player blobs. Feel free to do this in the cfg of the blob.

}