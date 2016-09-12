package;



class Money extends Entity
{
    var value : Int = 0;

    public function new(X : Float, Y : Float, World : World, Value : Int)
    {
        super(X, Y, World);

        loadGraphic("assets/images/money.png", true, 12, 12);

        value = Value;
        switch (value)
        {
            case 1:
                animation.add("idle", [1]);
            case 5:
                animation.add("idle", [2]);
            case 10:
                animation.add("idle", [0]);
        }

        animation.play("idle");
    }

    public function onCollideWithPlayer(player : Player)
    {
        GameState.money += value;
        // TODO: Play sound
        destroy();
    }
}
