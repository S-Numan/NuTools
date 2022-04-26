//TODO, wait for command from server before LateLoadRules.

void onInit(CRules@ rules)
{
    if(!isServer())//Server handles their rules loading themselves.
    {
        //Remove all scripts in the whatever gamemode kag initially loads to the client. Don't skip NuToolsLogic.as (avoids removing this script.)
        //Nu::Rules::ClearScripts(false, array<string>(1, "DummyScript.as"));//False means doesn't sync
        
        LateLoadRules("Rules/" + "DummyGamemode2.cfg");
    }
}

void onTick(CRules@ rules)
{
    if(getGameTime() % 30 == 0)
    {
        print("Something broke. DummyScript.as", SColor(255, 0, 177, 177));
    }
}