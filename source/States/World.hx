package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxSort;

class World extends FlxTransitionableState
{
    public var deadState : Bool = false;
    var deadMenu : Bool = false;
    var deadText : FlxText;

    public var hud : HUD;

    public var player : Player;
    public var tools : FlxGroup;

    public var hazards : FlxGroup;
    public var enemies : FlxGroup;

    public var items : FlxGroup;
    public var moneys : FlxGroup;
    public var breakables : FlxGroup;

    public var teleports : FlxGroup;
    public var solids : FlxGroup;

    public var entities : FlxTypedGroup<Entity>;

    public var scene : TiledScene;
    public var sceneName : String;
    public var spawnDoor : String;

    public function new(?Scene : String = null, ?Door : String = null, ?Dir : String = null)
    {
        if (Dir != null)
        {
            switch(Dir)
            {
                case "left":
                    FlxTransitionableState.defaultTransOut.direction.set(-1.0, 0);
                case "right":
                    FlxTransitionableState.defaultTransOut.direction.set(1.0, 0);
                case "up":
                    FlxTransitionableState.defaultTransOut.direction.set(0, -1.0);
                case "down":
                    FlxTransitionableState.defaultTransOut.direction.set(0, 1.0);
            }
        }

        // super(transIn, transOut);
        super();

        if (Scene == null)
            Scene = "w1";
        if (Door == null)
            Door = "spawn";

        sceneName = Scene;
        spawnDoor = Door;
    }

    override public function create()
    {
        bgColor = FlxG.random.color();
        // add(new FlxBackdrop("assets/scenery/dummy_bg.png"));

        entities = new FlxTypedGroup<Entity>();

        moneys = new FlxGroup();
        breakables = new FlxGroup();
        items = new FlxGroup();
        hazards = new FlxGroup();
        enemies = new FlxGroup();
        tools = new FlxGroup();
        solids = new FlxGroup();
        teleports = new FlxGroup();

        hud = new HUD();

        // Setup level
        setupLevel();
        add(entities);
        add(hud);

        var bounds : FlxRect = scene.getBounds();
        FlxG.camera.setScrollBoundsRect(bounds.x-60, bounds.y, bounds.width+60, bounds.height);
		FlxG.worldBounds.set(bounds.x-60, bounds.y, bounds.width+60, bounds.height);

        FlxG.camera.follow(player);

        deadState = false;
    }

    function setupLevel()
    {
        scene = loadScene(sceneName);

        // Locate spawn door
        var teleport : Teleport = null;
        for (point in teleports)
        {

            if (Std.is(point, Teleport))
            {
                teleport = cast(point, Teleport);
                if (teleport.name == spawnDoor)
                {
                    player = new Player(teleport.spawnPoint.x, teleport.spawnPoint.y, this);
                    player.face(teleport.direction);
                    entities.add(player);
                    return;
                }
            }
        }

        trace("Player to default position");
        player = new Player(100, 100, this);
        entities.add(player);
    }

    override public function update(elapsed : Float)
    {
        #if neko
        if (FlxG.keys.justPressed.E)
        {
            if (Sys.command("tiled", ["./assets/scenes/" + scene.name + ".tmx"]) == 0)
                FlxG.resetState();
        }
        #end

        if (!deadState)
        {
            var snapX : Int = snap(FlxG.mouse.x, 20);
            var snapY : Int = snap(FlxG.mouse.y, 20);

            if (FlxG.keys.justPressed.R)
                bgColor = FlxG.random.color();
            else if (FlxG.keys.justPressed.ONE)
                addEntity(new Breakable(snapX, snapY, this));
            else if (FlxG.keys.justPressed.TWO)
                addEntity(new KeyActor(snapX, snapY+20, this, "GREEN"));
            else if (FlxG.keys.justPressed.THREE)
                addEntity(new Hazard(snapX, snapY, this));
            else if (FlxG.keys.justPressed.FOUR)
                addEntity(new ToolActor(snapX, snapY+20, this, "WOMBAT"));
            else if (FlxG.keys.justPressed.FIVE)
                addEntity(new Twitcher(snapX, snapY, this));
            else if (FlxG.keys.pressed.SIX)
            {
                var money : Money = null;
                for (i in 0...FlxG.random.int(1, 10))
                {
                    money = new Money(FlxG.mouse.x + FlxG.random.int(-5, 5), FlxG.mouse.y + FlxG.random.int(-5, 5), this, FlxG.random.getObject([1, 5, 10]));
                    addEntity(money);
                }
            }

            FlxG.overlap(player, moneys, onCollidePlayerMoney);
            FlxG.overlap(player, hazards, onCollidePlayerHazard);
            FlxG.overlap(player, enemies, onCollidePlayerEnemy);

            /*scene.collideWithLevel(player);
            for (group in [enemies, items, tools])
                for (entity in group)
                    scene.collideWithLevel(cast(entity, FlxObject));*/
            FlxG.collide(player, solids);
            FlxG.collide(enemies, solids);
            FlxG.collide(items, solids);
            FlxG.collide(tools, solids);
            FlxG.collide(moneys, solids);

            FlxG.collide(moneys);
            FlxG.collide(player, breakables);
            FlxG.collide(items);
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

        entities.sort(depthSort);
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

    public function addEntity(entity : Entity)
    {
        if (Std.is(entity, Breakable))
            breakables.add(entity);
        else if (Std.is(entity, ToolActor))
            items.add(entity);
        else if (Std.is(entity, Hazard))
            hazards.add(entity);
        else if (Std.is(entity, Enemy))
            enemies.add(entity);
        else if (Std.is(entity, Money))
            moneys.add(entity);
        else if (Std.is(entity, Tool))
            tools.add(entity);
        else if (Std.is(entity, Solid))
            solids.add(entity);
        else if (Std.is(entity, Teleport))
            teleports.add(entity);

        entities.add(entity);
    }

    static function depthSort(Order : Int, EntA : FlxObject, EntB : FlxObject) : Int
    {
        return FlxSort.byValues(Order, EntA.y + EntA.height, EntB.y + EntB.height);
    }

    function loadScene(sceneName : String) : TiledScene
	{
		var scene = new TiledScene(this, sceneName);

		if (scene != null)
			add(scene.backgroundTiles);

		if (scene != null)
			scene.loadObjects(this);

		/*if (scene != null)
			add(scene.overlayTiles);*/

		return scene;
	}
}
