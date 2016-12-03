package;

class FuelCanisterComponent implements IFuelComponent
{
    var owner : Entity;
    var fuel : Int;
    var fps : Int; // Fuel (used) per step

    public function new(Owner : Entity, InitialFuel : Int, ?FuelPerStep : Int = 1)
    {
        owner = Owner;
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
        if (fuel <= 0)
        {
            fuel = 0;
            owner.onFuelDepleted();
        }
    }
}
