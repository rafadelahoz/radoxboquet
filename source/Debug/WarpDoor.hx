package;

import sys.FileSystem;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;

class WarpDoor extends FlxGroup
{
    var path : String = "assets/scenes";

    var x : Float;
    var y : Float;
    var width : Int;
    var height : Int;

    var scenes : Array<String>;
    var current : Int;
    var listSize : Int;

    var scenesGroup : FlxGroup;

    public function new()
    {
        super();

        x = 70;
        y = 10;
        width = 120;
        height = FlxG.height - 20;

        var bg : FlxSprite = new FlxSprite(x, y);
        bg.makeGraphic(width, height, 0xFF040404);
        bg.scrollFactor.set(0, 0);
        add(bg);

        scenesGroup = new FlxGroup();
        add(scenesGroup);

        scenes = [];

        if (FileSystem.exists(path) && FileSystem.isDirectory(path))
        {
            for (element in FileSystem.readDirectory(path))
            {
                if (!FileSystem.isDirectory(path + "/" + element))
                {
                    var extPos : Int = element.lastIndexOf(".");
                    var ext : String = element.substring(extPos+1, element.length);
                    if (ext.toUpperCase() == "TMX")
                        scenes.push(element.substring(0, extPos));
                }
            }
        }

        current = 0;
        listSize = 9;

        drawScenes();
    }

    function drawScenes()
    {
        for (element in scenesGroup.members)
        {
            element.destroy();
        }

        scenesGroup.clear();

        var xx : Float = x + 5;
        var yy : Float = y + 5;
        var height : Int = 18;

        var scene : String = null;
        var last : Int = Std.int(Math.min(current+listSize, scenes.length));
        trace("Showing from " + current + " to " + last);
        for (index in current...last)
        {
            scene = scenes[index];
            scenesGroup.add(new WarpItem(xx, yy, scene));
            yy += height;
        }

        scenesGroup.add(new WarpItem(xx, yy, "...", nextPage));
    }

    function nextPage()
    {
        current += listSize;
        if (current >= scenes.length)
            current = 0;

        trace("Next page is " + current);

        drawScenes();
    }

    override public function update(elapsed : Float)
    {
        if (FlxG.keys.justReleased.W)
        {
            destroy();
            return;
        }

        super.update(elapsed);
    }
}

class WarpItem extends FlxText
{
    var handler : Void -> Void;

    public function new(X : Float, Y : Float, Text : String, ?Handler : Void -> Void = null)
    {
        super(X, Y);
        text = Text;
        setFormat("assets/data/adventurePixels.ttf", 16);
        scrollFactor.set(0, 0);

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
            FlxG.switchState(new World(text));
        }
    }
}
