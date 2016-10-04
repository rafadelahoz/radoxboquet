package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class Entity extends FlxSprite
{
    var world : World;

    public var flat : Bool;

    var shaking : Bool;
    var shakeIntensity : Int;
    var shakeTimer : FlxTimer;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y);
        this.world = World;
        flat = false;
        shaking = false;
        shakeTimer = new FlxTimer();
    }

    override public function destroy()
    {
        world.removeEntity(this);
        super.destroy();
    }

    public function flash(?Color : Int = 0xFFFF004D, ?Duration : Float = 0.2, ?TargetColor = 0xFFFFFFFF, ?Weird : Bool = false)
    {
        color = Color;
        if (Weird)
            FlxTween.tween(this, {color: TargetColor}, Duration);
        else
            FlxTween.color(this, Duration, Color, TargetColor);
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

    public function shake(?duration : Float = 0.2, ?intensity : Int = 2)
    {
        shakeTimer.cancel();
        shaking = true;
        shakeIntensity = intensity;
        shakeTimer.start(duration, stopShake);
    }

    public function stopShake(?t:FlxTimer = null)
    {
        shakeTimer.cancel();
        shaking = false;
    }

    override public function draw()
    {
        if (shaking)
        {
            var xx : Float = x;
            var yy : Float = y;

            x += FlxG.random.int(-shakeIntensity, shakeIntensity);
            y += FlxG.random.int(-shakeIntensity, shakeIntensity);
            super.draw();
            x = xx;
            y = yy;
        }
        else
            super.draw();
    }
}
