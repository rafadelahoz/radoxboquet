package;

import flixel.FlxSprite;

class Entity extends FlxSprite
{
    var world : World;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y);
        this.world = World;
    }
}
