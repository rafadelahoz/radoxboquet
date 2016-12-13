package;

import flixel.FlxG;

class Thesaurus
{
    /* Items and actor types */
    public static var Sword : String = "SWORD";
    public static var Bow : String = "BOWARR";
    public static var FireRod : String = "FIRROD";
    public static var Colorb : String = "COLORB";
    public static var Hospital : String = "HOSPTL";

    public static var Key : String = "KEY";

    public static var Corpse : String = "CORPSE";
    public static var Ashes : String = "ASHES";

    public static var EnemyType : String = "Enemy";
    public static var ActorType : String = "Actor";

    /* Save file managed actors */
    public static var SavefileManagedActors : Array<String> = [Key, Hospital];

    /* Room storage managed actors */
    public static var RoomStorageManagedActors : Array<String> = [Corpse];

    /* Color names */
    public static var Colors : Array<String> = [Yellow, Green, Red];
    public static var Yellow : String = "YELLOW";
    public static var Green : String = "GREEN";
    public static var Red : String = "RED";

    public static function getColorCode(Color : String) : Int
    {
        var color : Int = 0xFFFFFFFF;

        switch (Color)
        {
            case Thesaurus.Yellow:
                color = 0xFFffc700;
            case Thesaurus.Green:
                color = 0xFF00FF4D;
            case Thesaurus.Red:
                color = 0xFFFF004D;
            default:
                color = FlxG.random.color();
        }

        return color;
    }
}
