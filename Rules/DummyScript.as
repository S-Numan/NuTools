#include "DefaultStart.as";
#include "NuLib.as";

void onInit(CRules@ rules)
{
    rules.addCommandID("NuRuleScripts");

    if(!isServer())//Server handles their rules loading themselves.
    {
        print("Dummy rules loaded. Waiting for server to pass rules.");
        //The client just joined (most likely)
        //print("==CLIENT GAMEMODE WIPE==");
        
        //Remove all scripts in the whatever gamemode kag initially loads to the client. Don't skip NuToolsLogic.as (avoids removing this script.)
        Nu::Rules::ClearScripts(false, array<string>());//False means doesn't sync
    }
}

void onTick(CRules@ rules)
{
    print("Waiting for server to pass gamemode. DummyScript.as onTick(CRules@)", SColor(255, 0, 177, 177));
}

void onCommand(CRules@ rules, u8 cmd, CBitStream@ params)
{
    if(cmd == rules.getCommandID("NuRuleScripts"))
    {
        NuLib::NuRuleScripts(rules, params);
    }
}