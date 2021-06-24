#include "NuMenuCommon.as";//For menus.
#include "NumanLib.as";//For misc usefulness.
#include "NuTextCommon.as";//For text and fonts.
#include "NuHub.as";//For hauling around menus and fonts.

void onInit( CBlob@ rules )
{
    NuHub@ hub;//First we make the hub variable.
    if(!getHub(@hub)) { return; }


}

void onTick( CBlob@ rules )
{
    if(!isClient()) { return; }
    //Add hotbar to player blobs. Feel free to do this in the cfg of the blob.

}