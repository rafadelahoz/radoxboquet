package;

class Fire extends Hazard
{
    var flame : Flame;
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        solid = false;

        flammable = true;
        fuelComponent = new ActiveFuelComponent();
        // fuelComponent = new TimedFuelComponent(true, 1, 1);
        // fuelComponent = new FuelCanisterComponent(20);

        makeGraphic(20, 20, 0x00403030);
    }

    override public function onInit()
    {
        super.onInit();
        fuelComponent.init();

        flame = new Flame(this);
        world.addEntity(flame);
    }

    override public function destroy()
    {
        flame.destroy();
        super.destroy();
    }
}
