package;

import flixel.util.FlxTimer;

class CurativeItem
{
    public static var initialized : Bool = false;

    public static var items : Array<String>;
    public static var itemPower : Map<String, Int>;
    public static var itemDelay : Map<String, Float>;

    static function init()
    {
        if (!initialized)
        {
            initialized = true;

            // Do the thing
            items = [];

            itemPower = new Map<String, Int>();
            itemDelay = new Map<String, Float>();

            initItem("APPFEL", 25, 0.2);
            initItem("KEBABS", 50, 1);
            initItem("TASTY1", 13, 0.1);
            initItem("TASTY2", 33, 0.1);
            initItem("FOODIN", 70, 0.78);
        }
    }

    static function initItem(name : String, power : Int, delay : Float)
    {
        items.push(name);
        itemPower.set(name, power);
        itemDelay.set(name, delay);
    }

    static function getPower(item : Item) : Int
    {
        var id : String = item.name;
        // Try to use the property also
        if (item.property != null)
            id += ";" + item.property;
        // If with the property we get nothing, try just with the name
        if (!itemPower.exists(id))
            id = item.name;

        var power : Int = itemPower.get(id);
        if (power == null)
            return -1;
        return power;
    }

    static function getDelay(item : Item) : Float
    {
        var id : String = item.name;
        // Try to use the property also
        if (item.property != null)
            id += ";" + item.property;
        // If with the property we get nothing, try just with the name
        if (!itemDelay.exists(id))
            id = item.name;

        var delay : Float = itemDelay.get(id);
        if (delay == null)
            return 0.2;
        return delay;
    }

    public static function is(item : Item) : Bool
    {
        init();

        return items.indexOf(item.name) >= 0;
    }

    public static function onUse(player : Player, item : Item)
    {
        init();

        var power : Int = getPower(item);
        if (power > 0)
        {
            GameState.removeItem(item);
            GameState.addHP(power);
            // Wait for a sec!
            new FlxTimer().start(getDelay(item), function(t:FlxTimer) {
                player.onToolFinish(null);
                t.destroy();
            });
        }
    }
}
