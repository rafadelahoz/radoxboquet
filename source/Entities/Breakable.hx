package;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;

class Breakable extends Entity
{
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        makeGraphic(18, 18, 0xFFAB5236);
        centerOffsets(true);
        immovable = true;
    }

    public function onCollisionWithSword(sword : Sword)
    {
        var value : Int = FlxG.random.getObject([1, 5, 10]);

        var spawnPos : FlxPoint = getMidpoint();

        var money : Money = new Money(spawnPos.x, spawnPos.y, world, value);
        world.addEntity(money);

        destroy();
    }
}
