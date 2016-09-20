package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Bow extends Tool
{
    override function onActivate()
    {
        name = "BOW";
        power = 0;
        
        solid = false;
        
        // loadGraphic("assets/images/sword.png");
        makeGraphic(20, 3, 0xFFFA0033);
        // setSize(20, 10);
        // offset.set(0, 6);

        x = player.x;
        y = player.y;

        // Instantiate arrow
        world.addEntity(new Arrow(x, y, world));

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
