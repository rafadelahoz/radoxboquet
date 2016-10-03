package;

class NPCConfig
{
    public var condition : String;

    public var enabled : Bool;
    public var visible : Bool;
    public var solid : Bool;

    public var flip : Bool;
    public var flat : Bool;

    public var graphic_asset : String;
    public var graphic_width : Int;
    public var graphic_height : Int;
    public var graphic_frames : String;
    public var graphic_speed : Int;
    public var messages : Array<String>;

    public function new(Condition : String)
    {
        condition = Condition;
        messages = [];
        enabled = true;
        solid = true;
        visible = true;
        flat = false;
    }
}
