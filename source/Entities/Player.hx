package;

import flixel.FlxG;

class Player extends Entity
{
    public static var IDLE : Int = 0;
    public static var ACTION : Int = 1;

    var WalkSpeed : Float = 100;

    var state : Int;
    var currentTool : Tool;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        loadGraphic("assets/images/player_sheet.png", true, 20, 20);
        animation.add("idle", [0, 1], 4);
        animation.add("walk", [0, 1], 10);
        animation.add("act!", [1]);

        animation.play("idle");

        state = IDLE;
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case Player.IDLE:
                onIdleState(elapsed);
            case Player.ACTION:
                onActingState(elapsed);
        }

        // Delegate
        super.update(elapsed);
    }

    function onIdleState(elapsed : Float)
    {
        if (FlxG.keys.justPressed.A)
        {
            state = ACTION;
            handleAction();
            return;
        }

        // Horizontal movement
        if (FlxG.keys.pressed.LEFT)
            velocity.x = -WalkSpeed;
        else if (FlxG.keys.pressed.RIGHT)
            velocity.x = WalkSpeed;
        else
            velocity.x = 0;

        // Vertical movement
        if (FlxG.keys.pressed.UP)
            velocity.y = -WalkSpeed;
        else if (FlxG.keys.pressed.DOWN)
            velocity.y = WalkSpeed;
        else
            velocity.y = 0;

        // Animation handling
        if (velocity.x != 0 || velocity.y != 0)
            animation.play("walk");
        else
            animation.play("idle");

        // Facing
        if (velocity.x > 0)
            flipX = false;
        else if (velocity.x < 0)
            flipX = true;
    }

    function onActingState(elapsed : Float)
    {
        // ?
        animation.play("act!");
        velocity.set(0, 0);
    }

    function handleAction()
    {
        var tool : Item = GameState.items[GameState.currentItem];
        switch (tool.name)
        {
            case "SWORD":
                world.add(new Sword(x, y, world));
            default:
                trace("used " + tool.name);
                onToolFinish(null);
        }

        velocity.set(0, 0);
    }

    public function onToolFinish(tool : Tool)
    {
        state = IDLE;
    }
}
