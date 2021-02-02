#include "NuMenuCommon.as";
#include "NuTextCommon.as";

void onInit( CRules@ this )
{
    if(!isClient())
    {
        return;
    }

    CMenuTransporter@ transporter;
    if(!this.get("NuMenus", @transporter)) { error("Failed to get NuMenus. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return; }

    print("Text Example Creation");
}

void onReload( CRules@ this )
{
    onInit(this);
}

void onTick( CRules@ this )
{
    CMenuTransporter@ transporter;
    if(!this.get("NuMenus", @transporter)) { error("Failed to get NuMenus. Make sure NuMenuCommonLogic is before anything else that tries to use the built in NuMenus array."); return; }
   
}

NuText@ text_test = NuText("Arial_font.png");

void onRender(CRules@ this)
{
    text_test.Render(Vec2f(16.0f, 16.0f));
}