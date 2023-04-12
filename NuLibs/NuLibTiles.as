#include "NuLibCore.as"; 

namespace Nu
{
        
    //1: Point to get the tile under.
    //Returns the top of the tile under the point.
    shared f32 getTileUnderPos(Vec2f pos)
    {
        CMap@ map = getMap();	
        u16 tilesdown = 0;
        
        u32 pos_y = pos.y - pos.y % map.tilesize;//Store the y pos floored to the nearest top of a tile
        while(true)//Loop until stopped inside
        {
            if(map.tilemapheight * map.tilesize < pos_y + tilesdown * map.tilesize)//If we are checking below the map itself
            {
                break;
            }
            if(map.isTileSolid(Vec2f(pos.x, pos_y + map.tilesize * tilesdown)))//if this current point has a solid tile
            {
                return(pos_y + tilesdown * map.tilesize);//The current blobs pos plus one or more tiles down
            }
            tilesdown += 1;
        }
        return 0.0f;
    }
    //TODO, optimize
    //1.    getDistanceFromGround()
    //2.    isBelowLand(Vec2f pos)
    //3.    getLandHeightAtX(int x)
    //4     getLandYAtX(int x)
    //If the pos is below the land, do what is currently there from pos. If the pos is above the land, we done.

    //1: Regular position in world space.
    //Returns the tile position of this vector.
    shared Vec2f TilePosify(Vec2f pos)
    {
        CMap@ map = getMap();
        pos.x = Maths::Floor(pos.x) / map.tilesize;
        pos.y = Maths::Floor(pos.y) / map.tilesize;

        return pos;
    }
}