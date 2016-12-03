package;

class Fire extends Hazard
{
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        solid = false;

        flammable = true;
        fuelComponent = new EndlessFuelComponent();
        // fuelComponent = new TimedFuelComponent(true, 1, 1);
        // fuelComponent = new FuelCanisterComponent(20);

        makeGraphic(20, 20, 0x00403030);
    }

    public function setupEndlessFire() : Fire
    {
        fuelComponent = new EndlessFuelComponent();
        return this;
    }

    public function setupTimedFire(?StartActive : Bool = false, ActiveTime : Float = 4.0, ?InactiveTime : Float = -1) : Fire
    {
        fuelComponent = new TimedFuelComponent(StartActive, ActiveTime, InactiveTime);
        return this;
    }

    public function setupFuelCanisterFire(Fuel : Int) : Fire
    {
        fuelComponent = new FuelCanisterComponent(this, Fuel);
        return this;
    }

    override public function onInit()
    {
        super.onInit();
        fuelComponent.init();

        currentFlame = new Flame(this);
        world.addEntity(currentFlame);
    }
}
