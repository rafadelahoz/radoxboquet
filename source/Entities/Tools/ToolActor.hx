package;

class ToolActor extends Entity
{
    public var name : String;
    public var property : String;

    public function new(X : Float, Y : Float, World : World, Name : String, ?Property : String = null)
    {
        super(X, Y, World);

        name = Name;
        property = Property;

        makeGraphic(15, 15, 0xFF2AF035);

        switch (name)
        {
            case "SWORD":
                //....
            case "CORPSE":
                loadGraphic("assets/images/corpse.png");
                setSize(20, 13);
                offset.set(0, 6);
                y += 6;
            default:
        }
    }

    public function onPickup() : Bool
    {
        if (GameState.addItem(name, property))
        {
            kill();
            destroy();
            world.items.remove(this);
            return true;
        }
        else
        {
            return false;
        }
    }

    public function onCollisionWithTool(tool : Tool)
    {
        // override!
    }
}
