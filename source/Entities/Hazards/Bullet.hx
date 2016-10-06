package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class Bullet extends Hazard
{
    var target : FlxPoint;

    public function new(X : Float, Y : Float, World : World, Target : FlxObject, ?Speed : Int = 300)
    {
        super(X, Y, World);

        loadGraphic("assets/images/purple_bullet.png");
        setSize(10, 10);
        centerOffsets(true);
        x -= 5;
        y -= 5;

        flat = false;

        target = Target.getMidpoint();

        flixel.math.FlxVelocity.moveTowardsPoint(this, target, Speed);
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
