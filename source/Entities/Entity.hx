package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class Entity extends FlxSprite
{
    var world : World;

    public var flat : Bool;
    public var floating : Bool;

    var shaking : Bool;
    var shakeIntensity : Int;
    var shakeTimer : FlxTimer;

    var fallingTween : FlxTween;
    public var falling : Bool;

    public var flammable : Bool;
    public var fuelComponent : IFuelComponent;
    public var currentFlame : Flame;
    public var heat : Int;
    var FlameThreshold : Int;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y);
        this.world = World;
        flat = false;
        floating = false;
        shaking = false;
        shakeTimer = new FlxTimer();

        falling = false;
        fallingTween = null;

        flammable = false;
        currentFlame = null;
        heat = 0;
        FlameThreshold = 100;
    }

    public function onInit()
    {
        // override me!
    }

    override public function destroy()
    {
        if (currentFlame != null)
            currentFlame.destroy();
        world.removeEntity(this);
        super.destroy();
    }

    override public function update(elapsed : Float)
    {
        if (falling)
        {
            velocity.set();
            acceleration.set();
        }

        if (alive)
            super.update(elapsed);
    }

    public function flash(?Color : Int = 0xFFFF004D, ?Duration : Float = 0.2, ?TargetColor = 0xFFFFFFFF, ?Weird : Bool = false)
    {
        color = Color;
        if (Weird)
            FlxTween.tween(this, {color: TargetColor}, Duration);
        else
            FlxTween.color(this, Duration, Color, TargetColor);
    }

    public function overlapsMap(?ignoreHoles : Null<Bool> = null)
    {
        var checkHoles : Bool = true;
        if (ignoreHoles != null)
            checkHoles = !ignoreHoles;
        else
            checkHoles = !floating;

        return overlaps(world.solids) || (checkHoles && overlaps(world.holes));
    }

    public function overlapsMapAt(X : Float, Y : Float, ?ignoreHoles : Null<Bool> = null)
    {
        var checkHoles : Bool = true;
        if (ignoreHoles != null)
            checkHoles = !ignoreHoles;
        else
            checkHoles = !floating;

        return overlapsAt(X, Y, world.solids) || (checkHoles && overlapsAt(X, Y, world.holes));
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

    public function onFall(where : Hole)
    {
        if (floating)
        {
            trace("Floating entity " + this + " was ordered to fall?");
            return;
        }

        if (!falling)
        {
            falling = true;
            solid = false;
            velocity.set();
            acceleration.set();
            drag.set(100, 100);
            fallingTween = FlxTween.tween(this.scale, {x: 0, y: 0}, 1, {startDelay: 0.25,
                onStart: function(t:FlxTween) {
                    playSfx("fall");
                },
                onComplete: function(t:FlxTween) {
                    fallingTween.destroy();
                    kill();
                    destroy();
                }
            });
        }
    }

    /** Fire related operations **/

    public function onHeat(by : Flame)
    {
        if (flammable)
        {
            heat += by.heatPower;
            if (heat > FlameThreshold)
            {
                onFireStart(by);
            }
        }
    }

    public function onFireStart(by : Flame)
    {
        currentFlame = new Flame(this);
        world.addEntity(currentFlame);
    }

    public function onFuelDepleted()
    {
        flammable = false;
        currentFlame.extinguish();
        currentFlame = null;
        fuelComponent = null;
    }

    public function getFlamePosition() : FlxPoint
    {
        var position : FlxPoint = getMidpoint();
        position.y += height/2;
        return position;
    }

    public function setFlammable(?Fuel : Int = 600)
    {
        if (!flammable)
        {
            flammable = true;
            FlameThreshold = 100;
            heat = 0;
            fuelComponent = new FuelCanisterComponent(this, Fuel);
        }
    }

    /* Instance based Utilities */

    public function playSfx(sound : String, ?usePosition : Bool = true)
    {
        if (usePosition)
        {
            var snd : FlxSound = FlxG.sound.play("assets/sounds/" + sound + ".ogg", 0);
            var midpoint : FlxPoint = getMidpoint();
        	snd.proximity(midpoint.x, midpoint.y, world.player, 100);
            snd.fadeIn(0.2, 0, 1);
        }
        else
        {
            FlxG.sound.play("assets/sounds/" + sound + ".ogg");
        }
    }

    /** Static methods and utilities **/

    // returns value randomized by +/- 30%
    static function widenFloat(value : Float, ?range : Float = 0.3) : Float
    {
        return value + FlxG.random.float(- value * range, value * range);
    }

    // returns value +/- range, avoiding closest values
    static function range(value : Float, width : Int) : Float
    {
        // Avoid the closest half of the range values
        var delta : Int = 0;
        while (Math.abs(delta) < width/2)
            delta = FlxG.random.int(-width, width);

        return value + delta;
    }

    // Returns true if entity will overlap a solid using current velocity in this step
    function willMeetSolid(elapsed : Float) : Bool
    {
        return overlapsAt(x + velocity.x * elapsed, y + velocity.y * elapsed, world.solids);
    }
}
