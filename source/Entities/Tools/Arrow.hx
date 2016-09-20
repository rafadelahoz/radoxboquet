package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;

class Arrow extends Tool
{
    var enabled : Bool;
    var speed : Int = 160;

    override function onActivate()
    {
        name = "ARROW";
        power = 1;

        enabled = false;

        loadGraphic("assets/images/arrow.png");
        setSize(4, 12);
        offset.set(0, 4);

        x += 8;
        y -= 8;

        // Setup collidable frame
        new FlxTimer().start(0.1, function(t:FlxTimer) {
            t.cancel();
            enabled = true;
        });

        velocity.set(0, -speed);
    }

    override public function update(elapsed : Float)
    {
        if (enabled)
        {
            if (overlapsAt(x, y-2, world.solids))
            {
                onHitSomething();
            }

            FlxG.overlap(this, world.breakables, function(tool : Tool, br : Breakable) {
                if (enabled)
                {
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

    function pushItem(self : Tool, item : FlxObject) : Void
    {
        if (!item.immovable)
        {
            var selfCenter = self.getMidpoint();

            var itemForce = item.getMidpoint();
            itemForce.x -= selfCenter.x;
            itemForce.y -= selfCenter.y;
            itemForce.x *= 3.0;
            itemForce.y *= 3.0;

            item.velocity.set(itemForce.x, itemForce.y);
            item.drag.set(100, 100);
        }

        if (Std.is(item, ToolActor))
        {
            cast(item, ToolActor).onCollisionWithTool(this);
        }

        if (Std.is(item, KeyActor))
        {
            onHitSomething();
        }
    }

    function hitEnemy(self : Tool, enemy : Enemy)
    {
        if (enabled)
        {
            // Notify enemy
            enemy.onCollisionWithTool(this);
            onHitSomething();
        }
    }

    function onHitSomething()
    {
        // Don't do anything to anyone
        enabled = false;
        solid = false;

        // Bounce
        velocity.set(FlxG.random.int(-50, 50), velocity.y*(-0.1));
        angle = FlxG.random.getObject([-15, 15]);

        // Flicker
        FlxFlicker.flicker(this, 0.12, 0.02, false);

        // And go away
        new FlxTimer().start(0.12, function(t:FlxTimer) {
            t.destroy();
            kill();
            destroy();
        });
    }
}
