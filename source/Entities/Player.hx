package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;

class Player extends Entity
{
    public static var IDLE      : Int = 0;
    public static var ACTION    : Int = 1;
    public static var HURT      : Int = 2;

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
        animation.add("hurt", [1]);

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
            case Player.HURT:
                onHurtState(elapsed);
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

        if (FlxG.keys.justPressed.S)
        {
            var item : FlxObject = findClosestEntity(world.items);
            if (item != null && Std.is(item, ToolActor))
            {
                if (overlaps(item))
                {
                    if (cast(item, ToolActor).onPickup())
                    {
                        // Play sound?
                    }
                }
            }
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

    function findClosestEntity(group : FlxGroup) : FlxObject
    {
        var me : FlxPoint = getMidpoint();
        me.y += height/2;
        var other : FlxPoint = FlxPoint.get();

        var closestDistance : Float = 1e10;
        var closestObject : FlxObject = null;

        var distance : Float = -1;
        var member : FlxObject = null;

        for (basic in group.members)
        {
            if (Std.is(basic, FlxObject))
            {
                member = cast(basic, FlxObject);
                if (member.alive && member.active)
                {
                    other = member.getMidpoint(other);
                    distance = me.distanceTo(other);
                    if (distance < closestDistance)
                    {
                        closestDistance = distance;
                        closestObject = member;
                    }
                }
            }
        }

        return closestObject;
    }

    function onActingState(elapsed : Float)
    {
        // ?
        animation.play("act!");
        velocity.set(0, 0);
    }

    function onHurtState(elapsed : Float)
    {
        animation.play("hurt");

        if (Math.abs(velocity.x) < 25 && Math.abs(velocity.y) < 25)
        {
            state = IDLE;
        }
    }

    function handleAction()
    {
        var tool : Item = GameState.items[GameState.currentItem];
        switch (tool.name)
        {
            case "SWORD":
                world.tools.add(new Sword(x, y, world));
            default:
                dropTool(tool);
        }

        velocity.set(0, 0);
    }

    function dropTool(tool : Item)
    {
        var right : Float = x + 18;
        var left : Float = x - 18;

        GameState.removeItem(tool);
        switch (tool.name)
        {
            case "CORPSE":
                world.items.add(new CorpseActor(flipX ? left : right, y, world));
            default:
                world.items.add(new ToolActor(flipX ? left : right, y, world, tool.name));
        }

        // Wait for a sec!
        new FlxTimer().start(0.16, function(t:FlxTimer) {
            onToolFinish(null);
            t.destroy();
        });
    }

    public function onToolFinish(tool : Tool)
    {
        state = IDLE;
    }

    public function onCollisionWithHazard(hazard : Hazard)
    {
        if (state != HURT)
        {
            var force : FlxPoint = getMidpoint();
            var hcenter : FlxPoint = hazard.getMidpoint();

            force.x -= hcenter.x;
            force.y -= hcenter.y;

            force.x *= 3;
            force.y *= 3;

            velocity.set(force.x, force.y);
            drag.set(100, 100);

            flipX = (force.x > 0);

            state = HURT;
            GameState.addHP(-5);
        }
    }
}
