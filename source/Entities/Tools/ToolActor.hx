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
            default:
        }
    }

    public function onPickup() : Bool
    {
        if (GameState.addItem(name, property))
        {
            trace("Got " + name);
            destroy();
            return true;
        }
        else
        {
            return false;
        }
    }
}
