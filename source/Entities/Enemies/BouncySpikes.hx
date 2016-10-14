package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class BouncySpikes extends Enemy
{
    static var WaitDuration : Float = 0.5;

    var speed : Int = 50;
    var hspeed : Int;
    var vspeed : Int;

    override public function onInit()
    {
        super.onInit();

        hp = -1;
        invincible = true;

        loadGraphic("assets/images/purplebullet.png");
        setSize(14, 14);
        offset.set(-1, -1);
        /*x += offset.x;
        y += offset.y;*/

        hspeed = 0;
        vspeed = 0;

        speed = speed + FlxG.random.int(-50, 50);

        new FlxTimer().start(WaitDuration, function(t:FlxTimer) {
            hspeed = (FlxG.random.bool(50) ? 1 : -1) * speed;
            vspeed = (FlxG.random.bool(50) ? 1 : -1) * speed;
        });

        FlxG.watch.add(this, "velocity");
    }

    override public function update(elapsed : Float)
    {
        if (overlapsAt(x + hspeed / 2 * elapsed, y, world.solids))
        {
            hspeed *= -1;
        }

        if (overlapsAt(x, y + vspeed / 2 * elapsed, world.solids))
        {
            vspeed *= -1;
        }

        velocity.set(hspeed, vspeed);

        super.update(elapsed);
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        player.onCollisionWithEnemy(this);
    }
}
