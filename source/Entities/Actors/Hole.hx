package;

class Hole extends Entity
{
    public function new(X : Float, Y : Float, World : World, Width : Int, Height : Int)
    {
        super(X, Y, World);

        makeGraphic(Width, Height, 0x10DDDDDD);
        immovable = true;
    }
}
