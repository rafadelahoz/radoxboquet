package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class KeyDoor extends Entity
{
    public var lockColor : String;
    public var unlockDistance : Float = 24;

    public var opening : Bool;

    var overlay : FlxSprite;

    public function new(X : Float, Y : Float, World : World, Color : String)
    {
        super(X, Y, World);

        makeGraphic(20, 20, KeyActor.getColorCode(Color));

        overlay = new FlxSprite(X, Y, "assets/images/lock_door.png");

        lockColor = Color;
        immovable = true;
        opening = false;
    }

    override public function destroy()
    {
        overlay.destroy();
        super.destroy();
    }

    override public function update(elapsed : Float)
    {
        if (!opening)
        {
            var center : FlxPoint = getMidpoint();
            var key : KeyActor = null;
            for (item in world.items)
            {
                if (Std.is(item, KeyActor))
                {
                    key = cast(item, KeyActor);
                    if (key.currentColor == lockColor &&
                        center.distanceTo(key.getMidpoint()) < unlockDistance)
                    {
                        opening = true;
                        onUnlockWithKey(key);
                        break;
                    }
                }
            }
        }

        super.update(elapsed);

        overlay.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
        overlay.draw();
    }

    public function onUnlockWithKey(key : KeyActor)
    {
        world.items.remove(key);
        var xx : Float = getMidpoint().x - key.width/2;
        var yy : Float = getMidpoint().y - key.height/2;
        FlxTween.tween(key, {x : xx, y : yy}, 0.5, {ease: FlxEase.quadOut, onComplete: function(t:FlxTween) {
            t.cancel();
            t.destroy();
            doOpen(key);
        }});
    }

    public function doOpen(key : KeyActor)
    {
        key.kill();
        key.destroy();

        FlxTween.tween(this, {alpha: 0}, 0.5, {onComplete: function(t:FlxTween){
            kill();
            destroy();
        }});
    }
}
