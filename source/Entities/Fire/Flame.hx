package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;

class Flame extends Hazard
{
    var HeatDistance : Float = 30;

    public var heatPower : Int;
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

            heatPower = 1;
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

    public function extinguish()
    {
        living = false;
        solid = false;

        origin.set(10, 20);
        FlxTween.tween(this.scale, {x: 0.2, y: 0}, {onComplete: function(t:FlxTween){
            t.destroy();
            destroy();
        }});
    }

    override public function update(elapsed : Float)
    {
        if (source.fuelComponent == null && living)
            stop();
        else if (source.fuelComponent != null)
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

        if (living)
        {
            var entity : Entity = null;
            var iterator : FlxTypedGroupIterator<Entity> = world.entities.iterator(Flame.flammableObjects);
            while (iterator.hasNext())
            {
                entity = iterator.next();
                if (entity != source)
                {
                    if (entity.getMidpoint().distanceTo(getMidpoint()) < HeatDistance)
                    {
                        entity.onHeat(this);
                    }
                }
            }
        }

        super.update(elapsed);
    }

    public static function flammableObjects(basic : Entity) : Bool
    {
        return (cast(basic, Entity).flammable && cast(basic, Entity).currentFlame == null);
    }
}
