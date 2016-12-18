package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class KeyActor extends ToolActor
{
    var overlay : FlxSprite;
    var invulnerable : Bool;
    public var currentColor : String;
    public var keyId : String;

    public function new(X : Float, Y : Float, World : World, Color : String = null, ?Slide : Bool = true, ?Id : String = null)
    {
        super(X, Y, World, Thesaurus.Key, Color, false);

        loadGraphic("assets/images/key.png");
        setSize(8, 17);
        offset.set(3, 1);
        centerOffsets(true);

        overlay = new FlxSprite(x, y).loadGraphic("assets/images/key_over.png");

        // The Y is specified as base y
        y -= height;

        setColor(Color);
        invulnerable = false;

        if (Slide)
        {
            slide(world.player);
            //doSlide(getMidpoint(), world.player.getMidpoint(), 3);
        }

        // For unique keys, the id is built and checked vs flag list
        if (Id != null)
        {
            keyId = world.sceneName + "-" + Id;
            if (GameState.getFlag(keyId))
            {
                kill();
            }
            else
            {
                GameState.setFlag(keyId, true);
            }
        }
    }

    override public function onCollisionWithTool(tool : Tool)
    {
        if (!invulnerable)
        {
            invulnerable = true;

            new FlxTimer().start(0.6, function(t:FlxTimer){
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
        overlay.angle = angle;
        overlay.scale.set(scale.x, scale.y);
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
            next = FlxG.random.getObject(Thesaurus.Colors);
        }

        setColor(next);
        flash(0xFFFFFFFF, 0.6, color);
    }

    public function setColor(Color : String)
    {
        color = Thesaurus.getColorCode(Color);
        currentColor = Color;
        property = currentColor;
    }

    public static function spawn(X : Float, Y : Float, World : World, Color : String = null, ?Slide : Bool = true, ?Id : String = null)
    {
        var key : KeyActor = new KeyActor(X, Y, World, Color, Slide, Id);
        if (!key.alive)
        {
            key.destroy();
        }
        else
        {
            World.addEntity(key);
        }
    }
}
