package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class RandomWalker extends Enemy
{
    static var WaitDuration : Float = 1.5;
    static var WalkDuration : Float = 0.5;
    static var delta : Int = 20;

    var center : FlxPoint;
    var timer : FlxTimer;
    var tween : FlxTween;

    override public function onInit()
    {
        super.onInit();

        hp = 2;

        loadGraphic("assets/images/skelewalker.png", true, 20, 20);
        setSize(18, 18);
        offset.set(1, 1);
        x += offset.x;
        y += offset.y;

        animation.add("idle", [0, 1], 3);
        animation.add("walk", [0, 1], 10);
        animation.play("idle");

        center = new FlxPoint(x, y);
        timer = new FlxTimer();
        tween = null;
        
        var factor : Float = FlxG.random.float(1.0, 1.5);
        scale.set(factor, factor);

        walk();
    }

    function walk()
    {
        if (timer != null)
        {
            timer.cancel();
        }

        if (tween != null)
        {
            tween.cancel();
        }

        animation.play("idle");

        timer.start(WaitDuration, function(t:FlxTimer) {
            var xx : Float = x;
            var yy : Float = y;
            var tries : Int = 0;
            while (tries < 8 && (xx == x || yy == y || overlapsAt(xx, yy, world.solids) || overlapsAt(xx, yy, world.enemies)))
            {
                xx = x+FlxG.random.getObject([-delta, delta]);
                yy = y+FlxG.random.getObject([-delta, delta]);
                tries += 1;
            }

            if (tries <= 8)
            {
                animation.play("walk");
                tween = FlxTween.tween(this, {x: xx, y: yy}, WalkDuration, {ease: FlxEase.quadInOut, onComplete: function(t:FlxTween) {
                    walk();
                }});
            }
            else
            {
                walk();
            }
        });
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        player.onCollisionWithEnemy(this);
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
            tween.cancel();
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
                walk();
            });
        }
    }
}
