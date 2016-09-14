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

    public static function init()
    {
        hp = new FlxRandom().int(15, 100);
        money = 13;

        items = [];
        items.push(new Item("SWORD"));
        // items.push(new Item("FIRROD"));
        // items.push(new Item("KEY"));

        currentItem = 0;
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
}
