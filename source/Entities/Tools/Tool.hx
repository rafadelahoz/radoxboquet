package;

class Tool extends Entity
{
    var player : Player;
    public var name : String;
    public var power : Int;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);
        player = World.player;
        name = "TOOL";

        power = 0;

        onActivate();
    }

    function onActivate()
    {
    }

    function onFinish()
    {
        player.onToolFinish(this);
    }

    public function cancel()
    {
        // Override for when the tool is ineffective
    }
}
