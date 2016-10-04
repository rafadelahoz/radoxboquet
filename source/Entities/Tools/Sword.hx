package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Sword extends Tool
{
    var originx : Float;
    var tween : FlxTween;
    var enabled : Bool;

    override function onActivate()
    {
        name = "SWORD";
        power = 1;

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

        originx = x;

        tween = FlxTween.tween(this, {x : targetx}, 0.06,
            {ease: FlxEase.quadIn, startDelay: 0.1, onComplete: function(_t:FlxTween) {
                _t.cancel();
                // Disable the sword once it reaches apex
                enabled = false;
                tween = FlxTween.tween(this, {x : sourcex}, 0.15, {ease: FlxEase.quadInOut, startDelay: 0.15,
                    // And destroy it at the end
                    onComplete: function(_t:FlxTween) {
                        _t.cancel();
                        tween = null;
                        onFinish();
                    }});
                }
            });

        // Setup collidable frame
        new FlxTimer().start(0.08, function(t:FlxTimer) {
            t.cancel();
            enabled = true;
        });
    }

    override public function update(elapsed : Float)
    {
        if (enabled)
        {
            FlxG.overlap(this, world.breakables, function(tool : Tool, br : Breakable) {
                if (enabled) {
                    br.onCollisionWithTool(this);
                    enabled = false;
                }
            });

            FlxG.overlap(this, world.items, pushItem);
            FlxG.overlap(this, world.moneys, pushItem);

            FlxG.overlap(this, world.enemies, hitEnemy);
        }

        super.update(elapsed);
    }

    override function onFinish()
    {
        super.onFinish();
        destroy();
    }

    function pushItem(tool : Tool, item : FlxObject) : Void
    {
        if (!item.immovable)
        {
            var toolCenter = tool.getMidpoint();
            if (tool.flipX)
                toolCenter.x - 10;
            else
                toolCenter.x + 10;

            var itemForce = item.getMidpoint();
            itemForce.x -= toolCenter.x;
            itemForce.y -= toolCenter.y;
            itemForce.x *= 4.5;
            itemForce.y *= 4.5;

            item.velocity.set(itemForce.x, itemForce.y);
            item.drag.set(100, 100);
        }

        if (Std.is(item, ToolActor))
        {
            cast(item, ToolActor).onCollisionWithTool(this);
        }
    }

    function hitEnemy(sword : Sword, enemy : Enemy)
    {
        enemy.onCollisionWithTool(this);
    }

    override public function cancel()
    {
        if (tween != null)
        {
            solid = false;

            // Cancel the motion
            tween.cancel();

            // Play some "not working" sound

            // Bounce back
            tween = FlxTween.tween(this, {x : originx}, 0.15, {ease: FlxEase.quadInOut, startDelay: 0.15,
                // And destroy it at the end
                onComplete: function(_t:FlxTween) {
                    _t.cancel();
                    tween = null;
                    onFinish();
                }});
        }
    }
}
