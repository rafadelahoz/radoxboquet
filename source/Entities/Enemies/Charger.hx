package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
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
    var SightDistance : Int = 90;
    var AlertTime : Float = 0.5;
    var ChargeSpeed : Int = 200;
    var ChargeSpeedThreshold : Int = 40;
    var ChargeDrag : Int = 200;
    var HurtTime : Float = 0.6;

    var state : Int;
    var timer : FlxTimer;
    var walkTarget : FlxPoint;
    var tester : FlxObject;
    var suspictious : Bool;

    override public function onInit()
    {
        super.onInit();

        hp = 3;

        loadGraphic("assets/images/skelecharger.png", true, 20, 20);
        setSize(16, 16);
        offset.set(2, 2);
        // Correct x, y?

        animation.add("idle", [0, 1, 2, 3], 5);
        animation.add("wait", [0, 1, 2, 3], 15);
        animation.add("walk", [0, 1, 2, 3], 8);
        animation.add("alert", [4]);
        animation.add("charge", [5, 6], 20);
        animation.add("hurt", [7]);

        var factor : Float = FlxG.random.float(0.9, 1.2);
        scale.set(factor, factor);

        timer = new FlxTimer();

        // Start facing a random direction
        if (FlxG.random.bool(50))
            facing = FlxObject.LEFT;
        else
            facing = FlxObject.RIGHT;

        tester = new FlxObject(x, y);
        tester.setSize(2, 2);

        // And idle
        switchState(IDLE);
    }

    override public function onDeath(?t:FlxTimer = null)
    {
        timer.cancel();
        tester.destroy();

        super.onDeath();
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case Charger.IDLE:
                locatePlayer();
                animation.play("idle");
            case Charger.WALK:
                // If we are close to the target or have stopped, idle
                if ((getMidpoint().distanceTo(walkTarget) < WalkStopThreshold) || willMeetSolid(elapsed))
                {
                    velocity.set();
                    switchState(IDLE);
                }
                else
                {
                    flixel.math.FlxVelocity.moveTowardsPoint(this, walkTarget, WalkSpeed);
                    locatePlayer();
                }

                animation.play("walk");
                handleMovementFacing();

            case Charger.HURT:
                onHurtState();
            case Charger.ALERT:
                if (suspictious)
                    animation.play("alert");
                else
                    animation.play("wait");
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

                // Can anim speed be set in function of velocity?
                animation.play("charge");
                handleMovementFacing();
        }

        flipX = (facing == FlxObject.LEFT);

        super.update(elapsed);
    }

    function switchState(newState : Int)
    {
        timer.cancel();
        scale.set(1, 1);

        switch (newState)
        {
            case Charger.IDLE:
                timer.start(Entity.widenFloat(IdleWaitTime), onIdleEnd);
            case Charger.WALK:
                onWalkStart();
            case Charger.TURN:
                timer.start(Entity.widenFloat(TurnTime), function (t:FlxTimer) {
                    if (facing == FlxObject.LEFT)
                        facing = FlxObject.RIGHT;
                    else
                        facing = FlxObject.LEFT;
                    switchState(IDLE);
                });
            case Charger.ALERT:
                if (world.player.x < x)
                    facing = FlxObject.LEFT;
                else
                    facing = FlxObject.RIGHT;

                velocity.set(0, 0);
                suspictious = false;

                // Do a pre-wait
                timer.start(AlertTime * 0.5, function(t:FlxTimer) {
                    suspictious = true;
                    world.add(new Emotion(this, AlertTime));
                    timer.start(AlertTime, function (t:FlxTimer) {
                        switchState(CHARGE);
                    });
                });

            case Charger.CHARGE:
                walkTarget = world.player.getMidpoint();
                flixel.math.FlxVelocity.moveTowardsPoint(this, walkTarget, ChargeSpeed);
                drag.set(ChargeDrag, ChargeDrag);
            case Charger.HURT:
                timer.start(HurtTime, function (t:FlxTimer) {
                    switchState(CHARGE);
                });
        }

        state = newState;
    }

    function onIdleEnd(?t:FlxTimer = null)
    {
        var choice = FlxG.random.getObject([IDLE, TURN, WALK], [0.175, 0.175, 0.65]);
        switchState(choice);
    }

    function onWalkStart()
    {
        // Choose new position
        var target : FlxPoint = getMidpoint();
        target.x = Entity.range(target.x, WalkDistance);
        target.y = Entity.range(target.y, WalkDistance);

        var count = 0;

        // There should not be solids there
        while (overlapsAt(target.x, target.y, world.solids) && count < 100)
        {
            target.x = Entity.range(target.x, WalkDistance);
            target.y = Entity.range(target.y, WalkDistance);
            count += 1;
        }

        // Set target and leave the rest to update
        walkTarget = target;

        flixel.math.FlxVelocity.moveTowardsPoint(this, walkTarget, WalkSpeed);
    }

    function onHurtState()
    {
        animation.play("hurt");
    }

    function locatePlayer()
    {
        var LerpSteps : Int = 5;
        var midpoint : FlxPoint = getMidpoint();
        // Check player distance and overal position
        if (facing == FlxObject.LEFT && world.player.x < x ||
            facing == FlxObject.RIGHT && world.player.x > x + width)
        {
            // If close enough and facing him
            if (midpoint.distanceTo(world.player.getMidpoint()) < SightDistance &&
                Math.abs(midpoint.x - world.player.x) > Math.abs(midpoint.y - world.player.y))
            {
                // Wrycast towards its position
                tester.x = midpoint.x;
                tester.y = midpoint.y;

                var collided : Bool = false;
                for (step in 0...LerpSteps)
                {
                    tester.x = FlxMath.lerp(midpoint.x, world.player.x, step / (LerpSteps-1));
                    tester.y = FlxMath.lerp(midpoint.y, world.player.y, step / (LerpSteps-1));
                    if (tester.overlaps(world.solids))
                    {
                        // trace("Collided with player on step " + step + " at " + tester.x + ", " + tester.y);
                        collided = true;
                        break;
                    }
                }

                if (!collided)
                {
                    switchState(ALERT);
                }
            }
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

    function handleMovementFacing()
    {
        if (velocity.x < 0)
            facing = FlxObject.LEFT;
        else if (velocity.x > 0)
            facing = FlxObject.RIGHT;
    }
}
