package;

import flixel.FlxG;
import flixel.math.FlxRandom;

class GameState
{
    public static var MAXMONEY = 99999;

    public static var hp : Int = 100;
    public static var money : Int = 13;

    public static var items : Array<Item> = [];
    public static var currentItem : Int = 0;

    public static var doors : Map<String, Map<String, Bool>>;
    public static var actors : Map<String, Array<PositionItem>>;

    public static var savedScene : String;
    public static var savedSpawn : String;
    public static var hospitalX : Float;
    public static var hospitalY : Float;

    public static function init()
    {
        hp = new FlxRandom().int(15, 100);
        money = 13;

        items = [];
        items.push(new Item(" SWORD"));
        items.push(new Item("BOWARR"));
        // items.push(new Item("FIRROD"));
        // items.push(new Item("KEY"));

        currentItem = 0;

        doors = new Map<String, Map<String, Bool>>();
        actors = new Map<String, Array<PositionItem>>();

        savedScene = "d2";
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
            items.push(new Item(name, property));
            currentItem = items.length-1;
            return true;
        }

        return false;
    }

    public static function removeItem(item : Item)
    {
        items.remove(item);
        if (currentItem >= items.length)
            currentItem = items.length-1;
    }

    public static function addMoney(value : Int)
    {
        money += value;
        if (money < 0)
            money = 0;
        else if (money > MAXMONEY)
            money = MAXMONEY;
    }

    public static function isDoorOpen(scene : String, door : String) : Bool
    {
        if (scene == null || door == null)
            return false;

        if (doors[scene] != null)
        {
            if (doors[scene][door] != null)
            {
                return doors[scene][door];
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

        doors[scene][door] = true;
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
}
