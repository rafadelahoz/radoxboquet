package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRandom;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;

class World extends FlxState
{
    public var deadState : Bool = false;
    var deadMenu : Bool = false;
    var deadText : FlxText;

    public var hud : HUD;

    public var player : Player;
    public var tools : FlxGroup;
    
    public var solids : FlxGroup;
    public var hazards : FlxGroup;
    public var enemies : FlxGroup;

    public var items : FlxGroup;
    public var moneys : FlxGroup;
    public var breakables : FlxGroup;

    override public function create()
    {
        bgColor = new FlxRandom().color();
        // add(new FlxBackdrop("assets/scenery/dummy_bg.png"));

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

        FlxG.watch.add(items, "members.get(0)");

        hazards = new FlxGroup();
        add(hazards);
        
        enemies = new FlxGroup();
        add(enemies);

        tools = new FlxGroup();
        add(tools);

        player = new Player(100, 100, this);
        add(player);

        hud = new HUD();
        add(hud);

        FlxG.camera.setScrollBoundsRect(0, 0, 2560, 2560);
		FlxG.worldBounds.set(0, 0, 2560, 2560);

        FlxG.camera.follow(player);

        deadState = false;
    }

    override public function update(elapsed : Float)
    {
        if (!deadState)
        {
            var snapX : Int = snap(FlxG.mouse.x, 20);
            var snapY : Int = snap(FlxG.mouse.y, 20);
            
            if (FlxG.keys.justPressed.ONE)
                breakables.add(new Breakable(snapX, snapY, this));
            else if (FlxG.keys.justPressed.TWO)
                items.add(new CorpseActor(snapX, snapY+20, this));
            else if (FlxG.keys.justPressed.THREE)
                hazards.add(new Hazard(snapX, snapY, this));
            else if (FlxG.keys.justPressed.FOUR)
                items.add(new ToolActor(snapX, snapY, this, "WOMBAT"));
            else if (FlxG.keys.justPressed.FIVE)
                enemies.add(new Twitcher(snapX, snapY, this));
            else if (FlxG.keys.pressed.SIX)
            {
                var money : Money = null;
                for (i in 0...FlxG.random.int(1, 10))
                {
                    money = new Money(FlxG.mouse.x + FlxG.random.int(-5, 5), FlxG.mouse.y + FlxG.random.int(-5, 5), this, FlxG.random.getObject([1, 5, 10]));
                    moneys.add(money);
                }
            }

            FlxG.overlap(player, moneys, onCollidePlayerMoney);
            FlxG.overlap(player, hazards, onCollidePlayerHazard);
            FlxG.overlap(player, enemies, onCollidePlayerEnemy);

            FlxG.collide(moneys);
            FlxG.collide(player, solids);
            FlxG.collide(player, breakables);
        }
        else
        {
            if (deadMenu)
            {
                if (FlxG.keys.justReleased.A ||
                    FlxG.keys.justReleased.S ||
                    FlxG.keys.justReleased.ENTER)
                {
                    GameController.DeadContinue();
                }

                if (FlxG.keys.justPressed.A ||
                    FlxG.keys.justPressed.S ||
                    FlxG.keys.justPressed.ENTER)
                {
                    deadText.text += "\nOK";
                }
            }
        }

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
    
    function onCollidePlayerEnemy(_player : Player, enemy : Enemy)
    {
        enemy.onCollisionWithPlayer(_player);
    }

    public function onPlayerDead()
    {
        trace("PLAYER DEAD");
        if (!deadState)
        {
            deadState = true;

            hud.onPlayerDead();

            var deadbg = new FlxSprite(60, 0);
            add(deadbg);
            deadbg.makeGraphic(500, 500, 0xFFFF004D);
            deadbg.alpha = 0.2;
            deadbg.scrollFactor.set(0, 0);

            FlxTween.tween(deadbg, {alpha:1.0}, 1, {ease: FlxEase.expoOut, onComplete:function(t:FlxTween){
                t.cancel();
                deadText = HUD.buildLabel(FlxG.width/2, FlxG.height/2, "TRY HARDER?");
                deadText.alignment = FlxTextAlign.CENTER;
                deadText.scrollFactor.set(0, 0);
                add(deadText);

                deadMenu = true;
            }});
        }
    }
    
    public static function snap(value : Float, ?grid : Int = 20)
    {
        return grid*Std.int(value/grid);
    }
}
