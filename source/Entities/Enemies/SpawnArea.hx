package;

import flixel.FlxG;
import flixel.FlxObject;

class SpawnArea
{
    public function new(X : Float, Y : Float, World : World, Width : Int, Height : Int, Elements : Map<String, String>)
    {
        var x, y : Float;
        var value : String;
        var number : Int;
        var enemy : Enemy;

        var tester : FlxObject = new FlxObject(0, 0);
        tester.setSize(20, 20);

        for (element in Elements.keys())
        {
            // Fetch the specified value for the element
            value = Elements.get(element);

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
                x = FlxG.random.float(X, X+Width-20);
                y = FlxG.random.float(Y, Y+Height-20);
                while (tester.overlapsAt(x, y, World.solids) ||
                        tester.overlapsAt(x, y, World.enemies))
                {
                    x = FlxG.random.float(X, X+Width-20);
                    y = FlxG.random.float(Y, Y+Height-20);
                }

                enemy = null;

                switch (element)
                {
                    case "twitcher":
                        enemy = new Twitcher(x, y, World);
                    case "targetshooter":
                        enemy = new TargetShooter(x, y, World);
                    case "randomwalker":
                        enemy = new RandomWalker(x, y, World);
                    case "idler":
                        enemy = new Idler(x, y, World);
                    default:
                        trace("Not spawning anything for " + element);
                }

                if (enemy != null)
                    World.addEntity(enemy);
            }
        }
    }
}
