package;

import flixel.FlxG;
import flixel.FlxObject;

class SpawnArea
{
    public function new(X : Float, Y : Float, World : World, Width : Int, Height : Int, Elements : Map<String, Int>)
    {
        var x, y : Float;
        var number : Int;
        var enemy : Enemy;

        var tester : FlxObject = new FlxObject(0, 0);
        tester.setSize(20, 20);

        trace(Elements);

        for (element in Elements.keys())
        {
            number = Elements.get(element);
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
                }

                if (enemy != null)
                    World.addEntity(enemy);
            }
        }
    }
}
