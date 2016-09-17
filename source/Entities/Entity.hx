package;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

class Entity extends FlxSprite
{
    var world : World;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y);
        this.world = World;
    }

    public function flash(?Color : Int = 0xFFFF004D, ?Duration : Float = 0.2)
    {
        color = Color;
        FlxTween.tween(this, {color: 0xFFFFFFFF}, Duration);
    }

    public function overlapsMap()
    {
        return overlaps(world.solids);
    }

    public function overlapsMapAt(X : Float, Y : Float)
    {
        return overlapsAt(X, Y, world.solids);
    }

    public function doSlide(me : FlxPoint, from : FlxPoint, coefficient : Float, ?bounds : Float = 24, ?friction : Int = 100)
    {
        if (from != null)
        {
            var force : FlxPoint = me;

            force.x -= from.x;
            force.y -= from.y;

            force.x = FlxMath.bound(force.x, -bounds, bounds);
            force.y = FlxMath.bound(force.y, -bounds, bounds);

            force.x *= coefficient;
            force.y *= coefficient;

            velocity.set(force.x, force.y);
            drag.set(friction, friction);
        }
    }
}
