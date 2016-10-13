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

        handleGraphic();

        if (Slide)
            slide(world.player);
    }

    function handleGraphic()
    {
        // Only handle the graphic for thos items that are not special
        if (SPECIAL_TOOLS.indexOf(name) < 0)
        {
            switch (name)
            {
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
