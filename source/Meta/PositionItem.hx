package;

class PositionItem 
{
    public var x : Float;
    public var y : Float;
    public var item : Item;
    
    public var name(get, null) : String;
    public var property(get, null) : String;
    
    public function new(X : Float, Y : Float, Item : Item)
    {
        x = X;
        y = Y;
        item = Item;
    }
    
    public function get_name() : String
    {
        if (item == null)
            return null;
            
        return item.name;
    }
    
    public function get_property() : String
    {
        if (item == null)
            return null;
            
        return item.property;
    }
}