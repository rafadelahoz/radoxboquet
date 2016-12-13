package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;

class Plate extends Entity
{
    var enemies : Array<String>;
    var door : String;

    var pressed : Bool;

    var overlapsPlayer : Bool;
    var overlapsEnemy : Bool;
    var overlapsItem : Bool;

    public function new(X : Float, Y : Float, World : World, Color : Int, Door : String, EnemyList : String)
    {
        super(X, Y, World);

        loadGraphic("assets/images/plate.png", true, 20, 20);
        animation.add("idle", [0]);
        animation.add("pressed", [1]);
        animation.play("idle");

        setSize(16, 16);
        centerOffsets(true);

        color = Color;
        door = Door;

        if (EnemyList != null && EnemyList.length > 0)
        {
            enemies = EnemyList.split(",");
            enemies = enemies.map(function(elem : String) : String {
                return StringTools.trim(elem);
            });
        }
        else
        {
            enemies = [];
        }

        flat = true;
        pressed = false;

        FlxG.watch.add(this, "pressed");
        FlxG.watch.add(this, "overlapsPlayer");
        FlxG.watch.add(this, "overlapsEnemy");
        FlxG.watch.add(this, "overlapsItem");
    }

    override public function onInit()
    {
        super.onInit();

        overlapsPlayer = overlaps(world.player);
        overlapsEnemy = checkOverlap(world.enemies);
        overlapsItem = checkOverlap(world.items);

        var overlapped : Bool = overlapsPlayer || overlapsEnemy || overlapsItem;

        if (door != null && !overlapped)
            GameState.closeDoor(world.sceneName, door);
    }

    override public function update(elapsed : Float)
    {
        overlapsPlayer = overlaps(world.player);
        overlapsEnemy = checkOverlap(world.enemies);
        overlapsItem = checkOverlap(world.items);

        var overlapped : Bool = overlapsPlayer || overlapsEnemy || overlapsItem;

        if (!pressed && overlapped)
        {
            playSfx("click1", false);
            pressed = true;

            var handled : Bool = false;

            if (overlapsItem)
                handled = onOverlapItem();

            if (!handled && overlapsEnemy)
                handled = onOverlapEnemy();

            if (!handled && overlapsPlayer)
                onOverlapPlayer();
        }

        if (pressed && !overlapped)
        {
            playSfx("click2", false);
            pressed = false;
            if (door != null && door.length > 0 &&
                GameState.isDoorOpen(world.sceneName, door))
            {
                GameState.closeDoor(world.sceneName, door);
            }
        }

        if (pressed)
            animation.play("pressed");
        else
            animation.play("idle");

        super.update(elapsed);
    }

    function checkOverlap(Group : FlxGroup) : Bool
    {
        var overlapping : Bool = false;

        var iterator = Group.iterator(function(elem : FlxBasic) : Bool {
            var entity : Entity = cast(elem, Entity);
            return entity.alive && !entity.floating && entity.weights;
        });

        while (iterator.hasNext() && !overlapping)
        {
            overlapping = overlaps(iterator.next());
        }

        return overlapping;
    }

    function onOverlapPlayer() : Bool
    {
        var handled : Bool = false;

        // Chose random position
        var pos : FlxPoint = getRandomPosition(20, 20);
        // Spawn configured enemy
        var enemy : String = FlxG.random.getObject(enemies);
        if (EnemySpawner.isEnemy(enemy))
        {
            var spawned : Enemy = EnemySpawner.spawn(pos.x, pos.y, enemy, world);
            if (spawned != null)
            {
                world.addEntity(spawned);
                world.addEntity(new Smoke(spawned.getMidpoint(), world));
                handled = true;
            }
        }

        pos.destroy();

        return handled;
    }

    function onOverlapEnemy() : Bool
    {
        for (item in world.enemies.members)
        {
            if (item.alive && Std.is(item, Enemy))
            {
                var enemy : Enemy = cast(item, Enemy);
                if (enemy.weights && !enemy.floating && this.overlaps(enemy))
                {
                    var midpoint : FlxPoint = getMidpoint();
                    FlxTween.tween(enemy, {x : midpoint.x-enemy.width/2, y : midpoint.y-enemy.height/2}, 0.7);
                    new FlxTimer().start(0.7, function(t:FlxTimer) {
                        t.destroy();
                        // Choose random position
                        var pos : FlxPoint = getRandomPosition(20, 20);
                        // Spawn key
                        var key : KeyActor = new KeyActor(pos.x, pos.y, world);
                        // Add key entity
                        world.addEntity(key);
                        // Add spawn smoke
                        world.addEntity(new Smoke(key.getMidpoint(), world));

                        // Add de-spawn smoke
                        world.addEntity(new Smoke(enemy.getMidpoint(), world));
                        // Remove enemy
                        enemy.kill();
                        enemy.destroy();

                        pos.destroy();
                    });

                    midpoint.destroy();
                }
            }
        }

        return true;
    }

    function onOverlapItem() : Bool
    {
        // If key:
        for (item in world.items.members)
        {
            if (item.alive && Std.is(item, ToolActor))
            {
                var actor : ToolActor = cast(item, ToolActor);
                if (actor.weights && !actor.floating && overlaps(actor))
                {
                    if (actor.name == "KEY")
                    {
                        if (door != null && door.length > 0)
                        {
                            trace("Open Door");
                            // Open target door
                            GameState.openDoor(world.sceneName, door);
                            // Destroy key??
                            actor.flash(0xFFFFFFFF, 0.6, actor.color);
                            return true;
                        }
                    }
                }
            }
        }

        return false;
    }

    function getRandomPosition(?Width : Int = 20, ?Height : Int = 20) : FlxPoint
    {
        var radius : Int = 50;
        var tester : FlxObject = new FlxObject(0, 0, Width, Height);
        var position : FlxPoint = new FlxPoint(x, y);

        var group : FlxGroup = new FlxGroup();
        group.add(world.solids);
        group.add(world.npcs);
        group.add(world.enemies);
        group.add(world.items);
        group.add(world.player);

        var obj : FlxObject = new FlxObject(x - radius/2, y - radius/2, width + radius, height + radius);
        group.add(obj);

        var tries : Int = 0;

        while (tester.overlapsAt(position.x, position.y, group) && tries < 100)
        {
            position.x = FlxG.random.int(Std.int(x-radius), Std.int(x+radius));
            position.y = FlxG.random.int(Std.int(y-radius), Std.int(y+radius));
            tries += 1;
        }

        group.clear();
        group.destroy();
        obj.destroy();
        tester.destroy();
        return position;
    }
}
