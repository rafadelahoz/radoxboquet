package;

class EnemySpawner
{
    static var enemies = ["twitcher", "targetshooter", "randomwalker", "idler",
                            "charger", "thrower", "follower", "bouncy", "badcrop"];

    public static function isEnemy(Enemy : String) : Bool
    {
        return enemies.indexOf(Enemy) > -1;
    }

    public static function spawn(X : Float, Y : Float, Enemy : String, World : World) : Enemy
    {
        var enemy : Enemy = null;

        switch (Enemy.toLowerCase())
        {
            case "twitcher":
                enemy = new Twitcher(X, Y, World, Enemy);
            case "targetshooter":
                enemy = new TargetShooter(X, Y, World, Enemy);
            case "randomwalker":
                enemy = new RandomWalker(X, Y, World, Enemy);
            case "idler":
                enemy = new Idler(X, Y, World, Enemy);
            case "charger":
                enemy = new Charger(X, Y, World, Enemy);
            case "thrower":
                enemy = new Thrower(X, Y, World, Enemy);
            case "follower", "badcrop":
                enemy = new Follower(X, Y, World, Enemy);
            case "bouncy":
                enemy = new BouncySpikes(X, Y, World, Enemy);
            default:
                trace("Not spawning anything for " + Enemy);
                enemy = new Enemy(X, Y, World);
        }

        return enemy;
    }

    public static function getTypeName(enemy : Enemy)
    {
        if (Std.is(enemy, BouncySpikes))
            return "bouncy";
        if (Std.is(enemy, Charger))
            return "charger";
        if (Std.is(enemy, Follower))
            return "follower";
        if (Std.is(enemy, Idler))
            return "idler";
        if (Std.is(enemy, RandomWalker))
            return "randomwalker";
        if (Std.is(enemy, TargetShooter))
            return "targetshooter";
        if (Std.is(enemy, Thrower))
            return "thrower";
        if (Std.is(enemy, Twitcher))
            return "twitcher";

        throw "Unmapped enemy type: " + Type.typeof(enemy);
    }
}
