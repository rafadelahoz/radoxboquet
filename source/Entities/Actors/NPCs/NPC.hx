package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

class NPC extends Entity
{
    var player : Player;
    var tween : FlxTween;

    public var enabled : Bool;

    public var configs : Array<NPCConfig>;
    public var currentConfig : NPCConfig;

    public var messages : Array<String>;
    public var commands : Array<String>;
    // public var facing : Int;

    public var canFlip : Bool;
    public var hotspot : FlxPoint;
    public var backspot : FlxPoint;

    public function new(X : Float, Y : Float, World : World, Message : String, ?CanFlip : Bool = true)
    {
        super(X, Y, World);
        immovable = true;

        // loadGraphic("assets/images/npc_dummy.png");
        makeGraphic(20, 20, 0xFF4DFF10);
        alpha = 0.1;

        messages = [Message];
        commands = [];
        canFlip = CanFlip;

        configs = [];
        currentConfig = null;
        enabled = true;
        tween = null;

        hotspot = new FlxPoint();
        backspot = new FlxPoint();

        if (canFlip)
            flipX = FlxG.random.bool(50);

        setupHotspots();

        player = world.player;
    }

    public function setupGraphic(asset : String, ?w : Float = -1, ?h : Float = -1, ?frames : String = null, ?speed : Int = 10, ?SetupHotspots : Bool = true)
    {
        if (asset != null)
        {
            var graphic : String = "assets/images/" + asset + ".png";
            var animated : Bool = (w > 0 && h > 0 && speed > 0);

            if (!animated)
                loadGraphic(graphic);
            else
            {
                loadGraphic(graphic, true, Std.int(w), Std.int(h));
                var frarr : Array<Int> = [];
                var numFrames : Int = -1;

                if (frames != null && frames.charAt(0) == "[")
                {
                    for (frame in frames.substring(0, frames.length-1).split(","))
                    {
                        frarr.push(Std.parseInt(frame));
                    }
                }
                else
                {
                    if (frames == null)
                        numFrames = animation.frames;
                    else
                        numFrames = Std.parseInt(frames);

                    for (i in 0...numFrames)
                        frarr.push(i);
                }
                animation.add("idle", frarr, speed);
                animation.play("idle");
            }

            alpha = 1;
        }
        else
        {
            if (w > 0 && h > 0)
                makeGraphic(Std.int(w), Std.int(h), 0x00000000);
        }

        if (SetupHotspots)
            setupHotspots();
    }

    function setupHotspots()
    {
        if (!enabled)
        {
            hotspot.set(-1, -1);
            backspot.set(-1, -1);
        }
        else if (solid)
        {
            hotspot.set(x + width + 10, y + height - 10);
            if (canFlip)
                backspot.set(x - 10, y + height - 10);
        }
        else
        {
            hotspot.set(getMidpoint().x, getMidpoint().y);
            backspot.set(-1, -1);
        }
    }

    public function setupConfigurations(Configs : Array<NPCConfig>)
    {
        configs = Configs;
        loadDefaultConfig();
    }

    override public function update(elapsed : Float)
    {
        checkConditions();

        if (canFlip)
        {
            if (!flipX && canInteract(world.player, backspot))
            {
                flipX = true;
            }
            else if (flipX && canInteract(world.player, hotspot))
            {
                flipX = false;
            }
        }

        super.update(elapsed);
    }

    public function canInteract(other : Entity, ?spot : FlxPoint=null) : Bool
    {
        if (!enabled)
            return false;

        var ignoreFacing : Bool = false;
        if (spot == null)
        {
            if (!flipX || !solid)
                spot = hotspot;
            else
                spot = backspot;
        }
        else
        {
            ignoreFacing = true;
        }

        // We can interact if:
        // - we don't care about facing, or
        // - we are facing each other
        // and we are close to each other
        return ((ignoreFacing || other.flipX != flipX) &&
                other.getHitbox().containsPoint(spot));
    }

    public function onInteract()
    {
        if (messages.length > 0 || commands.length > 0)
        {
            tween = FlxTween.tween(this.scale, {x: 1.1, y: 1.1}, 0.2, {type: FlxTween.PINGPONG});
            world.addMessage(messages, onMessageFinish, onMessageCancel);
        }
        else
        {
            onMessageFinish();
        }
    }

    public function onMessageFinish()
    {
        if (commands.length > 0)
            executeCommands();

        onMessageCancel();
        world.player.onInteractionEnd();
    }

    public function onMessageCancel()
    {
        if (tween != null)
            tween.cancel();
        scale.set(1, 1);
    }

    function checkConditions()
    {
        var loadedSomething : Bool = false;

        for (config in configs)
        {
            if (config.condition != "default")
            {
                if (evalCondition(config.condition))
                {
                    loadedSomething = true;
                    loadConfig(config);
                    break;
                }
            }
        }

        if (!loadedSomething)
            loadDefaultConfig();
    }

    function loadDefaultConfig()
    {
        for (config in configs)
        {
            if (config.condition == "default")
            {
                loadConfig(config);
                return;
            }
        }
    }

    function loadConfig(config : NPCConfig)
    {
        // Load!
        if (currentConfig != config)
        {
            currentConfig = config;

            enabled = config.enabled;

            if (config.enabled)
            {
                visible = true;

                solid = config.solid;
                canFlip = config.flip;
                visible = config.visible;
                flat = config.flat;

                switch (config.face)
                {
                    case null:
                    case "left":
                        flipX = true;
                    case "right":
                        flipX = false;
                }

                if (config.graphic_asset != null)
                {
                    setupGraphic(config.graphic_asset, config.graphic_width,
                                config.graphic_height, config.graphic_frames,
                                config.graphic_speed, false);
                }

                messages = config.messages;
                commands = config.commands;
            }
            else
            {
                visible = false;
                solid = false;
            }

            setupHotspots();
        }
    }

    function evalCondition(condition : String) : Bool
    {
        if (condition == "default")
            return true;
        else
        {
            var cond = condition;
            var negated : Bool = false;
            var value : Bool = false;

            if (condition.charAt(0) == "!")
            {
                negated = true;
                cond = cond.substring(1, cond.length);
            }

            var tokens : Array<String> = cond.split(".");
            switch (tokens[0])
            {
                case "flag":
                    value = GameState.getFlag(tokens[1]);
                case "has":
                    value = GameState.hasItem(tokens[1]);
                default:
                    trace("Unknown condition: " + cond);
            }

            return (negated ? !value : value);
        }
    }

    function executeCommands()
    {
        var commands : Array<String> = currentConfig.commands;
        for (command in commands)
        {
            var tokens : Array<String> = command.split(" ");
            switch (tokens[0])
            {
                case "give":
                    var name : String = tokens[1];
                    var prop : String = null;
                    if (tokens.length > 1)
                        prop = tokens[2];
                    GameState.addItem(name, prop);
                case "remove":
                    var name : String = tokens[1];
                    var prop : String = null;
                    if (tokens.length > 1)
                        prop = tokens[2];
                    GameState.removeItemWithData(name, prop);
                case "set":
                    var value : Bool = tokens.length == 1 ||
                                        tokens[2].toLowerCase() == "true";
                    GameState.setFlag(tokens[1], value);
                case "switch":
                    GameState.setFlag(tokens[1], !GameState.getFlag(tokens[1]));
            }
        }
    }
}
