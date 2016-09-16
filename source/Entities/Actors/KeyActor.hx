package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class KeyActor extends ToolActor
{
    public static var Yellow : String = "YELLOW";
    public static var Green : String = "GREEN";
    public static var Red : String = "RED";

    static var colors : Array<String> = [Yellow, Green, Red];

    var overlay : FlxSprite;
    var invulnerable : Bool;
    var currentColor : String;

    public function new(X : Float, Y : Float, World : World, Color : String = null, ?Slide : Bool = true)
    {
        super(X, Y, World, "KEY", Color, false);

        loadGraphic("assets/images/key.png");
        setSize(8, 17);
        offset.set(3, 1);
        x += offset.x;
        y += offset.y;

        overlay = new FlxSprite(x, y).loadGraphic("assets/images/key_over.png");

        // The Y is specified as base y
        y -= height;

        setColor(Color);
        invulnerable = false;

        if (Slide)
            slide(world.player);
    }

    override public function onCollisionWithTool(tool : Tool)
    {
        if (!invulnerable)
        {
            invulnerable = true;

            new FlxTimer().start(0.2, function(t:FlxTimer){
                t.cancel();
                t.destroy();
                invulnerable = false;
            });

            changeColor();
        }
    }

    override public function update(elapsed)
    {
        super.update(elapsed);
        overlay.x = x - offset.x;
        overlay.y = y - offset.y;
    }

    override public function draw()
    {
        super.draw();
        overlay.draw();
    }

    public function changeColor()
    {
        var next : String = currentColor;
        while (next == currentColor)
        {
            next = FlxG.random.getObject(colors);
        }

        setColor(next);
    }

    public function setColor(Color : String)
    {
        switch (Color)
        {
            case "YELLOW":
                color = 0xFF4DFFFF;
            case "GREEN":
                color = 0xFF00FF4D;
            case "RED":
                color = 0xFFFF004D;
            default:
                color = FlxG.random.color();
        }

        currentColor = Color;
        property = currentColor;
    }
}
