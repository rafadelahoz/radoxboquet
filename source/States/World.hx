package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxRandom;
import flixel.group.FlxGroup;

class World extends FlxState
{
    public var hud : HUD;
    public var player : Player;

    public var moneys : FlxGroup;
    public var breakables : FlxGroup;

    override public function create()
    {
        bgColor = new FlxRandom().color();

        moneys = new FlxGroup();
        add(moneys);

        breakables = new FlxGroup();
        add(breakables);

        player = new Player(100, 100, this);
        add(player);

        hud = new HUD();
        add(hud);
    }

    override public function update(elapsed : Float)
    {
        if (FlxG.mouse.justPressed)
        {
            breakables.add(new Breakable(20*Std.int(FlxG.mouse.x/20), 20*Std.int(FlxG.mouse.y/20), this));
        }

        FlxG.overlap(player, moneys, onCollidePlayerMoney);
        FlxG.collide(player, breakables);

        super.update(elapsed);
    }

    function onCollidePlayerMoney(_player : Player, money : Money)
    {
        money.onCollideWithPlayer(_player);
    }
}
