package;

import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

class Smoke extends Entity
{
    public function new(Source : FlxPoint, World : World)
    {
        super(Source.x, Source.y, World);

        loadGraphic("assets/images/smoke.png", true, 24, 24);
        animation.add("idle", [0, 1], 6, false);
        animation.play("idle");
        solid = false;

        centerOffsets(true);
        x -= width/2;
        y -= width/2;

        alpha = 1;

        FlxTween.tween(this.scale, {x: 1.25, y: 1.25}, 0.75, {onComplete: function(t:FlxTween) {
            t.destroy();
            kill();
            destroy();
        }});

        FlxTween.tween(this, {alpha: 0.2}, 0.75, {onComplete: function(t:FlxTween) {
            t.destroy();
        }});
    }
}
