package;

class Enemy extends Entity
{
    var player : Player;
    
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);
        
        player = world.player;
        
        onInit();
    }
    
    public function onInit()
    {
        // override
    }
    
    public function onCollisionWithPlayer(player : Player)
    {
        // override
    }
    
    public function onCollisionWithTool(tool : Tool)
    {
        // override
    }
}