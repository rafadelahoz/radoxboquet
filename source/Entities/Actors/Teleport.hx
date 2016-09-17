package;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;

class Teleport extends Entity
{
    public var name : String;
    public var target : String;
    public var door : String;
    public var direction : String;

    var rect : FlxRect;
    public var spawnPoint : FlxPoint;

    public function new(X : Float, Y : Float, World : World, Width : Int, Height : Int, Id : String, Target : String, Door : String, Dir : String)
    {
        super(X, Y, World);
        makeGraphic(Width, Height, 0x00000000);

        name = Id;
        direction = Dir;
        target = Target;
        door = Door;

        var border = 4;

        rect = new FlxRect(X+border, Y+border, Width-border, Height-border);
        spawnPoint = getMidpoint();

        switch (Dir.toLowerCase())
        {
            case "left":
                spawnPoint.x -= Width*0.75;
            case "right":
                spawnPoint.x += Width*0.75;
            case "up":
                spawnPoint.y -= Height*0.75;
            case "down":
                spawnPoint.y += Height*0.75;
        }

        if (target == null || target == "none")
        {
            kill();
            destroy();
        }
    }

    override public function update(elapsed : Float)
    {
        if (rect.containsPoint(world.player.getMidpoint()))
        {
            // Teleport!
            FlxG.switchState(new World(target, door, direction));
        }

        super.update(elapsed);
    }
}
