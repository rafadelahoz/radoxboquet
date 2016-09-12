package;

import flixel.math.FlxRandom;

class GameState
{
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
        items.push(new Item("FIRROD"));
        for (i in 0...30)
            items.push(new Item("KEY"));

        currentItem = 0;
    }
}
