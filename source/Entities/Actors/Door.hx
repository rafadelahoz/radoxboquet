package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class Door extends Entity
{
    public var name : String;
    public var closed : Bool;

    public function new(X : Float, Y : Float, World : World, Name : String)
    {
        super(X, Y, World);

        loadGraphic("assets/images/grate_door.png");

        name = Name;

        if (name != null && GameState.isDoorOpen(world.sceneName, name))
            open();
        else
            close();
    }

    public function setupGrahic(asset : String)
    {
        var graphic : String = "assets/images/" + asset + ".png";
        loadGraphic(graphic);
    }

    override public function update(elapsed : Float)
    {
        onUpdate();
        super.update(elapsed);
    }

    public function onUpdate()
    {
        if (closed && GameState.isDoorOpen(world.sceneName, name))
        {
            open();
        }
        else if (!closed && !GameState.isDoorOpen(world.sceneName, name))
        {
            close();
        }
    }

    public function open()
    {
        closed = visible = solid = immovable = false;
    }

    public function close()
    {
        closed = visible = solid = immovable = true;
    }
}
