package;

class FuelCanisterComponent implements IFuelComponent
{
    var fuel : Int;
    var fps : Int; // Fuel (used) per step

    public function new(InitialFuel : Int, ?FuelPerStep : Int = 1)
    {
        fuel = InitialFuel;
        fps = FuelPerStep;
    }

    public inline function init() {}

    public function hasFuel() : Bool
    {
        return fuel > 0;
    }

    public function drawFuel() : Void
    {
        fuel -= fps;
        if (fuel < 0)
            fuel = 0;
    }
}
