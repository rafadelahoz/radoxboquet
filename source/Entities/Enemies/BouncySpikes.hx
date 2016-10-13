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
    static var speed : Int = 50;

    override public function onInit()
    {
        super.onInit();

        hp = -1;
        invincible = true;

        loadGraphic("assets/images/purplebullet.png");
        setSize(14, 14);
        offset.set(3, 3);
        x += offset.x;
        y += offset.y;

        speed = speed + FlxG.random.int(-50, 50);

        new FlxTimer().start(WaitDuration, function(t:FlxTimer) {
            velocity.x = (FlxG.random.bool(50) ? 1 : -1) * speed;
            velocity.y = (FlxG.random.bool(50) ? 1 : -1) * speed;
        });

        FlxG.watch.add(this, "velocity");
        solid = false;
    }

    override public function update(elapsed : Float)
    {
        if (overlapsAt(x + velocity.x * elapsed, y, world.solids))
        {
            velocity.x *= -1;
        }

        if (overlapsAt(x, y + velocity.y * elapsed, world.solids))
        {
            velocity.y *= -1;
        }

        super.update(elapsed);
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        player.onCollisionWithEnemy(this);
    }
}
