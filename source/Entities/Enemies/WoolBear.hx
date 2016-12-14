package;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;

class WoolBear extends Enemy
{
    static var IDLE : Int = 0;
    static var WALK : Int = 1;
    static var CHASE : Int = 2;
    static var ADMIRE : Int = 3;

    var IdleRadius : Int = 25;
    var ChaseRadius : Int = 50;

    var IdleSpeed : Int = 100;
    var ChaseSpeed : Int = 100;
    var AdmireSpeed : Int = 100;

    var state : Int;
    var home : FlxPoint;
    var timer : FlxTimer;

    override public function onInit()
    {
        super.onInit();

        makeGraphic(20, 20, 0xFFFFFFFF);
        setSize(16, 16);
        offset.set(2, 2);

        timer = new FlxTimer();
        home = new FlxPoint();
    }

    function switchState(newState : Int)
    {
        switch (newState)
        {

        }

        state = newState;
    }

    override function update(elapsed : Float)
    {
        switch (state)
        {

        }

        super.update(elapsed);
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
