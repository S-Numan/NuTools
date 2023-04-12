//If you want to run this script. With CommandChat, type out:
//!ras NuImageExample.as                                    // To add
//!rebuild                                                  // To rebuild
//!rrs NuImageExample.as                                    // To remove

#include "NuLibCore.as";//For NuImage and other misc.
#include "NuRend.as";//For the easy rendering.

Nu::NuImage@ image;

void onInit(CRules@ rules)
{
    if(!isClient()) { return; }

    @image = @Nu::NuImage();//Give the "image" variable a NuImage class.

    image.CreateImage("ExampleImage.png");//Image that is rendered
    
    //Other examples
    //image.CreateImage("render-name",//Assign a texture name
        //"ExampleImage.png");//Image that is rendered
    //image.CreateImage("render-name", sprite);//Feel free to copy a sprite instead
    //image.CreateImage("render-name", "");//Provided the texture render-name already exists, you can do this to give it to the NuImage class. Remember to make sure render-name actually exists.

    image.setFrameSize(Vec2f(32, 32));//Frame size in the image

    image.setFrame(3);//Frame drawn in the image

    image.setColor(SColor(255, 0, 0, 255));//Colors drawn image

    image.setZ(1.0f);//Sets the z

    image.setAngle(45.0f);//Angles the image

    //image.setScale(0.5f);//Scales the image

    //image.setCenterScale(true);//When true, scales from the center. When false, scales from the upper left.


    ProperIniting();//If you want to render images with more performance.
}

void onTick(CRules@ rules)
{
    if(!isClient()) { return; }

    //Slow but easy rendering. This should generally only be used for GUI and debugging. It is not great on performance.
    RenderImage(
        Render::layer_posthud,//Layer drawn on
        image,//Image drawn
        Vec2f(image.getFrameSize().x, 0.0f),//Position
        false);//Is drawn on the world. (false for screenpos, true for worldpos)
    //^ Seperate from "Proper rendering". E.G RenderAnImage.


    ProperTicking();//If you want to render images with more performance.
}

//That's all folks. ¯\_(ツ)_/¯
//All you need it above.









void ProperIniting()
{
    Render::addScript(Render::layer_posthud, "NuImageExample.as", "RenderAnImage", 0.0f);
}
void ProperTicking()
{
    image.Tick();//For proper rendering, remember to tick the image onTick. Otherwise the image wont update properly.

    FRAME_TIME = 0;//Reset frame time to 0 on tick.
}


f32 FRAME_TIME = 0;

void RenderAnImage(int id)
{
    FRAME_TIME += Render::getRenderDeltaTime() * getTicksASecond();//Add to FRAME_TIME.

    
    //Render::SetTransformWorldspace();
    Render::SetTransformScreenspace();//Set the rendered image to screen space.


    //Vec2f interpolated_pos = Vec2f_lerp(old_pos, current_pos, FRAME_TIME);//You lerp between the old and current pos using FRAME_TIME to get the interpolated pos.

    image.Render(Vec2f(0, 0));//Draw on pos.
}








//For easy editing.
void onReload(CRules@ rules)
{
    onInit(rules);
}