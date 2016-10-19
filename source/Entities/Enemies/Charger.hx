package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;

class Charger extends Enemy
{
    static var IDLE     : Int = 0;
    static var TURN     : Int = 1;
    static var WALK     : Int = 2;
    static var ALERT    : Int = 3;
    static var CHARGE   : Int = 4;
    static var REST     : Int = 5;
    static var HURT     : Int = 6;

    var IdleWaitTime : Float = 2;
    var WalkDistance : Int = 40;
    var WalkStopThreshold : Float = 8;
    var WalkSpeed : Int = 40;
    var TurnTime : Float = 0.5;
    var AlertTime : Float = 0.5;
    var ChargeSpeed : Int = 200;
    var ChargeSpeedThreshold : Int = 40;
    var ChargeDrag : Int = 200;

    var state : Int;
    var timer : FlxTimer;
    var walkTarget : FlxPoint;

    override public function onInit()
    {
        super.onInit();

        hp = 3;

        loadGraphic("assets/images/transition.png");
        setSize(14, 14);
        offset.set(3, 3);
        // Correct x, y?

        timer = new FlxTimer();

        // Start facing a random direction
        if (FlxG.random.bool(50))
            facing = FlxObject.LEFT;
        else
            facing = FlxObject.RIGHT;

        // And idle
        switchState(IDLE);
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case Charger.IDLE:
                if (FlxG.keys.justPressed.C)
                    switchState(ALERT);
            case Charger.WALK:
                // If we are close to the target or have stopped, idle
                if ((getMidpoint().distanceTo(walkTarget) < WalkStopThreshold) || willMeetSolid(elapsed))
                {
                    trace("Arrived");
                    velocity.set();
                    switchState(IDLE);
                }
                else
                {
                    flixel.math.FlxVelocity.moveTowardsPoint(this, walkTarget, WalkSpeed);
                }
            case Charger.HURT:
                onHurtState();
            case Charger.ALERT:
                // Graphic
                scale.set(0.8, 0.8);
            case Charger.CHARGE:
                if (Math.abs(velocity.x) + Math.abs(velocity.y) < ChargeSpeedThreshold)
                {
                    velocity.set(0, 0);
                    switchState(IDLE);
                }
                else if (willMeetSolid(elapsed))
                {
                    // Bounce!

                    var hitX : Bool =
                        (overlapsAt(x + (velocity.x * elapsed), y, world.solids));
                        //  || overlapsAt(x + (hspeed / 5) * elapsed, y, world.npcs));
                    var hitY : Bool =
                        (overlapsAt(x, y + (velocity.y * elapsed), world.solids));
                        //  || overlapsAt(x, y + (vspeed / 5) * elapsed, world.npcs));

                    if (hitX)
                        velocity.x *= -1;
                    if (hitY)
                        velocity.y *= -1;
                }
        }

        super.update(elapsed);
    }

    function switchState(newState : Int)
    {
        timer.cancel();
        scale.set(1, 1);

        switch (newState)
        {
            case Charger.IDLE:
                timer.start(widen(IdleWaitTime), onIdleEnd);
            case Charger.WALK:
                onWalkStart();
            case Charger.TURN:
                timer.start(widen(TurnTime), function (t:FlxTimer) {
                    if (facing == FlxObject.LEFT)
                        facing = FlxObject.RIGHT;
                    else
                        facing = FlxObject.LEFT;
                    switchState(IDLE);
                });
            case Charger.ALERT:
                timer.start(AlertTime, function (t:FlxTimer) {
                    switchState(CHARGE);
                });
            case Charger.CHARGE:
                walkTarget = world.player.getMidpoint();
                flixel.math.FlxVelocity.moveTowardsPoint(this, walkTarget, ChargeSpeed);
                drag.set(ChargeDrag, ChargeDrag);
        }

        flipX = (facing == FlxObject.LEFT);

        state = newState;
    }

    function onIdleEnd(?t:FlxTimer = null)
    {
        var choice = FlxG.random.getObject([/*IDLE, */TURN, WALK]);
        switchState(choice);
    }

    function onWalkStart()
    {
        // Choose new position
        var target : FlxPoint = getMidpoint();
        target.x = range(target.x, WalkDistance);
        target.y = range(target.y, WalkDistance);

        // There should not be solids there
        while (overlapsAt(target.x, target.y, world.solids))
        {
            target.x = range(target.x, WalkDistance);
            target.y = range(target.y, WalkDistance);
        }

        // Set target and leave the rest to update
        walkTarget = target;

        flixel.math.FlxVelocity.moveTowardsPoint(this, walkTarget, WalkSpeed);
    }

    function onHurtState()
    {
        if (Math.abs(velocity.x) < 50 && Math.abs(velocity.y) < 50)
        {
            switchState(IDLE);
        }
    }

    override function hurtSlide(cause : FlxObject)
    {
        super.hurtSlide(cause);

        // If you are still alive, then please continue
        if (hp > 0)
        {
            switchState(HURT);
        }
    }

    function willMeetSolid(elapsed : Float) : Bool
    {
        return overlapsAt(x + velocity.x * elapsed, y + velocity.y * elapsed, world.solids);
    }

    // returns value randomized by +/- 30%
    static function widen(value : Float) : Float
    {
        return value + FlxG.random.float(- value * 0.3, value * 0.3);
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
}
