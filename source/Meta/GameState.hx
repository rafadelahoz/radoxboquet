package;

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
        //items.push(new Item("SWORD"));
        //items.push(new Item("FIRROD"));
        items.push(new Item("KEY"));

        currentItem = 0;
    }

    public static function addItem(name : String, ?property : String = null) : Bool
    {
        trace(items.length);
        if (items.length < 10)
        {
            trace("Getting " + name);
            items.push(new Item(name, property));
            return true;
        }

        return false;
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
