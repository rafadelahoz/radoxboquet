package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;

class Player extends Entity
{
    public static var DEAD      : Int = -1;
    public static var IDLE      : Int = 0;
    public static var ACTION    : Int = 1;
    public static var HURT      : Int = 2;
    public static var INTERACT  : Int = 3;

    var WalkSpeed : Float = 100;
    var InvincibleTime : Float = 0.7;

    var _state : Int;
    public var state (get, set) : Int;
    public var currentTool : Tool;

    public var invincible : Bool;
    var invincibleTimer : FlxTimer;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        loadGraphic("assets/images/player_sheet.png", true, 20, 20);
        animation.add("idle", [0, 1], 4);
        animation.add("walk", [1, 0], 10);
        animation.add("act!", [1]);
        animation.add("hurt", [1]);
        animation.add("dead", [2]);

        animation.play("idle");

        setSize(18, 18);
        offset.set(1, 1);

        x -= width/2;
        y -= height/2;

        FlxG.watch.add(this, "state");

        state = IDLE;
        invincible = false;
        invincibleTimer = new FlxTimer();
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
            case Player.INTERACT:
                onInteractState(elapsed);
            case Player.DEAD:
                onDeadState(elapsed);
        }

        // Delegate
        super.update(elapsed);
    }

    function get_state() : Int
    {
        return _state;
    }

    function set_state(nextState : Int) : Int
    {
        if (state != DEAD)
            _state = nextState;
        else
            trace("You can't cheat death");

        return state;
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
            for (entity in world.npcs)
            {
                if (Std.is(entity, NPC))
                {
                    var npc : NPC = cast(entity, NPC);
                    if (npc.canInteract(this))
                    {
                        state = INTERACT;
                        npc.onInteract();
                        return;
                    }
                }
            }

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

        if (FlxG.keys.justPressed.SPACE)
        {
            GameState.switchItem();
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
        {
            flipX = false;
        }
        else if (velocity.x < 0)
        {
            flipX = true;
        }

        // DEBUG: Player faster when CONTROL
        if (FlxG.keys.pressed.SHIFT)
        {
            velocity.x *= 2;
            velocity.y *= 2;
        }
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

        if (Math.abs(velocity.x) < 50 && Math.abs(velocity.y) < 50)
        {
            if (GameState.hp <= 0)
                onDead();
            else
                state = IDLE;
        }
    }

    function onInteractState(elapsed : Float)
    {
        animation.play("idle");
        velocity.set(0, 0);
        acceleration.set(0, 0);
    }

    function onDeadState(elapsed : Float)
    {
        solid = false;
        animation.play("dead");
        velocity.set(0, 0);
        acceleration.set(0, 0);
    }

    function handleAction()
    {
        var tool : Item = GameState.items[GameState.currentItem];

        if (CurativeItem.is(tool))
        {
            CurativeItem.onUse(this, tool);
        }
        else
        {
            switch (StringTools.trim(tool.name).toUpperCase())
            {
                case "SWORD":
                    currentTool = new Sword(x, y, world);
                    world.addEntity(currentTool);
                case "BOWARR":
                    currentTool = new Bow(x, y, world);
                    world.addEntity(currentTool);
                default:
                    dropTool(tool);
            }
        }

        velocity.set(0, 0);
    }

    function dropTool(tool : Item)
    {
        var right : Float = x + 18;
        var left : Float = x - 18;
        var ydelta : Float = FlxG.random.float(-3, 3);
        var down : Float = y+height+ydelta;

        // Don't place things on walls!
        if (!flipX)
        {
            while ((overlapsMapAt(right, y) || overlapsAt(right, y, world.teleports) || overlapsAt(right, y, world.npcs)) && right > x)
            {
                right -= 2;
            }
        }
        else
        {
            while ((overlapsMapAt(left, y) || overlapsAt(left, y, world.teleports) || overlapsAt(left, y, world.npcs)) && left < x)
            {
                left += 2;
            }
        }

        GameState.removeItem(tool);
        switch (tool.name)
        {
            case "CORPSE":
                world.addEntity(new CorpseActor(flipX ? left : right, down, world, true));
            case "KEY":
                world.addEntity(new KeyActor(flipX ? left : right, down, world, tool.property));
            case "HOSPTL":
                world.addEntity(new Hospital(flipX ? left : right, down, world, true));
            default:
                world.addEntity(new ToolActor(flipX ? left : right, down, world, tool.name));
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
        currentTool = null;
    }

    public function onCollisionWithHazard(hazard : Hazard)
    {
        onHurt(hazard.power, hazard);
    }

    public function onCollisionWithEnemy(enemy : Enemy)
    {
        onHurt(enemy.power, enemy);
    }

    function onHurt(damage : Int, cause : FlxObject)
    {
        if (!invincible && state != HURT && state != DEAD)
        {
            if (state == INTERACT)
            {
                world.cancelInteraction();
            }

            if (currentTool != null)
            {
                currentTool.destroy();
                currentTool = null;
            }

            hurtSlide(cause);
            state = HURT;
            GameState.addHP(-damage);
            flash(0xFF000000, true);
            shake();

            invincible = true;
            invincibleTimer.start(InvincibleTime, function(t:FlxTimer) {
                invincible = false;
            });
        }
    }

    public function onInteractionEnd()
    {
        state = IDLE;
    }

    public function onDead()
    {
        state = DEAD;

        // Lose money
        GameState.money = Std.int(GameState.money/2);

        flash(0xFF000000, 1, true);

        // Generate the lost money
        var midpoint : FlxPoint = getMidpoint();
        var generated : Int = 0;
        var money : Money = null;
        while (generated < GameState.money)
        {
            var value : Int = FlxG.random.getObject([1, 5, 10]);
            generated += value;
            money = new Money(midpoint.x + FlxG.random.int(-20, 20),
                            midpoint.y + FlxG.random.int(-20, 20),
                            world, value);
            world.addEntity(money);
        }
    }

    function hurtSlide(cause : FlxObject)
    {
        doSlide(getMidpoint(), cause.getMidpoint(), 10, 24, 400);
        flipX = (velocity.x > 0);
    }

    public function face(dir : String)
    {
        var cause : FlxPoint = new FlxPoint(x, y);

        if (dir != null)
        {
            switch(dir.toLowerCase())
            {
                case "left":
                    flipX = true;
                    cause.x += 10;
                case "right":
                    flipX = false;
                    cause.x -= 10;
                case "up":
                    cause.y += 10;
                case "down":
                    cause.y -= 10;
            }
        }

        doSlide(getMidpoint(), cause, 3, 24, 300);
    }
}
