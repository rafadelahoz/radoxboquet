package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

class Idler extends Enemy
{
    static var DECIDE : Int = 0;
    static var WALK : Int = 1;
    static var HURT : Int = 2;

    var state : Int;
    var step : Int = 20;
    var tween : FlxTween;
    var waitDuration : Float = 0.5;
    var stepDuration : Float = 1;

    override public function onInit()
    {
        hp = 3;

        loadGraphic("assets/images/skelewalker.png", true, 20, 20);
        animation.add("walk", [0, 1], 20);
        animation.play("walk");

        setSize(16, 16);
        offset.set(2, 2);
        x += offset.x;
        y += offset.y;

        var factor : Float = FlxG.random.float(1.0, 1.5);
        scale.set(factor, factor);

        tween = null;

        state = DECIDE;
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case Idler.DECIDE:
                onDecideState();
            case Idler.WALK:
                onWalkState();
            case Idler.HURT:
                onHurtState();
            default:
        }

        super.update(elapsed);
    }

    function onDecideState()
    {
        var found : Bool = false;
        var options : Array<Int> = [0, 1, 2, 3];
        var option : Int = -1;

        while (!found && options.length > 0)
        {
            option = FlxG.random.getObject(options);
            options.remove(option);

            switch(option)
            {
                case 0: found = !overlapsMapAt(x - 10, y);
                case 1: found = !overlapsMapAt(x + 10, y);
                case 2: found = !overlapsMapAt(x, y - 10);
                case 3: found = !overlapsMapAt(x, y + 10);
            }
        }

        if (!found)
            option = FlxG.random.int(0, 4);

        var target : FlxPoint = new FlxPoint(x, y);

        switch (option)
        {
            case 0: target.x -= step;
            case 1: target.x += step;
            case 2: target.y -= step;
            case 3: target.y += step;
        }

        tween = FlxTween.tween(this, {x: target.x, y: target.y}, stepDuration,
            {startDelay: waitDuration, onComplete: function(t:FlxTween){
                tween.cancel();
                state = DECIDE;
            }
        });

        state = WALK;
    }

    function onWalkState()
    {

    }

    function onHurtState()
    {

    }
}
