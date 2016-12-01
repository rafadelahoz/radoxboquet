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

    var speed : Int = 80;
    var hspeed : Int;
    var vspeed : Int;

    override public function onInit()
    {
        super.onInit();

        hp = -1;
        invincible = true;

        loadGraphic("assets/images/bouncy.png", true, 20, 20);
        animation.add("idle", [0, 1], 10);
        animation.play("idle");
        
        setSize(14, 14);
        offset.set(-1, -1);
        /*x += offset.x;
        y += offset.y;*/

        scale.set(1.3, 1.3);

        hspeed = 0;
        vspeed = 0;

        speed = speed + FlxG.random.int(-50, 50);

        new FlxTimer().start(WaitDuration, function(t:FlxTimer) {
            hspeed = (FlxG.random.bool(50) ? 1 : -1) * speed;
            vspeed = (FlxG.random.bool(50) ? 1 : -1) * speed;
        });
    }

    override public function update(elapsed : Float)
    {
        var hitX : Bool =
            (overlapsAt(x + (hspeed / 5) * elapsed, y, world.solids) ||
                overlapsAt(x + (hspeed / 5) * elapsed, y, world.npcs));
        var hitY : Bool =
            (overlapsAt(x, y + (vspeed / 5) * elapsed, world.solids) ||
                overlapsAt(x, y + (vspeed / 5) * elapsed, world.npcs));

        if (hitX)
            hspeed *= -1;

        if (hitY)
            vspeed *= -1;

        velocity.set(hspeed, vspeed);

        world.enemies.forEachOfType(BouncySpikes, function(enemy : BouncySpikes) {
            if (enemy != this && overlapsAt(x + hspeed * elapsed, y + vspeed * elapsed, enemy))
            {
                FlxObject.separate(this, enemy);
                onCollideWithOther(enemy);
                enemy.onCollideWithOther(this);
            }
        });

        super.update(elapsed);
    }

    function onCollideWithOther(enemy : BouncySpikes)
    {
        if (Math.abs(x - enemy.x) > Math.abs(y - enemy.y))
            hspeed *= -1;
        else if (Math.abs(x - enemy.x) < Math.abs(y - enemy.y))
            vspeed *= -1;
        else
        {
            hspeed *= -1;
            vspeed *= -1;
        }
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        player.onCollisionWithEnemy(this);
    }
}
