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

    public var canFlip : Bool;
    public var hotspot : FlxPoint;
    public var backspot : FlxPoint;

    public function new(X : Float, Y : Float, World : World, Message : String, ?CanFlip : Bool = true)
    {
        super(X, Y, World);
        immovable = true;

        // loadGraphic("assets/images/npc_dummy.png");
        makeGraphic(20, 20, 0xFF4DFF10);

        message = Message;
        canFlip = CanFlip;
        
        if (canFlip)
            flipX = FlxG.random.bool(50);
        
        setupHotspots();
        
        player = world.player;
    }
    
    public function setupGraphic(asset : String, ?w : Float = -1, ?h : Float = -1, ?frames : Int = -1, ?speed : Int = 10)
    {
        var graphic : String = "assets/images/" + asset + ".png";
        var animated : Bool = (w > 0 && h > 0 && speed > 0);
        if (!animated)
            loadGraphic(graphic);
        else
        {
            loadGraphic(graphic, true, Std.int(w), Std.int(h));
            var frames : Int = frames;
            if (frames < 0)
                frames = animation.frames;
            var frarr : Array<Int> = [];
            for (i in 0...(frames-1))
                frarr.push(i);
            animation.add("idle", frarr, speed);
            animation.play("idle");
        }
        
        setupHotspots();
    }
    
    function setupHotspots()
    {
        hotspot = new FlxPoint(x + width + 10, y + height - 10);
        if (canFlip)
            backspot = new FlxPoint(x - 10, y + height - 10);
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

        return (other.flipX != flipX && // We are facing each other
                other.getHitbox().containsPoint(spot)); // And we are close
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
