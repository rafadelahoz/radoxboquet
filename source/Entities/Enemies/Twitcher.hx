package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

class Twitcher extends Enemy
{
    static var TwitchDuration : Float = 0.12;
    static var delta : Int = 1;

    var center : FlxPoint;
    var timer : FlxTimer;

    override public function onInit()
    {
        super.onInit();

        hp = 2;
        power = 1;

        loadGraphic("assets/images/twitcher.png", true, 20, 20);
        setSize(18, 18);
        offset.set(1, 1);
        x += offset.x;
        y += offset.y;

        animation.add("twitch", [0, 1], 10);
        animation.play("twitch");

        hurtSfxSet = [];
        for (i in 1...6)
            hurtSfxSet.push("enemy_b-hurt" + i);

        center = new FlxPoint(x, y);
        timer = new FlxTimer();
        twitch();
    }

    override public function destroy()
    {
        center.destroy();
        timer.cancel();
        timer.destroy();

        super.destroy();
    }

    function twitch()
    {
        if (timer != null)
        {
            timer.cancel();
        }

        animation.paused = false;

        timer.start(TwitchDuration, function(t:FlxTimer) {
            x = center.x+FlxG.random.int(-delta, delta);
            y = center.y+FlxG.random.int(-delta, delta);
            if (FlxG.random.bool(11))
                center.set(x, y);
            twitch();
        });
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);
    }

    override function hurtSlide(cause : FlxObject)
    {
        super.hurtSlide(cause);

        // Don't twitch until slide finishes (please?)
        if (timer != null)
        {
            timer.cancel();
        }

        // If you are still alive, then please continue
        if (hp > 0)
        {
            animation.paused = true;
            timer.start(0.5, function(t:FlxTimer) {
                timer.cancel();
                // Stop sliding
                velocity.set();

                // Use the new position
                center.x = x;
                center.y = y;

                // And do your thing?
                twitch();
            });
        }
    }
}
