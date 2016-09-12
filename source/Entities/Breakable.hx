package;

import flixel.math.FlxRandom;

class Breakable extends Entity
{
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        makeGraphic(20, 20, 0xFFAB5236);
        immovable = true;
    }

    public function onCollisionWithSword(sword : Sword)
    {
        var value : Int = new FlxRandom().getObject([1, 5, 10]);
        var money : Money = new Money(x, y, world, value);
        world.moneys.add(money);
        money.velocity.set(money.x - world.player.x, money.y - world.player.y);
        money.drag.set(100, 100);

        destroy();
    }
}
