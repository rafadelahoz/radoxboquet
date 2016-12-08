package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class Message extends FlxGroup implements Interaction
{
    var x : Float;
    var y : Float;

    var world : World;

    var textField : FlxText;
    var text : String;
    var bg : FlxSprite;

    var state : Int;
    var timer : FlxTimer;

    public function new(World : World, Text : String)
    {
        super();

        x = 80;
        y = 20;

        world = World;
        text = processText(Text);
        state = 0;

        textField = new FlxText(x+6, y+8, 268);
        textField.setFormat("assets/data/adventurePixels.ttf", 16);
        textField.text = text;
        textField.scrollFactor.set(0, 0);

        bg = new FlxSprite(x, y);
        bg.makeGraphic(280, Std.int(textField.height + 16), 0xFF000000);
        bg.scrollFactor.set(0, 0);

        var topBorder : FlxSprite = new FlxSprite(x, y, "assets/images/text_border.png");
        topBorder.scrollFactor.set(0, 0);
        var bottomBorder : FlxSprite = new FlxSprite(x, bg.y + bg.height - 8, "assets/images/text_border.png");
        bottomBorder.scrollFactor.set(0, 0);

        add(bg);
        add(topBorder);
        add(bottomBorder);
        add(textField);

        timer = new FlxTimer();
        timer.start(0.1, function(t:FlxTimer){
            t.cancel();

            state += 1;
        });
    }

    override public function destroy()
    {
        world.removeInteraction(this);
        super.destroy();
    }

    public function cancel()
    {
        kill();
    }

    override public function update(elapsed : Float)
    {
        if (onUpdate())
            super.update(elapsed);
    }

    public function onUpdate() : Bool
    {
        if (state == 1 && Gamepad.justPressedA())
        {
            state += 1;
            textField.scale.set(1, 0.5);
        }
        else if (state == 2 && Gamepad.justReleasedA())
        {
            world.onInteractionEnd();

            kill();
            destroy();

            return false;
        }

        return true;
    }

    function processText(message : String) : String
    {
        // Perform substitutions and tidying on the provided text
        message = message.toUpperCase();
        message = StringTools.replace(message, "@NAME", GameState.name);
        message = StringTools.replace(message, "@LN", "\n");

        return message;
    }
}
