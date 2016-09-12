package;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Sword extends Tool
{
    override function onActivate()
    {
        loadGraphic("assets/images/sword.png");

        var sourcex = x;
        var targetx = x;

        flipX = player.flipX;
        if (flipX)
        {
            targetx = player.x - 20;
        }
        else
        {
            targetx = player.x + 20;
        }

        FlxTween.tween(this, {x : targetx}, 0.27,
            {ease: FlxEase.quadInOut, startDelay: 0.2, onComplete: function(_t:FlxTween) {
                _t.cancel();
                FlxTween.tween(this, {x : sourcex}, 0.27, {ease: FlxEase.quadInOut, onComplete: function(_t:FlxTween) {
                    _t.cancel();
                    onFinish();
                }});
        }});
    }

    override public function update(elapsed : Float)
    {
        FlxG.overlap(this, world.breakables, function(sword : Sword, br : Breakable) {
            br.onCollisionWithSword(this);
        });


        super.update(elapsed);
    }

    override function onFinish()
    {
        super.onFinish();
        destroy();
    }

}
