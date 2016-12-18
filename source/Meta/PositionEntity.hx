package;

class PositionEntity
{
    public var x : Float;
    public var y : Float;
    public var type : String;
    public var name : String;
    public var property : String;

    public function new(X : Float, Y : Float, Type : String, Name : String, ?Property : String = null)
    {
        x = X;
        y = Y;
        type = Type;
        name = Name;
        property = Property;
    }
}
