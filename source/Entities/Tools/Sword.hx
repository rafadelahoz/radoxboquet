package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Sword extends Tool
{
    var enabled : Bool;

    override function onActivate()
    {
        name = "SWORD";

        enabled = false;
        immovable = false;

        loadGraphic("assets/images/sword.png");
        setSize(20, 10);
        offset.set(0, 6);

        y += 6;

        var sourcex = x;
        var targetx = x;

        flipX = player.flipX;
        if (flipX)
        {
            targetx = player.x - 20;
            sourcex = player.x - 5;
        }
        else
        {
            targetx = player.x + 20;
            sourcex = player.x + 5;
        }

        x = sourcex;

        FlxTween.tween(this, {x : targetx}, 0.15,
            {ease: FlxEase.quadInOut, startDelay: 0.1, onComplete: function(_t:FlxTween) {
                _t.cancel();
                FlxTween.tween(this, {x : sourcex}, 0.15, {ease: FlxEase.quadInOut, startDelay: 0.15,
                    onComplete: function(_t:FlxTween) {
                        _t.cancel();
                        onFinish();
                    }});
                }
            });

        // Setup collidable frame
        new FlxTimer().start(0.20, function(t:FlxTimer) {
            t.cancel();
            enabled = true;
        });
    }

    override public function update(elapsed : Float)
    {
        if (enabled) {
            FlxG.overlap(this, world.breakables, function(sword : Sword, br : Breakable) {
                if (enabled) {
                    br.onCollisionWithSword(this);
                    enabled = false;
                }
            });
        }

        FlxG.overlap(this, world.items, pushItem);
        FlxG.overlap(this, world.moneys, pushItem);

        super.update(elapsed);
    }

    override function onFinish()
    {
        super.onFinish();
        destroy();
    }

    function pushItem(sword : Sword, item : FlxObject) : Void
    {
        if (!item.immovable)
        {
            var swordCenter = sword.getMidpoint();
            if (sword.flipX)
                swordCenter.x - 10;
            else
                swordCenter.x + 10;

            var itemForce = item.getMidpoint();
            itemForce.x -= swordCenter.x;
            itemForce.y -= swordCenter.y;
            itemForce.x *= 1.5;
            itemForce.y *= 1.5;

            item.velocity.set(itemForce.x, itemForce.y);
            item.drag.set(100, 100);
        }

        if (Std.is(item, ToolActor))
        {
            cast(item, ToolActor).onCollisionWithTool(this);
        }
    }
}
