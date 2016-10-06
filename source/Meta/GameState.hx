package;

import flixel.FlxG;
import flixel.math.FlxRandom;

class GameState
{
    public static var MAXMONEY = 99999;

    public static var name : String = "WANDERER";

    public static var hp : Int = 100;
    public static var money : Int = 13;

    public static var items : Array<Item> = [];
    public static var currentItem : Int = 0;

    public static var flags : Map<String, Bool>;
    public static var doors : Map<String, Map<String, Bool>>;
    public static var actors : Map<String, Array<PositionItem>>;

    public static var savedScene : String;
    public static var savedSpawn : String;

    public static function init()
    {
        name = "WANDERER";

        hp = new FlxRandom().int(15, 100);
        money = 13;

        items = [];
        items.push(new Item(" SWORD"));
        items.push(new Item("BOWARR"));
        // items.push(new Item("FIRROD"));
        // items.push(new Item("KEY"));

        currentItem = 0;

        flags = new Map<String, Bool>();
        doors = new Map<String, Map<String, Bool>>();
        actors = new Map<String, Array<PositionItem>>();

        savedScene = "w2";
        savedSpawn = null;
    }

    public static function addHP(value : Int)
    {
        setHP(hp + value);
    }

    public static function setHP(value : Int)
    {
        hp = Std.int(Math.max(Math.min(value, 100), 0));

        if (hp <= 0)
        {
            trace("Player dead");
            if (Std.is(FlxG.state, World))
            {
                trace("Notify world");
                (cast(FlxG.state, World)).onPlayerDead();
            }
        }
    }

    public static function addItem(name : String, ?property : String = null) : Bool
    {
        if (items.length < 10)
        {
            items.push(new Item(name.toUpperCase(), property));
            currentItem = items.length-1;
            return true;
        }

        return false;
    }

    public static function removeItemWithData(name : String, ?property : String = null)
    {
        for (item in items)
        {
            if (item.name == name && (property == null || item.property == property))
            {
                removeItem(item);
                return;
            }
        }
    }

    public static function removeItem(item : Item)
    {
        items.remove(item);
        if (currentItem >= items.length)
            currentItem = items.length-1;
    }

    public static function hasItem(name : String)
    {
        for (item in items)
        {
            if (item.name.toUpperCase() == name.toUpperCase())
                return true;
        }

        return false;
    }

    public static function switchItem()
    {
        currentItem = (currentItem+1)%(Std.int(Math.min(items.length, 10)));
    }

    public static function addMoney(value : Int)
    {
        money += value;
        if (money < 0)
            money = 0;
        else if (money > MAXMONEY)
            money = MAXMONEY;
    }

    public static function getFlag(flag : String) : Bool
    {
        return flags.get(flag.toUpperCase());
    }

    public static function setFlag(flag : String, value : Bool)
    {
        flags.set(flag.toUpperCase(), value);
    }

    public static function isDoorOpen(scene : String, door : String) : Bool
    {
        if (scene == null || door == null)
            return false;

        if (doors[scene] != null)
        {
            if (doors[scene][door.toUpperCase()] != null)
            {
                return doors[scene][door.toUpperCase()];
            }
        }

        return false;
    }

    public static function openDoor(scene : String, door : String)
    {
        if (scene == null || door == null)
            return;

        if (doors[scene] == null)
        {
            doors[scene] = new Map<String, Bool>();
        }

        doors[scene][door.toUpperCase()] = true;
    }

    public static function saveLocation(scene : String, spawn : String)
    {
        savedScene = scene;
        savedSpawn = spawn;
    }

    public static function storeActors(scene : String, sceneActors : Array<PositionItem>)
    {
        actors.set(scene, sceneActors);
    }

    public static function findHospital() : String
    {
        for (scene in actors.keys())
        {
            var hospital : PositionItem = findActorByName("HOSPTL", scene);
            if (hospital != null)
                return scene;
        }

        return null;
    }

    public static function findActorByName(name : String, scene : String) : PositionItem
    {
        if (actors.get(scene) != null)
        {
            for (actor in actors.get(scene))
            {
                if (actor.name == name)
                {
                    return actor;
                }
            }
        }

        return null;
    }

    /** DEBUG AREA **/
    public static function printActors()
    {
        trace("DUMPING STORED ACTORS");
        for (scene in actors.keys())
        {
            trace("[" + scene + "]");
            for (posItem in actors.get(scene))
            {
                trace("\t" + posItem.item.name + (posItem.item.property == null ? "" : posItem.item.property) +
                    "@(" + posItem.x + ", " + posItem.y + ")");
            }
        }
    }

    public static function printFlags()
    {
        trace("DUMPING FLAGS");
        for (flag in flags.keys())
        {
            trace("  [" + (flags.get(flag) ? "X" : " ") + "]" + flag);
        }
    }
}
