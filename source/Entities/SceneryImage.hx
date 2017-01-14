package;

class SceneryImage extends Entity
{
    public function new(X : Float, Y : Float, World : World, Image : String, SolidHeight : Int = 0)
    {
        super(X, Y, World);

        loadGraphic("assets/scenery/" + Image);

        // Pending baseline
        if (SolidHeight > 0)
        {
            world.addEntity(new Solid(x, y + (height-SolidHeight), world, Std.int(width), SolidHeight));
        }
    }
}
