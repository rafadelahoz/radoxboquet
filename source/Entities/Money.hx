package;

import flixel.FlxObject;

class Money extends Entity
{
    var value : Int = 0;

    public function new(X : Float, Y : Float, World : World, Value : Int)
    {
        super(X, Y, World);

        loadGraphic("assets/images/money.png", true, 12, 12);

        value = Value;
        switch (value)
        {
            case 1:
                animation.add("idle", [1]);
            case 5:
                animation.add("idle", [2]);
            case 10:
                animation.add("idle", [0]);
        }

        animation.play("idle");
        
        slide(world.player);
    }

    public function onCollisionWithPlayer(player : Player)
    {
        GameState.addMoney(value);
        // TODO: Play sound
        destroy();
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
