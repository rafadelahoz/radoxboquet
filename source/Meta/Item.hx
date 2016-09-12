package;

class Item
{
    public var name : String;
    public var property : String;

    public function new(Name : String, ?Property : String = null)
    {
        name = Name;
        property = Property;
    }
}
