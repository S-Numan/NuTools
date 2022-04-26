#define SERVER_ONLY

void onInit(CRules@ rules)
{
    if(!rules.hasCommandID("NuRuleScripts"))
    {
        rules.addCommandID("NuRuleScripts");
    }
    if(!rules.hasCommandID("ConfirmRulesSent"))
    {
        rules.addCommandID("ConfirmRulesSent");
    }
}