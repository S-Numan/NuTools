#include "NumanLib.as";//For NuImage and other misc.
#include "NuHub.as";

Nu::NuImage@ image;

void onInit(CRules@ rules)
{
    @image = @Nu::NuImage();

    image.CreateImage("RenderExample.png");//Image that is rendered
    
    //Other examples
    //image.CreateImage("render-name",//Assign a texture name
        //"RenderExample.png");//Image that is rendered
    //image.CreateImage("render-name", sprite);//Feel free to copy a sprite instead

    image.setFrameSize(Vec2f(32, 32));//Frame size in the image

    image.setFrame(2);//Frame drawn in the image

    image.setColor(SColor(255, 255, 0, 0));//Colors drawn image (currently red)

    image.setZ(1.0f);//Sets the z

    image.setAngle(45.0f);//Angles the image

    image.setScale(0.5f);//Scales the image
}

void onTick(CRules@ rules)
{
    RenderImage(
        Render::layer_posthud,//Layer drawn on
        image,//Image drawn
        Vec2f(0.0f,0.0f),//Position
        false);//Is drawn on the world. (false for screenpos, true for worldpos)
}

//That's all folks. ¯\_(ツ)_/¯