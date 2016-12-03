package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Hospital extends ToolActor
{
    public function new(X : Float, Y : Float, World : World, ?Slide : Bool = false)
    {
        super(X, Y, World, "HOSPTL", false);

        loadGraphic("assets/images/hospital.png");

        setSize(14, 14);
        offset.set(3, 6);
        x += offset.x;
        y += offset.y;

        y -= (offset.y + height);

        if (Slide)
            slide(world.player);
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);
    }

    override public function getStoragePositionY() : Int
    {
        return Std.int(y - offset.y + (offset.y + height));
    }
}
