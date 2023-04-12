#include "NuLibCore.as";

namespace Nu
{

    //1: The size of the image.
    //2: The size of the frame in the image
    //Returns the amount of frames in a given size.
    shared u16 getFramesInSize(Vec2f image_size, Vec2f frame_size)
    {
        Vec2f output;
        if(frame_size.x == 0 || frame_size.y == 0)
        {
            return 0;
        }

        output.x = image_size.x / frame_size.x;
        output.y = image_size.y / frame_size.y;

        return u16(output.x * output.y);
    }

    //1: The size of the image.
    //2: The size of the frame in the image
    //3: The frame you want in the image.
    //Returns the Vector of where the desired frame starts. (top left)
    shared Vec2f getFrameStart(Vec2f image_size, Vec2f frame_size, u16 desired_frame)
    {
        Vec2f frame_start = Vec2f(0,0);

        frame_start.x = frame_size.x * desired_frame % image_size.x;

        frame_start.y = int(frame_size.x * desired_frame / image_size.x) * frame_size.y;

        return frame_start;
    }

    //1: Where the frame starts
    //2: How big the frame is
    //3: Returns the end of a frame. (bottom right)
    shared Vec2f getFrameEnd(Vec2f frame_start, Vec2f frame_size)
    {
        Vec2f frame_end = frame_start + frame_size;

        return frame_end;
    }

    //1: The size of the image.
    //2: The size of the frame in the image
    //3: The frame you want in the image.
    //Returns an array of the four positions. Now in UV style! Buy now for only 19.99$ free shipping and handling.
    shared array<Vec2f> getUVFrame(Vec2f image_size, Vec2f frame_size, u16 desired_frame)
    {
        Vec2f frame_start = getFrameStart(image_size, frame_size, desired_frame);
        Vec2f frame_end = getFrameEnd(frame_start, frame_size);

        return getUVFrame(image_size, frame_start, frame_end);
    }
    //Same as above, but less user friendly. Set the frame start and end here instead of frame_size and desired frame.
    shared array<Vec2f> getUVFrame(Vec2f image_size, Vec2f frame_start, Vec2f frame_end)
    {
        Vec2f[] v_uv(4);

        frame_start.x = frame_start.x / image_size.x;
        frame_start.y = frame_start.y / image_size.y;

        frame_end.x = frame_end.x / image_size.x;
        frame_end.y = frame_end.y / image_size.y;

        v_uv[0] = Vec2f(frame_start.x,  frame_start.y   );//Top left
        v_uv[1] = Vec2f(frame_end.x,    frame_start.y   );//Top right
        v_uv[2] = Vec2f(frame_end.x,    frame_end.y     );//Bottom right
        v_uv[3] = Vec2f(frame_start.x,  frame_end.y     );//Bottom left

        return v_uv;
    }


    //1: The size of the frame
    //2: Optional extra Vec2f applied to each Vector in the returned array for ease.
    //Returns an array of the four positions (top left. top right. bottom left. bottom right.) of the frame.
    shared array<Vec2f> getFrameSizes(Vec2f &in frame_size, Vec2f &in add_to = Vec2f_zero)
    {
        Vec2f[] v_pos(4);

        v_pos[0] = add_to + Vec2f(0,                0                   );//Top left
        v_pos[1] = add_to + Vec2f(0 + frame_size.x, 0                   );//Top right
        v_pos[2] = add_to + Vec2f(0 + frame_size.x, 0 + frame_size.y    );//Bottom right
        v_pos[3] = add_to + Vec2f(0,                0 + frame_size.y    );//Bottom left

        //v_pos[0] = add_to + Vec2f(-frame_start.x,   -frame_start.y  );//Top left
        //v_pos[1] = add_to + Vec2f( frame_end.x,     -frame_start.y  );//Top right
        //v_pos[2] = add_to + Vec2f( frame_end.x,     frame_end.y     );//Bottom right
        //v_pos[3] = add_to + Vec2f(-frame_start.x,   frame_end.y     );//Bottom left

        return v_pos;
    }





    shared class NuImageExtraLight
    {
        NuImageExtraLight()
        {
            Setup();
        }

        void Setup()
        {
            if(!isClient()) { Nu::Error("NuImage was created serverside. This should not happen."); }

            frame_points = array<Vec2f>(4);
            frame_points_c = false;

            frame_center = Vec2f(0,0);
            frame_center_c = false;

            v_raw_c = false;
        }
        bool v_raw_c;

        bool frame_center_c;
        private Vec2f frame_center;//Center of frame_points
        Vec2f getFrameCenter()
        {
            if(frame_center_c)
            {
                frame_center = (getFramePoint(2) - getFramePoint(0)) / 2;
                frame_center_c = false;
            }
            return frame_center;
        }

        bool frame_points_c;
        private array<Vec2f> frame_points;//Top left, top right, bottom left, bottom right of the frame when drawn. Stretches or squishes the frame.
        const array<Vec2f>& getFramePoints()
        {
            return frame_points;
        }
        Vec2f getFramePoint(u8 value)
        {
            return getFramePoints()[value];
        }
        
        void setPointUpperLeft(Vec2f value)
        {
            frame_points[0] = value;//Top left
            frame_points[1].y = value.y;//Top right
            frame_points[3].x = value.x;//Bottom left
        
            if(!frame_center_c) { frame_center_c = true; }
            v_raw_c = true;
        }
        void setPointLowerRight(Vec2f value)
        {
            frame_points[1].x = value.x;//Top right
            frame_points[2] = value;//Bottom right
            frame_points[3].y = value.y;//Bottom left

            if(!frame_center_c) { frame_center_c = true; }
            v_raw_c = true;
        }
        void setFramePoints(array<Vec2f> &in _frame_points, bool calculate = true)
        {
            frame_points = _frame_points;

            if(!frame_center_c) { frame_center_c = true; }
            v_raw_c = true;
        }

        //This creates a texture and/or sets up a few things for this image to work with it.
        void CreateImage(string &in render_name, string &in file_path)
        {
            //ensure texture for our use exists
            if(!Texture::exists(render_name))
            {
                if(!Texture::createFromFile(render_name, file_path))
                {
                    warn("texture creation failed");
                    return;
                }
            }

            SetImage(Texture::data(render_name));
        }
        void SetImage(ImageData@ _image)
        {
            if(_image == @null) { error("image was null for some reason in NuLib::NuImage::SetImage"); return; }
            if(_image.size() == 0) { warning("Image provided in NuLib::NuImage::SetImage was 0 in size"); return; }

            setFramePoints(Nu::getFrameSizes(Vec2f(_image.width(), _image.height())));
        }
        void CreateImage(string &in render_name, ImageData@ _image)
        {
            if(_image.size() == 0) { warning("Image provided in NuLib::NuImage::CreateImage was 0 in size"); return; }

            if(!Texture::exists(render_name))
            {
                if(!Texture::createFromData(render_name, _image))
                {
                    warn("texture creation failed");
                    return;
                }
            }

            SetImage(Texture::data(render_name));
        }
        void CreateImage(string &in file_path)//Takes just a file path.
        {
            string file_name = Nu::CutOutFileName(file_path);//Cuts out the file name.
            file_name = "a_" + file_name;//a for auto is placed in the render name, in an attempt to avoid accidently using the render name somebody else is using by accident. 
            CreateImage(file_name, file_path);//Uses the file_name as the render_name, and the file path as is.
        }
        //Nothing is just a literal white pixel.
        void CreateImage()
        { 
            //return @CreateImage("white_pixel", "WhitePixel.png");
            
            if(!Texture::exists("white_pixel"))
            {
                ImageData@ white_pixel = @ImageData(1,1);//Make 1,1 sized image.
                white_pixel.put(0, 0, SColor(255, 255, 255, 255));//Make the pixel white
                if(!Texture::createFromData("white_pixel", white_pixel))//Make the white pixel a texture.
                {
                    warn("texture creation failure");
                }
            }
            SetImage(Texture::data("white_pixel"));
        }
    }

    //Use NuImageAnimated instead if you are planning on changing frames somewhat frequently.
    shared class NuImage : NuImageExtraLight
    {
        NuImage()
        {

        }
        //TODO, make constructor that let's you put CreateImage stuff in straight away.

        void Setup()
        {
            NuImageExtraLight::Setup();

            frame = 0;
            Vec2f offset = Vec2f(0,0);

            v_raw = array<Vertex>(4);
            frame_uv = array<Vec2f>(4);
            frame_uv_c = false;
            z = array<float>(4, 0.0f);
            center_scale = false;
            scale = Vec2f(1.0f, 1.0f);
            would_crash = false;
            angle = 0.0f;
            //rotate_around = Vec2f(0,0);
            color = SColor(255, 255, 255, 255);

            frame_size = Vec2f(0,0);
            image_size = Vec2f(0,0);
            max_frames = 0;
            max_frames_c = false;

            name = "";
            name_id = 0;

            is_texture = false;
        }

        bool is_texture;//Has this been given a texture?

        u16 name_id;//Used for keeping track of what image is what image. For when using several NuImages in one array for example. Loop through the array and compare enums to this.
        //Todo - replace name_id with a string name and hash?

        string name;//Either file name, or texture name.

        //Overrides
        //
            const array<Vec2f>& getFramePoints() override
            {
                if(frame_points_c)
                {
                    frame_points = Nu::getFrameSizes(frame_size);
                    frame_center_c = true;
                    frame_points_c = false;
                }
                return frame_points;
            }
            
            void SetImage(ImageData@ _image) override
            {
                if(_image == @null) { error("image was null for some reason in NuLib::NuImage::SetImage"); return; }
                if(_image.size() == 0) { warning("Image provided in NuLib::NuImage::SetImage was 0 in size"); return; }

                setImageSize(_image.width(), _image.height());
                setFrameSize(image_size);

                is_texture = true;
            }

            void CreateImage(string &in render_name, string &in file_path) override
            {
                NuImageExtraLight::CreateImage(render_name, file_path);

                name = render_name;
            }

            void CreateImage(string &in render_name, ImageData@ _image) override
            {
                NuImageExtraLight::CreateImage(render_name, _image);

                name = render_name;
            }

            void CreateImage() override
            { 
                NuImageExtraLight::CreateImage();
                
                name = "white_pixel";
            }
        //
        //Overrides

        /*//tex returns null for some reason
        ImageData@ CreateImage(string render_name, CSprite@ s)//Takes a sprite instead.
        {
            if(Texture::exists(render_name)){ print("texture " + render_name + " already exists"); }
            if(s == @null){ Nu::Error("Sprite was equal to null"); return @null; }
            
            ImageData@ tex = @Texture::dataFromSprite(@s);//Get the sprite data.//This returns null for some reason
            if(tex == @null){ Nu::Error("ImageData@ tex was somehow null?"); return @null; }
            
            Texture::createFromData(render_name, tex);//Create a texture from it.
            return @CreateImage(render_name);//Give this menu the texture.
        }*/
        void CreateImage(string &in render_name, CSprite@ s)//Takes a sprite instead.
        {
            if(s == @null){ Nu::Error("Sprite was equal to null"); return; }

            CreateImage(render_name, s.getFilename());//Give this menu the texture.

            setFrame(s.getFrame());

            setFrameSize(Vec2f(s.getFrameWidth(), s.getFrameHeight()));
        }


        private SColor color;
        void setColor(SColor _color)//Sets the color
        {
            color = _color;

            v_raw_c = true;
        }
        void setColor(u8 alpha, u8 red, u8 green, u8 blue)//Sets the color
        {
            setColor(SColor(alpha, red, green, blue));
        }
        SColor getColor()
        {
            return color;
        }

        bool frame_uv_c;
        private array<Vec2f> frame_uv;//TODO, make this an array of arrays, and only use the first array in NuImageLight. Then make it 4 arrays in NuImage.
        const array<Vec2f>& getFrameUV()
        {
            if(!is_texture) { Nu::Error("texture not initialized in NuImage. Have you tried calling CreateImage?"); frame_uv_c = false; }

            if(frame_uv_c)
            {
                frame_uv = Nu::getUVFrame(getImageSize(), getFrameSize(), getFrame());

                frame_uv_c = false;
            }
            return frame_uv;
        }
        void setFrameUV(array<Vec2f> &in _frame_uv)
        {
            frame_uv = _frame_uv;
            frame_uv_c = false;
        }

        bool max_frames_c;
        private u16 max_frames;
        u16 getMaxFrames()
        {
            if(max_frames_c)
            {
                max_frames = getFramesInSize(getImageSize(), getFrameSize());
            
                max_frames_c = false;
            }
            return max_frames;
        }

        private u16 frame;
        void setFrame(u16 value, bool get_uv = true)//Sets the frame
        {
            if(value >= getMaxFrames() && is_texture)//If the frame goes beyond max_frames.
            {
                if(max_frames == 0) { Nu::Error("Max frames was 0 on attempt to setFrame in NuImage to frame " + value); return; }
                value = value % max_frames;
            }
            frame = value;
            
            if(get_uv)
            {
                frame_uv_c = true;
            }
            v_raw_c = true;
        }
        u16 getFrame()//Sets the frame
        {
            return frame;
        }

        private Vec2f image_size;//Size of the image given.
        void setImageSize(Vec2f &in value)
        {
            setImageSize(value.x, value.y);
        }
        void setImageSize(f32 x, f32 y)
        {
            image_size.x = x;
            image_size.y = y;

            if(!max_frames_c) { max_frames_c = true; }
            
            setFrame(getFrame());//Confirm this frame still works.
        }
        Vec2f getImageSize()
        {
            return image_size;
        }

        private Vec2f frame_size;//The frame size of the icon. (for choosing different frames);
        //1. Frame size to be set.
        //2. Optional, if true, will reset the frame points on changing the frame size to fit the frame size. If false, frame_points remain unchanged.
        void setFrameSize(Vec2f &in value, bool calculate = true)//Sets the frame size of the frame in the image.
        {
            if(frame_size == value)
            {
                return;
            }

            frame_size = value;
            
            if(calculate) { frame_points_c = true; }

            max_frames_c = true;
            frame_center_c = true;

            setFrame(getFrame());//Confirm this frame still works
        }
        Vec2f getFrameSize()//Gets the frame size in the image.
        {
            return frame_size;
        }
        
        private Vec2f offset;//Position of image in relation to something else. This is modified by scale. (Bug Numan if you think that's bad)
        void setOffset(Vec2f &in value)
        {
            offset = value;

            if(!v_raw_c) { v_raw_c = true; }
        }
        Vec2f getOffset()
        {
            return offset;
        }

        private array<f32> z;//The z level this is drawn on.
        void setZ(f32 value)
        {
            for(u8 i = 0; i < z.size(); i++)
            {
                z[i] = value;
            }

            if(!v_raw_c) { v_raw_c = true; }
        }
        const array<f32>& getZ()
        {
            return z;
        }
        void setZAt(u8 element, f32 value)
        {
            z[element] = value;

            if(!v_raw_c) { v_raw_c = true; }
        }
        f32 getZAt(u8 value)
        {
            return z[value];
        }

        //private Vec2f rotate_around;//Doesn't work.
        private f32 angle;
        void setAngle(f32 value)//, Vec2f around)
        {
            while(value < 0)//While the value is negative
            {
                value += 360;//Add a full circle
            }
            angle = value % 360;//Angle equals value and the values stays within 360

            //rotate_around = around;

            if(!v_raw_c) { v_raw_c = true; }
        }
        //void setAngle(float value)
        //{
        //    setAngle(value, frame_center);
        //}
        f32 getAngle()
        {
            return angle;
        }

        

        private bool center_scale;//When this is true, this image scales from the center (expands/shrinks equally from all sides).
        //When this is false, this image scales from the top left. Thus, the top left stays to the top left. (bottom right expands/shrinks outwards)

        void setCenterScale(bool value)
        {
            center_scale = value;
            
            if(!v_raw_c) { v_raw_c = true; }
        }

        bool getCenterScale()
        {
            return center_scale;
        }

        private Vec2f scale;//Scale of the frame.
        void setScale(Vec2f _scale)//Sets the scale of the frame
        {
            scale = _scale;

            if(!v_raw_c) { v_raw_c = true; }
            //TODO, implement.
        }
        void setScale(f32 _scale)//Sets the scale of the frame.
        {
            setScale(Vec2f(_scale, _scale));
        }
        Vec2f getScale()//Gets the scale of the frame.
        {
            return scale;
        }

        bool would_crash;

        //TODO, figure out if you can render more than 4 Vertices at once.
        //If possible, make it possible to have multiple frames to be drawn at once, with their seperate positions and colors. With only one render call.
        private array<Vertex> v_raw;//For rendering.
        const array<Vertex>& getVRaw()
        {
            if(!is_texture) { Nu::Error("texture not initialized in NuImage. Have you tried calling CreateImage?"); v_raw_c = false; }

            if(v_raw_c)
            {
                CalculateVRaw();
            
                v_raw_c = false;
            }
            return v_raw;
        }

        void CalculateVRaw()
        {
            if(!getVertices(
                getFrameUV(), getFramePoints(),
                getZ(), getFrameCenter(), getOffset(), getAngle(), getColor()
                , v_raw, would_crash))
            {
                would_crash = true;
            }
        }

        //This should be done as soon to before Render() as possible. Anything changed in NuImage after this will not be applied until the next tick.
        void Tick()//Maybe rename to update?
        {
            if(v_raw_c)
            {
                CalculateVRaw();
                v_raw_c = false;
            }
        }

        void Render(Vec2f &in pos = Vec2f(0,0))
        {
            if(v_raw_c)//Would be more optimized to do this check at the end of every Tick instead of onRender().
            {
                Nu::Error("v_raw_c was true in NuImage::Render. Might need NuImage.Tick() in onTick. (need to call CalculateVRaw as you changed something in this NuImage)");
                v_raw_c = false;
            }

            u16 v_raw_size = v_raw.size();
            u16 i;

            for(i = 0; i < v_raw_size; i++)
            {
                v_raw[i].x += pos.x;
                v_raw[i].y += pos.y;
            }

            Render::RawQuads(name, v_raw);
        
            for(i = 0; i < v_raw_size; i++)//TODO, figure out how to only apply changes in position, not have to unapply positions.
            {//Maybe have an old_pos Vec2f, (no need for a pos Vec2f), it's a parameter
                v_raw[i].x -= pos.x;
                v_raw[i].y -= pos.y;
            }
        }
        

    }


    shared class NuImageAnimated : NuImage
    {
        NuImageAnimated()
        {
            
        }

        void Setup()
        {
            NuImage::Setup();

        }

        private array<array<Vec2f>> uv_per_frame;//The uv's required for each frame in the given image.

        const array<array<Vec2f>>& getFrameUVs()
        {
            if(frame_uv_c)
            {
                array<array<Vec2f>> _uv_per_frame(getMaxFrames());

                u16 i;
                for(i = 0; i < _uv_per_frame.size(); i++)
                {
                    _uv_per_frame[i] = Nu::getUVFrame(getImageSize(), getFrameSize(), i);
                }

                uv_per_frame = _uv_per_frame;
                
                if(!v_raw_c) { v_raw_c = true; }

                frame_uv_c = false;
            }
            return uv_per_frame;
        }
        //const array<Vec2f>& getFrameUV(u16 frame)
        //{
        //    return getFrameUVs()[frame];
        //}
        void setFrameUVs(array<array<Vec2f>>& _uv_per_frame)
        {
            uv_per_frame = _uv_per_frame;
            frame_uv_c = false;
        }

        //Overrides
        //
            void setFrame(u16 value, bool get_uv = true) override
            {
                NuImage::setFrame(value, false);//Don't touch the uv
            }

            const array<Vec2f>& getFrameUV() override
            {
                Nu::Error("array<Vec2f> getFrameUV() is not for use in the inherited class NuImage");
                return frame_uv;
            }

            void CalculateVRaw() override
            {
                if(!getVertices(
                    getFrameUVs()[getFrame()], getFramePoints(),
                    getZ(), getFrameCenter(), getOffset(), getAngle(), getColor()
                    , v_raw, would_crash))
                {
                    would_crash = true;
                }
            }
        //
        //Overrides
    }

    //Gets vertices to be rendered.
    shared bool getVertices(
        const array<Vec2f> &in frame_uv, array<Vec2f> &in frame_points,
        const array<f32> &in z,
        const Vec2f &in frame_center,// const Vec2f &in rotate_around,
        const Vec2f &in offset, const f32 &in angle, const SColor &in color,
        array<Vertex> &inout v_raw, bool &in stop_if_crash = false)
    {
        if(stop_if_crash){ return false; }//Already sent the error log, this could of crashed. So just stop to not spam.
        if(frame_points.size() == 0) { return false; Nu::Error("frame_points.size() was equal to 0"); }
        if(frame_uv.size() == 0) { return false; Nu::Error("frame_uv.size() was equal to 0"); }
        
        Vec2f _offset = offset;

        v_raw[0] = Vertex(_offset + 
            (frame_points[0]//XY
            ).RotateByDegrees(angle, frame_center), z[0], frame_uv[0], color);
        
        v_raw[1] = Vertex(_offset +
            Vec2f(frame_points[1].x,//X
                frame_points[1].y//Y
            ).RotateByDegrees(angle, frame_center), z[1], frame_uv[1], color);//Set the colors yourself.
        
        v_raw[2] = Vertex(_offset +
            (frame_points[2]//XY
            ).RotateByDegrees(angle, frame_center), z[2], frame_uv[2], color);
        
        v_raw[3] = Vertex(_offset +
            Vec2f(frame_points[3].x,//X
                frame_points[3].y//Y
            ).RotateByDegrees(angle, frame_center), z[3], frame_uv[3], color);

        return true;
    }

    //Gets vertices to be rendered.
    shared bool getVertices(
        const array<Vec2f> &in frame_uv, array<Vec2f> &in frame_points,
        const array<f32> &in z,
        Vec2f &in offset, const SColor &in color,
        array<Vertex> &inout v_raw, bool &in stop_if_crash = false)
    {
        if(stop_if_crash){ return false; }//Already sent the error log, this could of crashed. So just stop to not spam.
        if(frame_points.size() == 0) { return false; Nu::Error("frame_points.size() was equal to 0"); }
        if(frame_uv.size() == 0) { return false; Nu::Error("frame_uv.size() was equal to 0"); }

        v_raw[0] = Vertex(offset + frame_points[0]
            , z[0], frame_uv[0], color);
        
        v_raw[1] = Vertex(offset + frame_points[1]
            , z[1], frame_uv[1], color);//Set the colors yourself.
        
        v_raw[2] = Vertex(offset + frame_points[2]
            , z[2], frame_uv[2], color);
        
        v_raw[3] = Vertex(offset + frame_points[3]
            , z[3], frame_uv[3], color);

        return true;
    }

    //Gets vertices to be rendered.
    shared bool getVertices(
        array<Vec2f> &in frame_points,
        Vec2f &in offset, const SColor &in color,
        array<Vertex> &inout v_raw, bool &in stop_if_crash = false)
    {
        if(stop_if_crash){ return false; }//Already sent the error log, this could of crashed. So just stop to not spam.
        if(frame_points.size() == 0) { return false; Nu::Error("frame_points.size() was equal to 0"); }

        //Top left
        v_raw[0] = Vertex(offset.x + frame_points[0].x, offset.y + frame_points[0].y
            , 0.0f, 0, 0,
            color);
        
        //Top right
        v_raw[1] = Vertex(offset.x + frame_points[1].x, offset.y + frame_points[1].y
            , 0.0f, 1, 0,
            color);//Set the colors yourself.
        
        //Bottom right
        v_raw[2] = Vertex(offset.x + frame_points[2].x, offset.y + frame_points[2].y
            , 0.0f, 1, 1,
            color);
        
        //bottom left
        v_raw[3] = Vertex(offset.x + frame_points[3].x, offset.y + frame_points[3].y
            , 0.0f, 0, 1,
            color);

        return true;
    }
}