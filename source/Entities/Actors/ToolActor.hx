package;

import flixel.FlxObject;
import flixel.math.FlxMath;

class ToolActor extends Entity
{
    static var SPECIAL_TOOLS : Array<String> = ["CORPSE", "KEY", "HOSPTL"];

    public var name : String;
    public var property : String;

    public function new(X : Float, Y : Float, World : World, Name : String, ?Property : String = null, ?Slide : Bool = true)
    {
        super(X, Y, World);

        name = Name;
        property = Property;

        handleProperties();

        if (Slide)
            slide(world.player);
    }

    function handleProperties()
    {
        // Only handle the properties for thos items that are not special
        if (SPECIAL_TOOLS.indexOf(name) < 0)
        {
            switch (name)
            {
                case "ASHES":
                    loadGraphic("assets/images/ashes.png");
                    y -= height;
                    weights = false;
                    flat = true;
                default:
                    loadGraphic("assets/images/item_bag.png");
                    scale.set(1.3, 1.3);
                    x += 10-width/2;
                    y -= height;
            }
        }
    }

    public function onPickup() : Bool
    {
        if (GameState.addItem(name, property))
        {
            playSfx("pickup");
            kill();
            destroy();
            // world.items.remove(this);
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

    public function getStoragePositionX() : Int
    {
        return Std.int(x-offset.x);
    }

    public function getStoragePositionY() : Int
    {
        return Std.int(y-offset.y+height);
    }

    public function getPositionItem() : PositionItem
    {
        var pitem : PositionItem =
            new PositionItem(getStoragePositionX(), getStoragePositionY(),
                            new Item(name, property));
        return pitem;
    }
}
