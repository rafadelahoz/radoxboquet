package;

import flixel.FlxG;

class SpawnArea
{
    public function new(X : Float, Y : Float, World : World, Width : Int, Height : Int, Elements : Map<String, Int>)
    {
        var x, y : Float;
        var number : Int;
        for (element in Elements.keys())
        {
            x = FlxG.random.float(X, X+Width-20);
            y = FlxG.random.float(Y, Y+Height-20);
            number : Int = Elements.get(element);
            for (times in 0...number)
            {
                 : FlxG.random
                switch (element)
                {
                    case "twitcher":
                        var twitcher : Twitcher = new Twitcher(x, y, World);
                        World.addEntity(twitcher);
                    case "targetshooter":
                        var shooter : TargetShooter = new TargetShooter(x, y, World);
                        World.addEntity(shooter);
                    case "randomwalker":
                        var walker : RandomWalker = new RandomWalker(x, y, World);
                        World.addEntity(walker);
                    case "idler":
                        var idler : Idler = new Idler(x, y, World);
                        World.addEntity(idler);
                }
            }
        }
    }
}
