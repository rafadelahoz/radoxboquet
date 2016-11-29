package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class Bullet extends Hazard
{
    public static var Purple : String = "purple";
    public static var Lance : String = "lance";
    var target : FlxPoint;

    public function new(X : Float, Y : Float, World : World, ?Type : String = null, Target : FlxPoint, ?Direction : FlxPoint = null, ?Speed : Int = 300)
    {
        super(X, Y, World);

        switch (Type)
        {
            case "lance":
                loadGraphic("assets/images/lance.png");
                setSize(8, 4);
                centerOffsets(true);
            default:
                loadGraphic("assets/images/purple_bullet.png");
                setSize(10, 10);
                centerOffsets(true);
                // Center offsets
                x -= width/2;
                y -= height/2;
        }

        flat = false;
        floating = true;

        target = Target;
        if (target == null && Direction != null)
        {
            target = getMidpoint();
            target.x += Direction.x;
            target.y += Direction.y;
        }

        // Correct target
        target.x += offset.x;
        target.y += offset.y;

        trace("bullet: " + x + ", " + y);

        flixel.math.FlxVelocity.moveTowardsPoint(this, target, Speed);
        flipX = velocity.x < 0;
    }

    override public function update(elapsed : Float)
    {
        if (overlapsMap())
        {
            kill();
            destroy();
            return;
        }

        super.update(elapsed);
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        super.onCollisionWithPlayer(player);

        kill();
        destroy();
    }
}
