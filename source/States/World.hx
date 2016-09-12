package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxRandom;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxBackdrop;

class World extends FlxState
{
    public var hud : HUD;
    public var player : Player;
    public var tools : FlxGroup;
    public var items : FlxGroup;

    public var moneys : FlxGroup;
    public var breakables : FlxGroup;

    override public function create()
    {
        bgColor = new FlxRandom().color();
        add(new FlxBackdrop("assets/scenery/bg_1.png"));

        moneys = new FlxGroup();
        add(moneys);

        breakables = new FlxGroup();
        add(breakables);

        items = new FlxGroup();
        add(items);

        items.add(new ToolActor(200, 140, this, "SWORD"));
        items.add(new ToolActor(360, 60, this, "MONKEY"));        

        tools = new FlxGroup();
        add(tools);

        player = new Player(100, 100, this);
        add(player);

        hud = new HUD();
        add(hud);

        FlxG.camera.follow(player);
    }

    override public function update(elapsed : Float)
    {
        if (FlxG.mouse.justPressed)
        {
            breakables.add(new Breakable(20*Std.int(FlxG.mouse.x/20), 20*Std.int(FlxG.mouse.y/20), this));
            items.add(new ToolActor(20*(Std.int(FlxG.mouse.x/20)+1), 20*Std.int(FlxG.mouse.y/20), this, "CORPSE"));
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
