package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
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
    public static var INIT      : Int = 0;
    public static var GAMEPLAY  : Int = 1;
    public static var INTERACT  : Int = 2;
    public static var GAMEOVER  : Int = 3;

    var deadMenu : Bool;
    var deadText : FlxText;

    public var state : Int;

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

    public var interactionQueueCallback : Void -> Void;
    public var interactionQueueCancelCallback : Void -> Void;
    public var interactionQueue : Array<Interaction>;
    public var interactions : FlxGroup;

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
        state = INIT;
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

        interactions = new FlxGroup();
        hud = new HUD(this);

        // Setup level elements
        setupLevel();
        add(entities);
        add(interactions);
        add(hud);

        // Setup the world bounds and camera
        var bounds : FlxRect = scene.getBounds();
        FlxG.camera.setScrollBoundsRect(bounds.x-60, bounds.y, bounds.width+60, bounds.height);
		FlxG.worldBounds.set(bounds.x-60, bounds.y, bounds.width+60, bounds.height);
        FlxG.camera.follow(player);

        // Setup the world state
        interactionQueue = [];

        // Init all entities
        for (entity in entities)
        {
            entity.onInit();
        }

        // Store the game state if required
        handleGameState();

        // And delegate to the parent
        super.create();

        state = GAMEPLAY;
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
        switch (state)
        {
            case World.INIT:
                // Nop!
            case World.GAMEPLAY:
                handleDebugRoutines();
                handleCollisions();
            case World.INTERACT:
                // what
            case World.GAMEOVER:
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

                handleCollisions();
            default:
        }

        super.update(elapsed);

        entities.sort(depthSort);
    }

    function handleCollisions()
    {
        // debug: player ethereal when CONTROL
        if (FlxG.keys.pressed.CONTROL)
            player.solid = false;
        else
            player.solid = true;

        if (state == GAMEPLAY)
        {
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
        FlxG.collide(enemies, npcs);
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
        if (state != GAMEOVER)
        {
            state = GAMEOVER;

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
        else if (Std.is(entity, Door))
            solids.add(entity);
        else if (Std.is(entity, NPC))
            npcs.add(entity);

        entities.add(entity);

        // Once the world has been initalized, init all entities automatically
        if (state != INIT)
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
        else if (Std.is(entity, Door))
            solids.remove(entity);
        else if (Std.is(entity, NPC))
            npcs.remove(entity);

        entities.remove(entity, true);
    }

    /*public function showMessage(messageList : Array<String>, ?callback : Void -> Void = null, ?cancelCallback : Void -> Void)
    {
        var message : String;
        var msg : Message;

        for (index in 0...messageList.length)
        {
            message = messageList[index];
            msg = new Message(this, message);

            interactionQueue.push(msg);
        }

        interactionQueueCallback = callback;
        interactionQueueCancelCallback = cancelCallback;

        startInteraction();
    }*/

    public function setupInteraction(interactions : Array<Interaction>, ?callback : Void -> Void, ?cancelCallback : Void -> Void)
    {
        if (interactionQueue.length > 0)
            throw "Double interaction happening. That is bad.";

        interactionQueueCallback = callback;
        interactionQueueCancelCallback = cancelCallback;

        interactionQueue = interactions;

        startInteraction();
    }

    public function startInteraction()
    {
        if (state != INTERACT)
        {
            if (interactionQueue.length > 0)
            {
                player.state = Player.INTERACT;
                interactions.add(cast(interactionQueue.shift(), FlxBasic));
                state = INTERACT;
            }
            else
            {
                trace("No interaction defined");
                onInteractionEnd();
            }
        }
    }

    public function onInteractionEnd()
    {
        if (interactionQueue.length <= 0)
        {
            if (interactionQueueCallback != null)
                interactionQueueCallback();

            state = GAMEPLAY;
            player.onInteractionEnd();
        }
        else
        {
            var interaction : Interaction = interactionQueue.shift();
            interactions.add(cast(interaction, FlxBasic));
        }
    }

    public function removeInteraction(interaction : Interaction)
    {
        interactions.remove(cast(interaction, FlxBasic));
    }

    public function cancelInteraction()
    {
        for (interaction in interactions)
        {
            cast (interaction, Interaction).cancel();
            interaction.destroy();
        }

        for (interaction in interactionQueue)
        {
            interactionQueue.remove(interaction);
            interaction.cancel();
            cast(interaction, FlxBasic).destroy();
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
            // Remove the spawn point, as it won't be needed anymore
            spawnPoint.destroy();
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
                addEntity(new Idler(snapX, snapY, this));
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
            // DEBUG Increase, Decrease life
            else if (FlxG.keys.pressed.L)
                GameState.addHP(1);
            else if (FlxG.keys.pressed.O)
                GameState.addHP(-1);

            if (FlxG.keys.justPressed.D)
                GameState.printActors();
            else if (FlxG.keys.justPressed.F)
                GameState.printFlags();

            if (FlxG.keys.justPressed.P)
            {
                var prices : Map<Item, Int> = new Map<Item, Int>();
                var products : Array<Item> = [new Item("BANANA"), new Item("KEBABS"), new Item("ASWORD"), new Item("BOWARR"), new Item("HOMLES")];
                prices.set(products[0], 5);
                prices.set(products[1], 0);
                prices.set(products[2], 100);
                prices.set(products[3], 500);
                prices.set(products[4], 30);
                var msg : Message = new Shop(this, "Choose whatever you want, everything is of the finest quality", products, prices);

                setupInteraction([new Message(this, "Welcome!"), msg, new Message(this, "Thank you for your patronage")]);
            }
        }
    }
}
