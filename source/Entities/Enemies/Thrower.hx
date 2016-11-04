package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

class Thrower extends Enemy
{
    static var IDLE : Int = 0;
    static var POSITION : Int = 1;
    static var SHOOT : Int = 2;

    var LocationThreshold : Float = 100;

    var PositioningTime : Float = 4;
    var Accel : Int = 5000;
    var MaxSpeed : Int = 250;
    var Distance : Int = 60;
    var PositionMargin : Int = 20;
    var InPositionTime : Float = 1;

    var ShootDelay : Float = 0.5;
    var ShootTime : Float = 0.5;
    var ThrowSpeed : Int = 222;

    var timer : FlxTimer;

    var state : Int;
    var positionedTime : Float;

    override public function onInit()
    {
        super.onInit();

        hp = 3;

        makeGraphic(18, 18, 0xFFFFFFFF);
        offset.set(1, 1);

        timer = new FlxTimer();
        positionedTime = 0;

        switchState(IDLE);

        FlxG.watch.add(this, "positionedTime");
        FlxG.watch.add(this, "Math.abs(world.player.getMidpoint().y - getMidpoint().y)");
    }

    function switchState(newState : Int)
    {
        switch (newState)
        {
            case Thrower.IDLE:
                // DODO
            case Thrower.POSITION:
                timer.start(PositioningTime, function(t:FlxTimer) {
                    switchState(SHOOT);
                });
            case Thrower.SHOOT:
                positionedTime = 0;
                timer.start(ShootDelay, doShoot);
        }

        state = newState;
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case Thrower.IDLE:
                locatePlayer();
            case Thrower.POSITION:
                handlePositioning(elapsed);
            case Thrower.SHOOT:
                velocity.set();
                acceleration.set();
        }

        super.update(elapsed);
    }

    function doShoot(?t:FlxTimer = null)
    {
        timer.cancel();
        // Shoot
        flash(0xFF000000, ShootTime);
        // animation.play("open");

        var target : FlxPoint = new FlxPoint();
        if (world.player.getMidpoint().x < x)
            target.x -= 10;
        else
            target.x += 10;

        world.addEntity(new Bullet(getMidpoint().x, getMidpoint().y, world, null, target, ThrowSpeed));

        timer.start(ShootTime, function(t:FlxTimer) {
            switchState(POSITION);
        });
    }

    function handlePositioning(elapsed : Float)
    {
        var midpoint : FlxPoint = getMidpoint();
        var playerPos : FlxPoint = world.player.getMidpoint();

        var targetPoint : FlxPoint = new FlxPoint(x, playerPos.y);

        if (midpoint.x < playerPos.x)
        {
            targetPoint.x = playerPos.x - Distance;
        }
        else
        {
            targetPoint.x = playerPos.x + Distance;
        }

        FlxVelocity.accelerateTowardsPoint(this, targetPoint, Accel, MaxSpeed);

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
}
