#include "NumanLib.as";
#include "NuSignalsCommon.as";
#include "NuHub.as";

void onInit(CBlob@ blob)
{

}

void onTick(CBlob@ blob)
{
    NuHub@ hub;
    if(!rules.get("NuHub", @hub)) { Nu::Error("Failed to get NuHub. Make sure NuHubLogic is before anything else that tries to use it."); return; }
}

void onRender(CBlob@ blob)
{

}