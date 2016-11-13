package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

class Thrower extends Enemy
{
    static var IDLE : Int = 0;
    static var POSITION : Int = 1;
    static var SHOOT : Int = 2;
    static var HURT : Int = 3;

    var LocationThreshold : Float = 100;

    var PositioningTime : Float = 4;
    var Accel : Int = 3000;
    var MaxSpeed : Int = 200;
    var Distance : Int = 60;
    var StopThreshold : Int = 4;
    var PositionMargin : Int = 20;
    var InPositionTime : Float = 1;

    var ShootDelay : Float = 1;
    var ShootTime : Float = 0.5;
    var ThrowSpeed : Int = 130;

    var HurtTime : Float = 0.5;

    var timer : FlxTimer;

    var state : Int;
    var positionedTime : Float;
    var targetPoint : FlxPoint;

    override public function onInit()
    {
        super.onInit();

        hp = 3;

        loadGraphic("assets/images/skelethrower.png", true, 20, 20);
        animation.add("idle", [0, 1], 4);
        animation.add("walk", [1, 0], 6);
        animation.add("wait", [1, 0], 12);
        animation.add("shoot", [2]);
        animation.add("hurt", [3]);

        animation.play("idle");

        setSize(18, 18);
        offset.set(1, 1);

        timer = new FlxTimer();
        positionedTime = 0;
        targetPoint = new FlxPoint();

        switchState(IDLE);

        FlxG.watch.add(this.acceleration, "x");
        FlxG.watch.add(this.acceleration, "y");
        FlxG.watch.add(this.velocity, "x");
        FlxG.watch.add(this.velocity, "y");
    }

    function switchState(newState : Int)
    {
        switch (newState)
        {
            case Thrower.IDLE:
                // DODO
            case Thrower.POSITION:
                drag.set(200, 200);
                timer.start(PositioningTime, function(t:FlxTimer) {
                    switchState(SHOOT);
                });
            case Thrower.SHOOT:
                positionedTime = 0;
                timer.start(ShootDelay, doShoot);
                animation.play("wait");
            case Thrower.HURT:
                timer.cancel();
                timer.start(HurtTime, function (t:FlxTimer) {
                    switchState(POSITION);
                });
        }

        state = newState;
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case Thrower.IDLE:
                locatePlayer();
                animation.play("idle");
            case Thrower.POSITION:
                handlePositioning(elapsed);
            case Thrower.SHOOT:
                velocity.set();
                acceleration.set();
            case Thrower.HURT:
                animation.play("hurt");
        }

        super.update(elapsed);
    }

    function doShoot(?t:FlxTimer = null)
    {
        timer.cancel();

        if (state != SHOOT)
            return;

        // Shoot
        // flash(0xFF000000, ShootTime);
        shake(ShootTime * 0.3);
        // animation.play("open");

        var origin : FlxPoint = getMidpoint();
        var target : FlxPoint = new FlxPoint();

        if (flipX)
        {
            origin.x -= 14;
            target.x -= 10;
        }
        else
        {
            origin.x += 4;
            target.x += 10;
        }

        world.addEntity(new Bullet(origin.x, origin.y, world, Bullet.Lance, null, target, ThrowSpeed));

        animation.play("shoot");

        timer.start(ShootTime, function(t:FlxTimer) {
            switchState(POSITION);
        });
    }

    function handlePositioning(elapsed : Float)
    {
        var midpoint : FlxPoint = getMidpoint();
        var playerPos : FlxPoint = world.player.getMidpoint();

        targetPoint.set(x, playerPos.y);

        if (midpoint.x < playerPos.x)
        {
            targetPoint.x = playerPos.x - Distance;
        }
        else
        {
            targetPoint.x = playerPos.x + Distance;
        }

        FlxVelocity.accelerateTowardsPoint(this, targetPoint, Accel, MaxSpeed);

        if (midpoint.distanceTo(targetPoint) <= StopThreshold)
        {
            acceleration.set();
        }

        FlxG.collide(this, world.enemies);

        if (Math.abs(playerPos.y - midpoint.y) < PositionMargin)
            positionedTime += elapsed;
        else
            positionedTime = 0;

        if (positionedTime >= InPositionTime)
        {
            timer.cancel();
            positionedTime = 0;
            switchState(SHOOT);
        }

        flipX = (playerPos.x < midpoint.x);
        animation.play("walk");
    }

    function locatePlayer()
    {
        var midpoint : FlxPoint = getMidpoint();
        var playerPos : FlxPoint = world.player.getMidpoint();

        if (midpoint.distanceTo(playerPos) < LocationThreshold)
        {
            switchState(POSITION);
        }
    }

    override function hurtSlide(cause : FlxObject)
    {
        velocity.set();
        acceleration.set();

        super.hurtSlide(cause);

        // If you are still alive, then please continue
        if (hp > 0)
        {
            switchState(HURT);
        }
    }

    override public function onDeath(?t:FlxTimer = null)
    {
        timer.cancel();
        super.onDeath();
    }

    override public function draw()
    {
        super.draw();

        // new FlxSprite(targetPoint.x, targetPoint.y).makeGraphic(2, 2, 0xFFFFFFFF).draw();
    }
}
