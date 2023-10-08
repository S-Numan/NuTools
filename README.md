# NuTools
Hub for many things for KAG modders to use.

## Primarily including

### The NuLib folder
This folder contains a library of various useful functions sorted into seperate files where all(most) have comments about how they work.

### Custom gamemode loading
A system that loads gamemode.cfg files with all their scripts in a custom manner.

This makes picking the gamemode.cfg file much better, allowing multiple gamemode.cfg files to mesh without hassle. The first check to find a gamemode checks by the file name, the second by the gamemode_name, and the third by whatever vanilla does. Thus, name your gamemode CTF.cfg, and set sv_gamemode to CTF and it will load that file.

This comes with a few extra systems such as a respawn system if you enable it in the gamemode.cfg file.

This also allows one to see what scripts are currently in the CRules script list, and thus be able to change the gamemode mid game.
### NuImage
NuImage, a class to make modifying and rendering images so much easier.

### NuRend.as
An easier option for quickly rendering something. Do note this is not fast at all, and should only be used for gui or debug purposes.
`RenderImage(Render::ScriptLayer layer, Nu::NuImage@ _image, Vec2f _pos)`

Include NuRend.as and use the function above. That is all one needs to render an image.