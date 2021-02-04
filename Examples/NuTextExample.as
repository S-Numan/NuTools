//Set gamemode to "Testing" for this to activate.

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

    //hub.addFont("Arial.png");

    print("Text Example Creation");

    
    //NuText();
    @text_test = @NuText("Arial",//What is the text's font
        "Hello World!\n! @ # $ % ^ & * ( ) _ + } { ");//What does the text draw.

    text_test.setString(text_test.getString() + "\nNext Line!");//Get and add something to NuText's string.
    
    text_test.setIsWorldPos(true);//Is this text drawn on the world?
    
    text_test.setColor(SColor(255, 255, 0, 0));//What color is this text.
    
    text_test.setWidthCap(300.0f);//When will the text forcefuly next line to not go past this width.

    text_test.setAngle(0.0f);//What angle is the text at.
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
    
    text_test.Render(//Render the text
        Vec2f(128.0f, 128.0f),//At what position is this text drawn at.
        0);//What state is the text drawn in. (can be ignored and removed. state is a way to store details on states if desired. Most importantly used for example, what color text will be on x button state. I.E button being pressed/hovered.)
}