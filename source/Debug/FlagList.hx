package;

import sys.FileSystem;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;

class FlagList extends FlxGroup
{
    var x : Float;
    var y : Float;
    var width : Int;
    var height : Int;

    var flags : Array<String>;
    var current : Int;
    var listSize : Int;

    var itemsGroup : FlxGroup;

    public function new()
    {
        super();

        x = 200;
        y = 10;
        width = FlxG.width - 190;
        height = FlxG.height - 20;

        var bg : FlxSprite = new FlxSprite(x, y);
        bg.makeGraphic(width, height, 0xFF040404);
        bg.scrollFactor.set(0, 0);
        add(bg);

        itemsGroup = new FlxGroup();
        add(itemsGroup);

        flags = [];

        for (flag in GameState.flags.keys())
        {
            flags.push(flag);
        }

        current = 0;
        listSize = 9;

        drawItems();
    }

    function drawItems()
    {
        for (element in itemsGroup.members)
        {
            element.destroy();
        }

        itemsGroup.clear();

        var xx : Float = x + 5;
        var yy : Float = y + 5;
        var height : Int = 18;

        var item : String = null;
        var last : Int = Std.int(Math.min(current+listSize, flags.length));
        for (index in current...last)
        {
            item = flags[index];
            itemsGroup.add(new FlagItem(xx, yy, item));
            yy += height;
        }

        if (flags.length > listSize)
            itemsGroup.add(new FlagItem(xx, yy, "...", nextPage));
    }

    function nextPage()
    {
        current += listSize;
        if (current >= flags.length)
            current = 0;

        drawItems();
    }

    override public function update(elapsed : Float)
    {
        if (FlxG.keys.justReleased.F)
        {
            destroy();
            return;
        }

        super.update(elapsed);
    }
}

class FlagItem extends FlxText
{
    var handler : Void -> Void;
    var flagName : String;

    public function new(X : Float, Y : Float, Text : String, ?Handler : Void -> Void = null)
    {
        super(X, Y);
        flagName = Text;

        setFormat("assets/data/adventurePixels.ttf", 16);
        scrollFactor.set(0, 0);

        setupLabel();

        handler = Handler;
    }

    override public function update(elapsed : Float)
    {
        var rect : FlxRect = new FlxRect(x, y, width, height);
        if (rect.containsPoint(new FlxPoint(FlxG.mouse.screenX, FlxG.mouse.screenY)))
        {
            color = 0xFFFF004D;
            if (FlxG.mouse.justPressed)
            {
                onClick();
                return;
            }
        }
        else
            color = 0xFFFFFFFF;

        super.update(elapsed);
    }

    function onClick()
    {
        if (handler != null)
            handler();
        else
        {
            GameState.setFlag(flagName, !GameState.getFlag(flagName));
            setupLabel();
        }
    }

    function setupLabel()
    {
        text = flagName + " - " +
                (GameState.getFlag(flagName) ? "TRUE" : "FALSE");
    }
}
