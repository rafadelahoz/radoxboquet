package;

import flixel.FlxObject;
import flixel.math.FlxMath;

class ToolActor extends Entity
{
    public var name : String;
    public var property : String;

    public function new(X : Float, Y : Float, World : World, Name : String, ?Property : String = null, ?Slide : Bool = true)
    {
        super(X, Y, World);

        name = Name;
        property = Property;

        switch (name)
        {
            case "CORPSE":
            case "KEY":
            case "HOSPTL":
            default:
                loadGraphic("assets/images/item_bag.png");
                x += 10-width/2;
                y -= height;
        }

        if (Slide)
            slide(world.player);
    }

    public function onPickup() : Bool
    {
        if (GameState.addItem(name, property))
        {
            kill();
            destroy();
            world.items.remove(this);
            return true;
        }
        else
        {
            return false;
        }
    }

    public function onCollisionWithTool(tool : Tool)
    {
        // override!
    }

    public function slide(from : FlxObject)
    {
        if (from != null)
        {
            doSlide(getMidpoint(), from.getMidpoint(), 1.5);
        }
    }
    
    public function getPositionItem() : PositionItem
    {
        var pitem : PositionItem = new PositionItem(x-offset.x, y-offset.y+height, new Item(name, property));
        return pitem;
    }
}
