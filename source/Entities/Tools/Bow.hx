package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Bow extends Tool
{
    var arrowCost : Int = 2;

    override function onActivate()
    {
        name = "BOW";
        power = 0;

        solid = false;

        loadGraphic("assets/images/bow.png");

        x = player.x-2;
        y = player.y-8;

        if (GameState.money >= arrowCost)
        {
            // Pay the price
            GameState.addMoney(-arrowCost);
            // Instantiate arrow
            world.addEntity(new Arrow(x, y+8, world));
        }
        else
        {
            // Instantiate smoke?
            // Instantiate a money sign?
        }

        // Hide after a sec
        new FlxTimer().start(0.4, function(t:FlxTimer) {
            onFinish();
        });
    }

    override function onFinish()
    {
        super.onFinish();
        destroy();
    }
}
