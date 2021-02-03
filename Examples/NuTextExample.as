#include "NuMenuCommon.as";
#include "NuTextCommon.as";

void onInit( CRules@ this )
{
    if(!isClient())
    {
        return;
    }
    
    init = true;

    NuHub@ hub;
    if(!this.get("NuHub", @hub)) { error("Failed to get NuHub. Make sure NuHubLogic is before anything else that tries to use it."); return; }

    //hub.addFont("Arial_font.png");

    print("Text Example Creation");

    
    //NuText();
    @text_test = @NuText("Arial", "Hello World!\n!@#$%^&*()_+}{");
    text_test.setIsWorldPos(true);
}

void onReload( CRules@ this )
{
    onInit(this);
}

void onTick( CRules@ this )
{

   
}

NuText@ text_test;

bool init;

void onRender(CRules@ this)
{
    if(!init){ return; }//If the init has not yet happened.
    text_test.Render(Vec2f(128.0f, 128.0f));
}