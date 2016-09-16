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
            default:
                makeGraphic(14, 14, 0xFF2AF035);
                x += 3;
                y += 6;
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
            
            /*var fromCenter = from.getMidpoint();

            var itemForce = getMidpoint();
            itemForce.x -= fromCenter.x;
            itemForce.y -= fromCenter.y;
            
            itemForce.x = FlxMath.bound(itemForce.x, -24, 24);
            itemForce.y = FlxMath.bound(itemForce.y, -24, 24);
            
            itemForce.x *= 1.5;
            itemForce.y *= 1.5;

            velocity.set(itemForce.x, itemForce.y);
            drag.set(100, 100);*/
        }
    }
}
