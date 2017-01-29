package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.math.FlxVelocity;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Dog extends Entity
{
    static var IDLE : Int = 0;
    static var WALK : Int = 1;

    var IdleRadius : Int = 25;
    var IdleTime : Float = 2.5;

    var IdleSpeed : Int = 50;
    var WalkStopThreshold : Int = 10;

    var state : Int;
    var target : FlxPoint;
    var timer : FlxTimer;
    var tween : FlxTween;

    var drawy : Float;

    public function new(X : Float, Y : Float, World : World, ?Graphic : String = null, ?Index : Int = -1)
    {
        super(X, Y, World);

        if (Graphic == null)
            Graphic = "assets/images/dogs.png";
        else
            Graphic = "assets/images/" + Graphic + ".png";

        loadGraphic(Graphic, true, 20, 20);
        var frames : Int = Std.int(graphic.bitmap.width / 20);
        trace(Index);
        if (Index < 0)
            Index = FlxG.random.int(0, frames);
        else if (Index >= frames)
            Index = frames-1;

        trace(Index);

        animation.add("dog", [Index]);
        animation.play("dog");

        timer = new FlxTimer();
        target = new FlxPoint();
        tween = null;

        drawy = 0;

        immovable = true;

        color = FlxG.random.color();

        switchState(IDLE);
    }

    function switchState(newState : Int)
    {
        switch (newState)
        {
            case Dog.IDLE:
                if (tween != null)
                    tween.cancel();
                tween = FlxTween.tween(this, {drawy : drawy-1}, 0.1, {ease: FlxEase.sineInOut, type : FlxTween.PINGPONG});
                timer.start(Entity.widenFloat(IdleTime), function(t:FlxTimer) {
                    switchState(WALK);
                });
            case Dog.WALK:
                setupWalkState();
        }

        state = newState;
    }

    override function update(elapsed : Float)
    {
        switch (state)
        {
            case Dog.IDLE:
                velocity.set();
            case Dog.WALK:
                if (getMidpoint().distanceTo(target) < WalkStopThreshold)
                {
                    tween.cancel();
                    switchState(IDLE);
                }

                flipX = (velocity.x < 0);
        }

        super.update(elapsed);
    }

    function setupWalkState()
    {
        var group : FlxGroup = new FlxGroup();
        group.add(world.solids);
        group.add(world.holes);
        group.add(world.npcs);
        group.add(world.teleports);

        var home = FlxPoint.get(x, y);

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
        else
        {
            switchState(IDLE);
        }

        home.destroy();

        if (tween != null)
            tween.cancel();
        tween = FlxTween.tween(this, {drawy : drawy-1}, 0.05, {ease: FlxEase.sineInOut, type : FlxTween.PINGPONG});
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

    override public function draw()
    {
        var yy : Float = y;
        y += drawy;

        super.draw();

        y = yy;
    }
}
