package;

import flixel.FlxObject;

class ToolActor extends Entity
{
    public var name : String;
    public var property : String;

    public function new(X : Float, Y : Float, World : World, Name : String, ?Property : String = null)
    {
        super(X, Y, World);

        name = Name;
        property = Property;

        makeGraphic(14, 14, 0xFF2AF035);
        x += 3;
        y += 6;

        switch (name)
        {
            case "SWORD":
                //...
            default:
        }
        
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
            var fromCenter = from.getMidpoint();

            var itemForce = getMidpoint();
            itemForce.x -= fromCenter.x;
            itemForce.y -= fromCenter.y;
            itemForce.x *= 1.5;
            itemForce.y *= 1.5;

            velocity.set(itemForce.x, itemForce.y);
            drag.set(100, 100);
        }
    }
}
