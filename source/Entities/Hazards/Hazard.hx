package;

class Hazard extends Entity
{
    public var power : Int = 5;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);
        flat = true;
    }

    public function onCollisionWithPlayer(player : Player)
    {
        player.onCollisionWithHazard(this);
    }
}
