package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxCamera;
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
    public var initialized : Bool;
    public var deadState : Bool;
    var deadMenu : Bool;
    var deadText : FlxText;

    public var hud : HUD;

    public var player : Player;
    public var tools : FlxGroup;

    public var npcs : FlxGroup;

    public var hazards : FlxGroup;
    public var enemies : FlxGroup;

    public var items : FlxGroup;
    public var moneys : FlxGroup;
    public var breakables : FlxGroup;

    public var teleports : FlxGroup;
    public var solids : FlxGroup;

    public var entities : FlxTypedGroup<Entity>;
    public var messages : FlxGroup;
    public var messageQueue : Array<Message>;

    public var scene : TiledScene;
    public var sceneName : String;
    public var spawnDoor : String;

    public function new(?Scene : String = null, ?Door : String = null, ?Dir : String = null)
    {
        super();

        sceneName = Scene;
        spawnDoor = Door;
    }

    override public function create()
    {
        initialized = false;
        deadState = false;
        deadMenu = false;

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
        npcs = new FlxGroup();

        messages = new FlxGroup();
        hud = new HUD();

        // Setup level elements
        setupLevel();
        add(entities);
        add(messages);
        add(hud);

        // Setup the world bounds and camera
        var bounds : FlxRect = scene.getBounds();
        FlxG.camera.setScrollBoundsRect(bounds.x-60, bounds.y, bounds.width+60, bounds.height);
		FlxG.worldBounds.set(bounds.x-60, bounds.y, bounds.width+60, bounds.height);
        FlxG.camera.follow(player);

        // Setup the world state
        deadState = false;
        messageQueue = [];

        // Init all entities
        for (entity in entities)
        {
            entity.onInit();
        }

        // Store the game state if required
        handleGameState();

        initialized = true;

        // And delegate to the parent
        super.create();
    }

    function setupLevel()
    {
        // Load the scene
        scene = loadScene(sceneName);

        // Add stored actors
        loadStoredActors(sceneName);

        // And add the player
        spawnPlayer();
    }

    function spawnPlayer()
    {
        var spawnPoint : FlxPoint = null;
        var direction : String = null;

        // If no entry point provided, try with hospital
        if (spawnDoor == null)
        {
            var hospital : ToolActor = findActorByName("HOSPTL");
            // If the hospital is located, spawn there
            if (hospital != null && Std.is(hospital, Hospital))
            {
                spawnPoint = hospital.getMidpoint();
            }
            // Else try with a "spawn" point
            else
            {
                spawnDoor = "SPAWN";
            }
        }

        if (spawnPoint == null)
        {
            // Locate provided door or spawn
            var teleport : Teleport = findTeleportByName(spawnDoor);
            if (teleport != null)
            {
                spawnPoint = teleport.spawnPoint;
                direction = teleport.direction;
            }
            else
            {
                throw "NO SUITABLE PLAYER POSITION FOUND";
            }
        }

        player = new Player(spawnPoint.x, spawnPoint.y, this);
        player.face(direction);
        entities.add(player);
    }

    override public function update(elapsed : Float)
    {
        if (deadState)
        {
            if (deadMenu)
            {
                if (FlxG.keys.justReleased.A ||
                    FlxG.keys.justReleased.S ||
                    FlxG.keys.justReleased.ENTER)
                {
                    storeSceneActors();
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
        else
        {
            handleDebugRoutines();

            FlxG.overlap(player, moneys, onCollidePlayerMoney);
            FlxG.overlap(player, hazards, onCollidePlayerHazard);
            FlxG.overlap(player, enemies, onCollidePlayerEnemy);
            FlxG.overlap(items);
        }

        FlxG.collide(player, solids);
        FlxG.collide(enemies, solids);
        FlxG.collide(items, solids);
        FlxG.collide(items, teleports);
        FlxG.collide(tools, solids);
        FlxG.collide(moneys, solids);

        FlxG.collide(moneys);
        FlxG.collide(player, breakables);
        FlxG.collide(items);
        FlxG.collide(player, npcs);

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
            // player.onDead();

            var deadbg = new FlxSprite(60, 0);
            add(deadbg);
            deadbg.makeGraphic(500, 500, 0xFFFF004D);
            deadbg.alpha = 0.0;
            deadbg.scrollFactor.set(0, 0);

            FlxTween.tween(deadbg, {alpha:1.0}, 2, {startDelay: 2, ease: FlxEase.expoOut, onComplete:function(t:FlxTween){
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
        else if (Std.is(entity, KeyDoor))
            solids.add(entity);
        else if (Std.is(entity, NPC))
            npcs.add(entity);

        entities.add(entity);

        // Once the world has been initalized, init all entities automatically
        if (initialized)
        {
            entity.onInit();
        }
    }

    public function removeEntity(entity : Entity)
    {
        if (Std.is(entity, Breakable))
            breakables.remove(entity);
        else if (Std.is(entity, ToolActor))
            items.remove(entity);
        else if (Std.is(entity, Hazard))
            hazards.remove(entity);
        else if (Std.is(entity, Enemy))
            enemies.remove(entity);
        else if (Std.is(entity, Money))
            moneys.remove(entity);
        else if (Std.is(entity, Tool))
            tools.remove(entity);
        else if (Std.is(entity, Solid))
            solids.remove(entity);
        else if (Std.is(entity, Teleport))
            teleports.remove(entity);
        else if (Std.is(entity, KeyDoor))
            solids.remove(entity);
        else if (Std.is(entity, NPC))
            npcs.remove(entity);

        entities.remove(entity, true);
    }

    public function addMessage(messageList : Array<String>, ?callback : Void -> Void = null, ?cancelCallback : Void -> Void)
    {
        for (index in 0...messageList.length)
        {
            var message : String = messageList[index];
            var _callback : Void -> Void;
            if (index < messageList.length - 1)
                _callback = function() {
                    messages.add(messageQueue.shift());
                }
            else
                _callback = callback;

            var msg : Message = new Message(this, message, _callback, cancelCallback);
            messageQueue.push(msg);
        }

        messages.add(messageQueue.shift());
    }

    public function removeMessage(message : Message)
    {
        messages.remove(message);
    }

    public function cancelMessages()
    {
        for (message in messages)
        {
            cast (message, Message).cancel();
            message.destroy();
        }

        for (message in messageQueue)
        {
            messageQueue.remove(message);
            cast (message, Message).cancel();
            message.destroy();
        }
    }

    static function depthSort(Order : Int, EntA : FlxObject, EntB : FlxObject) : Int
    {
        if (Std.is(EntA, Entity) && cast(EntA, Entity).flat)
            return -1;
        else if (Std.is(EntB, Entity) && cast(EntB, Entity).flat)
            return 1;
        else if (Std.is(EntA, KeyDoor) && Std.is(EntB, KeyActor))
            return -1;
        else if (Std.is(EntB, KeyDoor) && Std.is(EntA, KeyActor))
            return 1;
        else
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

    function handleGameState()
    {
        // Store game state appropriately
        // Only store map if it has a spawn point
        var spawnPoint : Teleport = findTeleportByName("spawn");
        if (spawnPoint != null)
        {
            GameState.saveLocation(sceneName, spawnPoint.name);
        }
    }

    function findTeleportByName(name : String) : Teleport
    {
        var teleport : Teleport = null;
        for (point in teleports)
        {
            if (Std.is(point, Teleport))
            {
                teleport = cast(point, Teleport);
                if (teleport.name.toLowerCase() == name.toLowerCase())
                {
                    return teleport;
                }
            }
        }

        return null;
    }

    function findActorByName(name : String) : ToolActor
    {
        var actor : ToolActor = null;
        for (point in items)
        {
            if (Std.is(point, ToolActor))
            {
                actor = cast(point, ToolActor);
                if (actor.name.toLowerCase() == name.toLowerCase())
                {
                    return actor;
                }
            }
        }

        return null;
    }

    var num : Int = 0;
    public static var STORED_ACTORS : Array<String> = ["KEY", "HOSPTL"];
    override public function switchTo(next : FlxState) : Bool
    {
        // Check whether the transition has finished
        var transitionFinished : Bool = super.switchTo(next);
        // Store scene data only when transition has finished
        if (transitionFinished)
            storeSceneActors();
        // Return
        return transitionFinished;
    }

    function storeSceneActors()
    {
        var actors : Array<PositionItem> = [];
        // Before leaving, store important items!
        var actor : PositionItem = null;
        for (item in items)
        {
            if (Std.is(item, ToolActor))
            {
                actor = (cast (item, ToolActor)).getPositionItem();
                if (actor != null && STORED_ACTORS.indexOf(actor.name) >= 0)
                    actors.push(actor);
            }
        }

        GameState.storeActors(sceneName, actors);

        GameState.printActors();
    }

    function loadStoredActors(scene : String)
    {
        var actors : Array<PositionItem> = GameState.actors.get(scene);
        if (actors != null && actors.length > 0)
        {
            var actor : ToolActor = null;
            for (posItem in actors)
            {
                switch (posItem.name)
                {
                    case "HOSPTL":
                        actor = new Hospital(posItem.x, posItem.y, this);
                    case "KEY":
                        actor = new KeyActor(posItem.x, posItem.y, this, posItem.property, false);
                    default:
                        actor = new ToolActor(posItem.x, posItem.y, this, posItem.name, posItem.item.property);
                        trace("Load " + posItem.name + " at (" + posItem.x + ", " + posItem.y + ")");
                }

                if (actor != null)
                {
                    addEntity(actor);
                    actor = null;
                }
            }
        }
    }

    function handleDebugRoutines()
    {
        /*#if neko
        if (FlxG.keys.justPressed.E)
        {
            if (Sys.command("tiled", ["./assets/scenes/" + scene.name + ".tmx"]) == 0)
                FlxG.resetState();
        }
        #end*/

        var snapX : Int = snap(FlxG.mouse.x, 20);
        var snapY : Int = snap(FlxG.mouse.y, 20);

        if (FlxG.keys.pressed.CONTROL)
        {
            if (FlxG.keys.justPressed.R)
            {
                GameController.DeadContinue();
            }
            else if (FlxG.keys.justReleased.S)
            {
                storeSceneActors();
                GamePersistence.save();
            }
            else if (FlxG.keys.justReleased.L)
            {
                GamePersistence.load();
            }
        }
        else
        {
            if (FlxG.keys.justPressed.ONE)
                addEntity(new KeyDoor(snapX, snapY, this, null, FlxG.random.getObject([KeyActor.Green, KeyActor.Red, KeyActor.Yellow])));
            else if (FlxG.keys.justPressed.TWO)
                addEntity(new KeyActor(snapX, snapY+20, this, "GREEN"));
            else if (FlxG.keys.justPressed.THREE)
                // addEntity(new Hazard(snapX, snapY, this));
                addEntity(new TargetShooter(snapX, snapY, this));
            else if (FlxG.keys.justPressed.FOUR)
                addEntity(new Hospital(snapX, snapY+20, this));
            else if (FlxG.keys.justPressed.FIVE)
                addEntity(new Idler(snapX, snapY, this));
            else if (FlxG.keys.pressed.SIX)
            {
                var money : Money = null;
                for (i in 0...FlxG.random.int(1, 10))
                {
                    money = new Money(FlxG.mouse.x + FlxG.random.int(-5, 5), FlxG.mouse.y + FlxG.random.int(-5, 5), this, FlxG.random.getObject([1, 5, 10]));
                    addEntity(money);
                }
            }
            else if (FlxG.keys.justPressed.SEVEN)
                addEntity(new HazardSpikes(snapX, snapY, this, true, 2, 2));
            else if (FlxG.keys.justPressed.EIGHT)
            {
                var npc : NPC = new NPC(snapX, snapY, this, "I was made for loving you baby and I was made for loving you.\nI was made for loving you \tbaby\t ok?\n\nYES THANKYOU THANK YOU");
                npc.setupGraphic("player_sheet", 20, 20, "2", 10);
                addEntity(npc);
            }
            else if (FlxG.keys.justPressed.R)
            {
                bgColor = FlxG.random.color();
            }
            else if (FlxG.keys.justPressed.K)
            {
                GameState.setFlag("k-flag", !GameState.getFlag("k-flag"));
                trace("K-FLAG: " + GameState.getFlag("k-flag"));
            }
        }

        if (FlxG.keys.justPressed.D)
        {
            GameState.printActors();
        }
    }
}
