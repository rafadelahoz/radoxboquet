package;

class Tool extends Entity
{
    var player : Player;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);
        player = World.player;

        onActivate();
    }

    function onActivate()
    {
    }

    function onFinish()
    {
        player.onToolFinish(this);
    }
}
