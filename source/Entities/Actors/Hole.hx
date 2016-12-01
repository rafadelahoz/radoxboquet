package;

import flixel.math.FlxRect;
import flixel.math.FlxPoint;

class Hole extends Entity
{
    var bounds : FlxRect;

    public function new(X : Float, Y : Float, World : World, Width : Int, Height : Int)
    {
        super(X, Y, World);

        makeGraphic(Width, Height, 0x10DDDDDD);
        immovable = true;

        bounds = getHitbox();
    }

    override public function destroy()
    {
        bounds.destroy();
        super.destroy();
    }

    public function surrounds(entity : Entity)
    {
        var entityBounds : FlxRect = entity.getHitbox();

        var topLeft : FlxPoint = new FlxPoint(entityBounds.left, entityBounds.top);
        var bottomRight : FlxPoint = new FlxPoint(entityBounds.right, entityBounds.bottom);

        var surrounds : Bool = bounds.containsPoint(topLeft) && bounds.containsPoint(bottomRight);

        topLeft.destroy();
        bottomRight.destroy();
        entityBounds.destroy();

        return surrounds;
    }
}
