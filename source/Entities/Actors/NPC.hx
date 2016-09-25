package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

class NPC extends Entity
{
    var player : Player;

    public var message : String;
    // public var facing : Int;

    public var hotspot : FlxPoint;
    public var backspot : FlxPoint;

    public function new(X : Float, Y : Float, World : World, Message : String, ?CanFlip : Bool = true)
    {
        super(X, Y, World);
        immovable = true;

        loadGraphic("assets/images/npc_dummy.png");

        message = Message;
        hotspot = new FlxPoint(x + width + 10, y + 10);
        if (CanFlip)
            backspot = new FlxPoint(x - 10, y + 10);
        player = world.player;
    }

    override public function update(elapsed : Float)
    {
        if (backspot != null)
        {
            if (!flipX && canInteract(world.player, backspot))
            {
                flipX = true;
            }
            else if (flipX && canInteract(world.player, hotspot))
            {
                flipX = false;
            }
        }

        super.update(elapsed);
    }

    public function canInteract(other : Entity, ?spot : FlxPoint=null) : Bool
    {
        if (spot == null)
        {
            if (!flipX)
                spot = hotspot;
            else
                spot = backspot;
        }

        return other.getHitbox().containsPoint(spot);
    }

    public function onInteract()
    {
        var t : FlxTween = FlxTween.tween(this.scale, {x: 1.1, y: 1.1}, 0.2, {type: FlxTween.PINGPONG});
        world.addMessage(message, function() {
            t.cancel();
            scale.set(1, 1);
            world.player.onInteractionEnd();
        });
    }
}
