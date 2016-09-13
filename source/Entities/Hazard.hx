package;

class Hazard extends Entity
{
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);
        
        makeGraphic(20, 20, 0xFFFF004D);
    }
    
    public function onCollisionWithPlayer(player : Player)
    {
        player.onCollisionWithHazard(this);
    }
}