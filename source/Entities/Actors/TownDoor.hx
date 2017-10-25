package;

class TownDoor extends Entity
{
    public function new(X : Float, Y : Float, World : World, ?CanOpen : Bool = false, ?Index : Int = 1)
    {
        super(X, Y, World);

        loadGraphic("assets/images/doors.png", true, 20, 20);
        animation.add("open", [0])
        animation.add("closed", [Index]);
        animation.play("closed");
    }
}
