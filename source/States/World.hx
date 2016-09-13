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
    
    public var solids : FlxGroup;
    public var hazards : FlxGroup;
    
    public var items : FlxGroup;
    public var moneys : FlxGroup;
    public var breakables : FlxGroup;

    override public function create()
    {
        // bgColor = new FlxRandom().color();
        // add(new FlxBackdrop("assets/scenery/bg_1.png"));

        solids = new FlxGroup();
        add(solids);

        moneys = new FlxGroup();
        add(moneys);

        breakables = new FlxGroup();
        add(breakables);

        items = new FlxGroup();
        add(items);

        items.add(new ToolActor(200, 140, this, "SWORD"));
        items.add(new ToolActor(360, 60, this, "MONKEY"));        

        hazards = new FlxGroup();
        add(hazards);
        
        tools = new FlxGroup();
        add(tools);

        player = new Player(100, 100, this);
        add(player);

        hud = new HUD();
        add(hud);

        FlxG.camera.setScrollBoundsRect(0, 0, 2560, 2560);
		FlxG.worldBounds.set(0, 0, 2560, 2560);
        
        FlxG.camera.follow(player);
    }

    override public function update(elapsed : Float)
    {
        if (FlxG.keys.justPressed.ONE)
            breakables.add(new Breakable(20*Std.int(FlxG.mouse.x/20), 20*Std.int(FlxG.mouse.y/20), this));
        else if (FlxG.keys.justPressed.TWO)
            items.add(new ToolActor(20*(Std.int(FlxG.mouse.x/20)), 20*Std.int(FlxG.mouse.y/20), this, "CORPSE"));
        else if (FlxG.keys.justPressed.THREE)
            hazards.add(new Hazard(20*Std.int(FlxG.mouse.x/20), 20*Std.int(FlxG.mouse.y/20), this));

        FlxG.overlap(player, moneys, onCollidePlayerMoney);
        FlxG.overlap(player, hazards, onCollidePlayerHazard);
        
        FlxG.collide(player, solids);
        FlxG.collide(player, breakables);

        super.update(elapsed);
    }

    function onCollidePlayerMoney(_player : Player, money : Money)
    {
        money.onCollisionWithPlayer(_player);
    }
    
    function onCollidePlayerHazard(_player : Player, hazard : Hazard)
    {
        hazard.onCollisionWithPlayer(_player);
    }
}
