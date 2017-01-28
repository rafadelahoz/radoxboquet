package;

import flixel.FlxG;
import flixel.FlxObject;

class SpawnArea
{
    var x : Float;
    var y : Float;
    var w : Int;
    var h : Int;
    var elements : Map<String, String>;
    var world : World;

    public function new(X : Float, Y : Float, World : World, Width : Int, Height : Int, Elements : Map<String, String>)
    {
        x = X;
        y = Y;
        world = World;

        w = Width;
        h = Height;

        elements = Elements;
    }

    public function onInit()
    {
        var xx, yy : Float;
        var tries : Int;
        var value : String;
        var number : Null<Int>;
        var enemy : Enemy;

        var tester : FlxObject = new FlxObject(0, 0);
        tester.setSize(20, 20);

        for (element in elements.keys())
        {
            // Fetch the specified value for the element
            value = elements.get(element);

            // It can be a range
            if (value.indexOf("...") > 0)
            {
                var tokens : Array<String> = value.split("...");
                number = FlxG.random.int(Std.parseInt(tokens[0]),
                                        Std.parseInt(tokens[1]));
            }
            else
            {
                // It can be a number
                number = Std.parseInt(value);
            }

            // Or just 1 if everything else fails
            if (number == null)
            {
                trace("Spawning 1 " + element + " as '" +
                        value + "' can't be parsed");
                number = 1;
            }

            for (times in 0...number)
            {
                xx = FlxG.random.float(x, x+w-20);
                yy = FlxG.random.float(y, y+h-20);

                tries = 0;

                while ((tester.overlapsAt(x, y, world.solids) ||
                        tester.overlapsAt(x, y, world.enemies)) && tries < 100)
                {
                    xx = FlxG.random.float(x, x+w-20);
                    yy = FlxG.random.float(y, y+h-20);
                    tries++;
                }

                if (tries >= 100)
                    trace("Aborting spawn of " + element + ", no space found?");

                enemy = EnemySpawner.spawn(xx, yy, element, world);

                if (enemy != null)
                    world.addEntity(enemy);
            }
        }
    }
}
