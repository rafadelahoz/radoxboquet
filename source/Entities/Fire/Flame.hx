package;

import flixel.FlxG;
import flixel.math.FlxPoint;

class Flame extends Hazard
{
    var source : Entity;
    var living : Bool;

    public function new(Source : Entity)
    {
        var position : FlxPoint = Source.getFlamePosition();
        super(position.x, position.y, Source.world);

        if (!Source.flammable)
        {
            trace("Flame over non flammable source " + Source);
            source = null;
        }
        else
        {
            source = Source;

            loadGraphic("assets/images/fire.png", true, 20, 20);
            var speed : Int = Std.int(Entity.widenFloat(5));
            animation.add("idle", [0, 1], speed);
            animation.play("idle");

            // Reposition
            x -= width/2;
            y -= height;

            setSize(15, 15);
            centerOffsets(true);

            immovable = true;
            living = false;

            flat = false;
        }
    }

    public function start()
    {
        if (!living)
        {
            living = true;
            solid = true;
            visible = true;
        }
    }

    public function stop()
    {
        if (living)
        {
            living = false;
            solid = false;
            visible = false;
        }
    }

    override public function update(elapsed : Float)
    {
        if (source.fuelComponent == null)
            stop();
        else
        {
            if (source.fuelComponent.hasFuel())
            {
                source.fuelComponent.drawFuel();
                start();
            }
            else
            {
                stop();
            }
        }

        super.update(elapsed);
    }
}
