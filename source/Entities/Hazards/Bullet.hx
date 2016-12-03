package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;

class Bullet extends Hazard
{
    public static var Purple : String = "purple";
    public static var Lance : String = "lance";
    public static var Ball : String = "purpleball";

    var type : String;
    var target : FlxPoint;

    public function new(X : Float, Y : Float, World : World, ?Type : String = null, Target : FlxPoint, ?Direction : FlxPoint = null, ?Speed : Int = 300)
    {
        super(X, Y, World);

        flat = false;
        floating = true;

        type = Type;

        switch (type)
        {
            case Bullet.Lance:
                loadGraphic("assets/images/lance.png");
                setSize(8, 4);
                centerOffsets(true);
            case Bullet.Ball:
                loadGraphic("assets/images/purple_ball.png", true, 20, 20);
                animation.add("roll", [0, 1, 2, 3], 5);
                animation.add("break", [4]);
                animation.play("roll");
                setSize(10, 10);
                centerOffsets(true);
                x -= width;
                y -= height;
                floating = false;
            default:
                loadGraphic("assets/images/purple_bullet.png");
                setSize(10, 10);
                centerOffsets(true);
                // Center offsets
                x -= width/2;
                y -= height/2;
        }

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

        flixel.math.FlxVelocity.moveTowardsPoint(this, target, Speed);
        flipX = velocity.x < 0;
    }

    override public function update(elapsed : Float)
    {
        floating = true;
        if (solid && overlapsMap())
        {
            onBreak();
            return;
        }

        if (type == Bullet.Ball)
        {
            FlxG.overlap(this, world.hazards, onCollisionWithHazard);
        }

        floating = false;

        super.update(elapsed);
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        super.onCollisionWithPlayer(player);

        onBreak();
    }

    public function onBreak()
    {
        switch (type)
        {
            case Bullet.Ball:
                velocity.set();
                acceleration.set();
                solid = false;
                animation.play("break");
                angle = FlxG.random.getObject([0, 90, 180, 270]);
                new FlxTimer().start(0.5, function(t:FlxTimer) {
                    t.destroy();
                    kill();
                    destroy();
                });
            default:
                kill();
                destroy();
        }
    }

    public function onCollisionWithHazard(self : Bullet, hazard : Hazard)
    {
        if (Std.is(hazard, Bullet))
        {
            if (cast(hazard, Bullet).type == Bullet.Ball)
            {
                onBreak();
                (cast(hazard, Bullet)).onBreak();
            }
        }
    }
}
