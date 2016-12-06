package;

import flixel.FlxG;

class Plate extends Entity
{
    var pressed : Bool;

    var overlapsPlayer : Bool;
    var overlapsEnemy : Bool;
    var overlapsItem : Bool;

    public function new(X : Float, Y : Float, World : World, Color : Int)
    {
        super(X, Y, World);

        loadGraphic("assets/images/plate.png", true, 20, 20);
        animation.add("idle", [0]);
        animation.add("pressed", [1]);
        animation.play("idle");

        setSize(16, 16);
        centerOffsets(true);

        this.color = Color;

        flat = true;
        pressed = false;

        FlxG.watch.add(this, "pressed");
        FlxG.watch.add(this, "overlapsPlayer");
        FlxG.watch.add(this, "overlapsEnemy");
        FlxG.watch.add(this, "overlapsItem");
    }

    override public function update(elapsed : Float)
    {
        overlapsPlayer = overlaps(world.player);
        overlapsEnemy = overlaps(world.enemies);
        overlapsItem = overlaps(world.items);

        var overlapped : Bool = overlapsPlayer || overlapsEnemy || overlapsItem;

        if (!pressed && overlapped)
        {
            playSfx("click1");
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
            playSfx("click2");
            pressed = false;
        }

        if (pressed)
            animation.play("pressed");
        else
            animation.play("idle");

        super.update(elapsed);
    }

    function onOverlapPlayer() : Bool
    {
        // Chose random position
        // Spawn configured enemy
        return true;
    }

    function onOverlapEnemy() : Bool
    {
        // Choose random position
        // Spawn key
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
                if (actor.name == "KEY")
                {
                    trace("Open Door");
                    // Open target door
                    // Destroy key??
                    return true;
                }

            }
        }

        return false;
    }
}
