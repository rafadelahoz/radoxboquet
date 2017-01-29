package;

class TownDoor extends Entity
{
    public function new(X : Float, Y : Float, World : World, ?Index : Int = 0)
    {
        super(X, Y, World);

        loadGraphic()
    }
}
