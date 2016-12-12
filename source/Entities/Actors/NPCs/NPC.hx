package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

class NPC extends Entity
{
    var player : Player;
    var tween : FlxTween;

    public var enabled : Bool;

    public var configs : Array<NPCConfig>;
    public var currentConfig : NPCConfig;

    public var interactions : Array<String>;

    /*public var messages : Array<String>;
    public var commands : Array<String>;*/

    public var face : String;
    public var canTurn : Bool;
    public var canFlip : Bool;

    var tester : FlxObject;

    public function new(X : Float, Y : Float, World : World, Message : String, ?Face : String = null, ?CanTurn : Bool = true, ?CanFlip : Bool = true)
    {
        super(X, Y, World);
        immovable = true;

        // loadGraphic("assets/images/npc_dummy.png");
        makeGraphic(20, 20, 0xFF4DFF10);
        alpha = 0.1;

        interactions = ["\"" + Message + "\""];

        canTurn = CanTurn;
        canFlip = CanFlip;

        configs = [];
        currentConfig = null;
        enabled = true;
        tween = null;

        tester = new FlxObject(x, y);

        setFace(Face, true);

        // Random facing if can flip
        if (canTurn && Face == null)
        {
            if (FlxG.random.bool(50))
                setFace("right", true);
            else
                setFace("left", true);
        }

        placeTester();

        player = world.player;
    }

    public function setFace(towards : String, ?force : Bool = false)
    {
        if (towards == null || towards == "")
            face = "right";
        else
            face = towards.toLowerCase();

        if (canFlip || force)
        {
            switch (face)
            {
                case "left":
                    flipX = true;
                case "right":
                    flipX = false;
            }
        }

        placeTester();
    }

    public function setupGraphic(asset : String, ?w : Float = -1, ?h : Float = -1, ?frames : String = null, ?speed : Int = 10, ?PlaceTester : Bool = true)
    {
        if (asset != null && asset.length > 0)
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
                    for (frame in frames.substring(1, frames.length-1).split(","))
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
            {
                makeGraphic(Std.int(w), Std.int(h), 0x00000000);
            }
        }

        if (PlaceTester)
            placeTester();
    }

    function placeTester()
    {
        if (!enabled)
        {
            tester.solid = false;
            tester.x = -1;
            tester.y = -1;
        }
        else if (solid)
        {
            if (face == "right")
            {
                tester.x = x + width + 10;
                tester.y = y + height - 10;
            }
            else
            {
                tester.x = x - 10;
                tester.y = y + height - 10;
            }
        }
        else
        {
            canTurn = false;
            canFlip = false;
            tester.x = getMidpoint().x;
            tester.y = getMidpoint().y;
        }
    }

    public function setupConfigurations(Configs : Array<NPCConfig>)
    {
        configs = Configs;
        loadDefaultConfig();
    }

    override public function update(elapsed : Float)
    {
        // Switch configs only when not interacting (so sprite won't change mid-dialogue)
        if (world.state != World.INTERACT)
        {
            checkConditions();
        }

        // Turn if someone is behind and we can turn
        if (canTurn)
        {
            if (face == "left" && tester.overlapsAt(x + width + 10, tester.y, world.player))
                setFace("right");
            else if (face == "right" && tester.overlapsAt(x - 10, tester.y, world.player))
                setFace("left");
        }

        super.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
    }

    public function canInteract(other : Entity) : Bool
    {
        if (!enabled)
            return false;

        var ignoreFacing : Bool = !solid;

        // We can interact if:
        // - we don't care about facing, or
        // - we are facing each other
        // and we are close to each other
        var otherLeft : Bool = other.x < x;
        return ((ignoreFacing || (otherLeft && !other.flipX) || (!otherLeft && other.flipX))
                && tester.overlaps(other));
    }

    public function onInteract()
    {
        if (interactions.length > 0)
        {
            tween = FlxTween.tween(this.scale, {x: 1.1, y: 1.1}, 0.2, {type: FlxTween.PINGPONG});

            var actions : Array<Interaction> = InteractionBuilder.buildList(world, interactions);

            // Actually build interactions
            world.setupInteraction(actions, onMessageFinish, onMessageCancel);

            /*world.showMessage(messages, onMessageFinish, onMessageCancel);*/
        }
        else
        {
            onMessageFinish();
        }
    }

    public function onMessageFinish()
    {
        /*if (commands.length > 0)
            executeCommands();*/

        onMessageCancel();
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
                canTurn = config.canturn;
                canFlip = config.canflip;
                visible = config.visible;
                flat = config.flat;

                if (config.graphic_asset != null)
                {
                    setupGraphic(config.graphic_asset, config.graphic_width,
                                config.graphic_height, config.graphic_frames,
                                config.graphic_speed, false);
                }

                if (config.face != null)
                    setFace(config.face.toLowerCase());

                interactions = config.interactions;
                // commands = config.commands;
            }
            else
            {
                visible = false;
                solid = false;
            }

            placeTester();
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
                case "true":
                    value = true;
                case "false":
                    value = false;
                case "flag":
                    value = GameState.getFlag(tokens[1]);
                case "has":
                    value = GameState.hasItem(tokens[1]);
                case "door":
                    value = GameState.isDoorOpen(world.sceneName, tokens[1]);
                default:
                    trace("Unknown condition: " + cond);
            }

            return (negated ? !value : value);
        }
    }
}
