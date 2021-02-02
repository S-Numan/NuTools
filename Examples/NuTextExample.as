#include "NuMenuCommon.as";
#include "NuTextCommon.as";

/*void onInit( CRules@ this )
{
    if(!isClient())
    {
        return;
    }

    NuHub@ hub;
    if(!this.get("NuHub", @hub)) { error("Failed to get NuHub. Make sure NuHubLogic is before anything else that tries to use it."); return; }

    hub.addFont("Arial_font.png");

    print("Text Example Creation");

    

    text_test = NuText("Arial_font");
    text_test.text = "Hello World!\n!@#$%^&*()_+}{";
}

void onReload( CRules@ this )
{
    onInit(this);
}

void onTick( CRules@ this )
{

   
}

NuText@ text_test;

void onRender(CRules@ this)
{
    text_test.Render(Vec2f(16.0f, 16.0f));
}*/