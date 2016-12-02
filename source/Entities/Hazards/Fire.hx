package;

class Fire extends Hazard
{
    var flame : Flame;
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        flammable = true;
        fuelComponent = new ActiveFuelComponent();

        makeGraphic(20, 20, 0xFF403030);
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
