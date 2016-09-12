package;

class Tool extends Entity
{
    var player : Player;
    public var name : String;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);
        player = World.player;
        name = "TOOL";

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
