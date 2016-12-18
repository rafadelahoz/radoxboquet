package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.math.FlxVelocity;
import flixel.group.FlxGroup;

class WoolBear extends Enemy
{
    static var IDLE : Int = 0;
    static var WALK : Int = 1;
    static var CHASE : Int = 2;
    static var ADMIRE : Int = 3;
    static var RETURN : Int = 4;

    var IdleRadius : Int = 25;
    var ChaseRadius : Int = 75;

    var IdleTime : Float = 2.5;

    var IdleSpeed : Int = 50;
    var WalkStopThreshold : Int = 10;
    var ChaseSpeed : Int = 75;
    var AdmireSpeed : Int = 50;

    var state : Int;
    var home : FlxPoint;
    var targetEntity : Entity;
    var target : FlxPoint;
    var timer : FlxTimer;
    var tester : FlxObject;

    override public function onInit()
    {
        super.onInit();

        makeGraphic(20, 20, 0xFFFFFFFF);
        setSize(16, 16);
        offset.set(2, 2);

        timer = new FlxTimer();
        home = getMidpoint();
        target = new FlxPoint();

        tester = new FlxObject(2, 2);

        switchState(IDLE);
    }

    function switchState(newState : Int)
    {
        switch (newState)
        {
            case WoolBear.IDLE:
                timer.start(Entity.widenFloat(IdleTime), function(t:FlxTimer) {
                    switchState(WALK);
                });
            case WoolBear.WALK:
                setupWalkState();
            case WoolBear.CHASE:
            case WoolBear.RETURN:
                FlxVelocity.moveTowardsPoint(this, home, IdleSpeed);
        }

        state = newState;
    }

    override function update(elapsed : Float)
    {
        switch (state)
        {
            case WoolBear.IDLE:
                angle = 0;
                velocity.set();
                locatePlayer();

                color = 0xFFFFFFFF;
            case WoolBear.WALK:
                if (getMidpoint().distanceTo(target) < WalkStopThreshold)
                {
                    switchState(IDLE);
                }

                locatePlayer();

                color = 0xFFFFFFFF;
                angle += 1;
            case WoolBear.CHASE:
                target = targetEntity.getMidpoint();
                if (home.distanceTo(target) < ChaseRadius)
                {
                    FlxVelocity.moveTowardsPoint(this, target, ChaseSpeed);
                }
                else
                {
                    switchState(RETURN);
                }

                color = 0xFFFF004D;
                angle += 5;
            case WoolBear.RETURN:
                if (home.distanceTo(getMidpoint()) < WalkStopThreshold)
                    switchState(IDLE);
        }

        super.update(elapsed);
    }

    function locatePlayer()
    {
        var LerpSteps : Int = 5;
        var midpoint : FlxPoint = getMidpoint();
        var target : FlxPoint = world.player.getMidpoint();

        if (midpoint.distanceTo(target) < ChaseRadius)
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
                targetEntity = world.player;
                switchState(CHASE);
            }
        }

        target.destroy();
    }

    function setupWalkState()
    {
        var group : FlxGroup = new FlxGroup();
        group.add(world.solids);
        group.add(world.holes);
        group.add(world.npcs);

        // Choose walk target position
        target = getPositionInRadius(home, IdleRadius, 10);
        var tries : Int = 0;
        while (tries < 100 && overlapsAt(target.x, target.y, group))
        {
            target = getPositionInRadius(home, IdleRadius, 10);
            tries += 1;
        }

        if (tries < 100)
        {
            FlxVelocity.moveTowardsPoint(this, target, IdleSpeed);
        }
    }

    public static function getPositionInRadius(from : FlxPoint, radius : Float, ?minRadius : Float = 0) : FlxPoint
    {
        // Get a random amplitude between min and max
        var amplitude : Float = FlxG.random.float(minRadius, radius);
        // Get a random angle in rads
        var angle : Float = FlxG.random.float(0, 6.28);

        // Compute the new pos
        var pos : FlxPoint = new FlxPoint();
        pos.x = from.x + FlxMath.fastCos(angle)*amplitude;
        pos.y = from.y + FlxMath.fastSin(angle)*amplitude;
        return pos;
    }
}
