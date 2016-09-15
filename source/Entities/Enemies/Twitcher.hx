package;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

class Twitcher extends Enemy
{
    static var TwitchDuration : Float = 0.2;
    static var delta : Int = 1;
    
    var center : FlxPoint;
    var timer : FlxTimer;
    
    override public function onInit()
    {
        makeGraphic(18, 18, 0xFF333333);
        x += 2;
        y += 2;
        
        center = new FlxPoint(x, y);
        timer = new FlxTimer();
        twitch();
    }
    
    function twitch()
    {
        if (timer != null)
        {
            timer.cancel();
            timer.start(TwitchDuration, function(t:FlxTimer) {
                x = center.x+FlxG.random.int(-delta, delta);
                y = center.y+FlxG.random.int(-delta, delta);
                if (FlxG.random.bool(11))
                    center.set(x, y);
                twitch();
            });
        }
    }
    
    override public function onCollisionWithPlayer(player : Player)
    {
        player.onCollisionWithEnemy(this);
    }
    
    override public function update(elapsed : Float)
    {
        super.update(elapsed);
    }
}