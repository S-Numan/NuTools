#include "NuLibCore.as";

namespace Nu
{

    //1: The point to check if it is within the radius
    //2: The center of the radius (or circle if you want to call it a circle)
    //3: The radius.
    //Returns if the point is within the radius
    shared bool isPointInRadius(Vec2f point, Vec2f radius_center, float radius)
    {
        if(Maths::Pow(point.x - radius_center.x, 2) + Maths::Pow(point.y - radius_center.y, 2) < Maths::Pow(radius, 2))
        {
            return true;
        }

        return false;
    }

    //1: Value to be rounded.
    //2: Multiple to be rounded by.
    //Rounds by the given multiple. If the multiple is 5 and the value is 277, this will return 275. If the multiple is 10 and the value is 277, this would return 280. 
    shared float RoundByMultiple(float value, float multiple = 10.0f)
    {
        if(multiple == 0) { return value; }
        return Maths::Roundf(value / multiple) * multiple;
        /*f32 rem = Maths::FMod(value, multiple);
        f32 result = value - rem;
        if (rem > (multiple / 2))
            result += multiple;
        return result;*/
    }
    shared int RoundByMultiple(int value, int multiple = 10)//Same as above but for ints.
    {
        if(multiple == 0) { return value; }
        return Maths::Round(value / multiple) * multiple;
        /*int rem = value % multiple;
        int result = value - rem;
        if (rem > (multiple / 2))
            result += multiple;
        return result;*/
    }
    //Same as above except instead of rounding up, it always rounds down.
    shared float RoundDown(float value, float multiple = 10.0f)
    {
        if(multiple == 0) { return value; }
        return value - Maths::FMod(value, multiple);
    }
    shared int RoundDown(int value, int multiple = 10)//For ints
    {
        if(multiple == 0) { return value; }
        return value - value % multiple;
    }
    shared float Floor(float value, float multiple = 10.0f)//Alias
    {
        return RoundDown(value, multiple);
    }
    shared int Floor(int value, int multiple = 10)//Alias for ints
    {
        return RoundDown(value, multiple);
    }

    //1: The first vector.
    //2: The second Vector
    //Returns a vector of two vector's x's and y's multiplied together. 
    shared Vec2f MultVec(Vec2f value1, Vec2f value2)
    {
        value1.x = value1.x * value2.x;
        value1.y = value1.y * value2.y;
        return value1;
    }

    //1: The first vector.
    //2: The second Vector
    //Returns a vector of the first vector's x and y divided by the second vector's x and y. 
    shared Vec2f DivVec(Vec2f value1, Vec2f value2)
    {
        if(value2.x == 0 || value2.y == 0) { return Vec2f(0,0); }
        value1.x = value1.x / value2.x;
        value1.y = value1.y / value2.y;
        return value1;
    }
    
    //1: Vec2f 1.
    //2: Vec2f 2.
    //Returns a float that is the distance between the two points.
    shared float getDistance(Vec2f point1, Vec2f point2)
    {
        float dis = (Maths::Pow(point1.x-point2.x,2)+Maths::Pow(point1.y-point2.y,2));
        return Maths::Sqrt(dis);
        //return getDistanceToLine(point1, point1 + Vec2f(0,1), point2);
    }

    //1: float 1.
    //2: float 2.
    //Returns a float that is the distance between the two floats.
    shared float getDistance(float value1, float value2)
    {
        float dis = Maths::Abs(value1 - value2);
        return dis;
    }
    
    //1:
    //2:
    //3:
    //Returns a fraction based on a value between a and b.
    shared f32 InvLerp(f32 a, f32 b, f32 v)
    {
        return (v - a) / ( b - a );
    }


    //1: Float for the Vec2f
    //Takes a float, and puts it in both sides of a Vec2f, then returns the Vec2f. Generally only useful if you don't want to call something twice like a config read, and also don't want to put a variable on another line.
    shared Vec2f f32ToVec2f(float value)
    {
        return Vec2f(value, value);
    }

    //1: float 1
    //2: float 2
    //3: float
    //Gets the median between 3 floats
    shared float Median(float r, float g, float b) 
    {
        return Maths::Max(Maths::Min(r, g), Maths::Min(Maths::Max(r, g), b));
    } 

}