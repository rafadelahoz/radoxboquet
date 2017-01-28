package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

class Follower extends Enemy
{
    static var IDLE : Int = 0;
    static var GOTO : Int = 1;
    static var CHASE : Int = 2;
    static var HURT : Int = 3;

    var IdleTime : Float = 2;
    var GotoSpeed : Int = 15;
    var GotoDistance : Int = 40;
    var GotoNearDistance : Int = 8;
    var PlayerNearDistance : Int = 60;
    var ChaseSpeed : Int = 20;
    var PlayerFarDistance : Int = 120;
    var AlertTime : Float = 0.6;
    var HurtTime : Float = 0.6;

    var state : Int;
    var timer : FlxTimer;
    var target : FlxPoint;
    var midpoint : FlxPoint;
    var tester : FlxObject;
    var dochase : Bool;

    override public function onInit()
    {
        super.onInit();

        hp = 2;
        spawnsCorpse = (type != "badcrop");

        if (type == "badcrop")
            loadGraphic("assets/images/badcrop" + FlxG.random.int(0, 1) + ".png", true, 20, 20);
        else
            loadGraphic("assets/images/skelefollower.png", true, 20, 20);

        setSize(14, 14);
        offset.set(3, 3);

        animation.add("idle", [0, 1], 2);
        animation.add("walk", [0, 1], 6);
        animation.add("hurt", [2]);

        animation.play("idle");

        timer = new FlxTimer();
        target = new FlxPoint();
        midpoint = new FlxPoint();
        tester = new FlxObject(x, y);
        tester.setSize(2, 2);

        switchState(IDLE);

        FlxG.watch.add(this, "state");
    }

    override public function destroy()
    {
        timer.destroy();
        target.destroy();
        midpoint.destroy();
        tester.destroy();

        super.destroy();
    }

    function switchState(newState : Int)
    {
        switch (newState)
        {
            case Follower.IDLE:
                timer.start(Entity.widenFloat(IdleTime), function(t:FlxTimer) {
                    switchState(GOTO);
                });
            case Follower.GOTO:
                setupGoto();
            case Follower.HURT:
                timer.start(HurtTime, function (t:FlxTimer) {
                    switchState(CHASE);
                });
            case Follower.CHASE:
                if (state != Follower.HURT)
                {
                    world.add(new Emotion(this, AlertTime));
                    dochase = false;
                    timer.start(AlertTime, function(t:FlxTimer) {
                        dochase = true;
                    });
                }
                else
                {
                    dochase = true;
                }
        }

        state = newState;
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case Follower.IDLE:
                velocity.set(0, 0);
                animation.play("idle");
                locatePlayer();
            case Follower.GOTO:
                midpoint = getMidpoint(midpoint);
                if (midpoint.distanceTo(target) < GotoNearDistance || willMeetSolid(elapsed))
                {
                    velocity.set(0, 0);
                    switchState(IDLE);
                }
                else
                {
                    flixel.math.FlxVelocity.moveTowardsPoint(this, target, GotoSpeed);
                }

                animation.play("idle");
                locatePlayer();

            case Follower.HURT:
                animation.play("hurt");
            case Follower.CHASE:
                onChaseState(elapsed);
        }

        flipX = false;
        super.update(elapsed);
        FlxG.collide(this, world.enemies);
    }

    function setupGoto()
    {
        target = getMidpoint(target);
        target.x = Entity.range(target.x, GotoDistance);
        target.y = Entity.range(target.y, GotoDistance);

        var count = 0;

        // There should not be solids there
        while (overlapsAt(target.x, target.y, world.solids) && count < 100)
        {
            target.x = Entity.range(target.x, GotoDistance);
            target.y = Entity.range(target.y, GotoDistance);

            count += 1;
        }

        flixel.math.FlxVelocity.moveTowardsPoint(this, target, GotoSpeed);
    }

    function locatePlayer()
    {
        var LerpSteps : Int = 5;
        midpoint = getMidpoint(midpoint);
        var target : FlxPoint = world.player.getMidpoint();

        if (midpoint.distanceTo(target) < PlayerNearDistance)
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
                    collided = true;
                    break;
                }
            }

            if (!collided)
            {
                switchState(CHASE);
            }
        }

        target.destroy();
    }

    function onChaseState(elapsed : Float)
    {
        if (dochase)
        {
            midpoint = getMidpoint(midpoint);
            target = world.player.getMidpoint(target);
            flixel.math.FlxVelocity.moveTowardsPoint(this, target, ChaseSpeed);

            if (midpoint.distanceTo(target) > PlayerFarDistance)
                switchState(IDLE);
        }
        else
        {
            velocity.set();
        }

        animation.play("walk");
    }

    override function hurtSlide(cause : FlxObject)
    {
        super.hurtSlide(cause);

        switchState(HURT);
    }
}
