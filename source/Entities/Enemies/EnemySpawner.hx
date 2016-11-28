package;

class EnemySpawner
{
    static var enemies = ["twitcher", "targetshooter", "randomwalker", "idler",
                            "charger", "thrower", "follower", "bouncy"];
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
                enemy = new Twitcher(X, Y, World);
            case "targetshooter":
                enemy = new TargetShooter(X, Y, World);
            case "randomwalker":
                enemy = new RandomWalker(X, Y, World);
            case "idler":
                enemy = new Idler(X, Y, World);
            case "charger":
                enemy = new Charger(X, Y, World);
            case "thrower":
                enemy = new Thrower(X, Y, World);
            case "follower":
                enemy = new Follower(X, Y, World);
            case "bouncy":
                enemy = new BouncySpikes(X, Y, World);
            default:
                trace("Not spawning anything for " + Enemy);
                enemy = new Enemy(X, Y, World);
        }

        return enemy;
    }
}
