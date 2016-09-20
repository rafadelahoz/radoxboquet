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
        y -= height;

        setSize(14, 14);
        offset.set(1, 1);
        x += offset.x;
        y += offset.y;

        if (Slide)
            slide(world.player);
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);
    }
}
