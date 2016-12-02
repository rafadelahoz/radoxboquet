package;

class ActiveFuelComponent implements IFuelComponent
{
    public function new()
    {
        // ha
    }

    public inline function init() {}
    public inline function drawFuel() {}
    public inline function hasFuel() : Bool { return true; }
}
