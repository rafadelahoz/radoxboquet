package;

import flixel.util.FlxSave;

class GamePersistence
{
    static var SAVE_NAME : String = "SLOT01";
    public static function save()
    {
        var save : FlxSave = new FlxSave();
        save.bind(SAVE_NAME);

        save.data.hp = GameState.hp;
        save.data.money = GameState.money;
        // Why store current item?
        // save.data.currentItem = GameState.currentItem;
        save.data.items = new Array();
        for (item in GameState.items)
        {
            save.data.items.push({"name": item.name, "property": item.property});
        }

        save.data.flags = new Array();
        for (flag in GameState.flags.keys())
        {
            save.data.flags.push({"flag": flag, "value": GameState.flags.get(flag)});
        }

        save.data.savedScene = GameState.savedScene;
        save.data.savedSpawn = GameState.savedSpawn;

        save.close();

        trace("SAVED");
    }

    public static function load() : Bool
    {
        var save : FlxSave = new FlxSave();
        save.bind(SAVE_NAME);

        if (save.data.hp == null)
        {
            return false;
        }

        // Player status
        GameState.hp = save.data.hp;
        GameState.money = save.data.money;
        
        // Why load current item?
        // GameState.currentItem = save.data.currentItem;

        // Carried items list
        GameState.items = [];
        for (item in cast(save.data.items, Array<Dynamic>))
        {
            GameState.addItem(item.name, item.property);
        }

        // Flag list
        GameState.flags = new Map<String, Bool>();
        for (flag in cast(save.data.flags, Array<Dynamic>))
        {
            GameState.setFlag(flag.flag, flag.value);
        }

        // Location settings
        GameState.savedScene = save.data.savedScene;
        GameState.savedSpawn = save.data.savedSpawn;

        save.destroy();

        trace("LOADED");

        return true;
    }
}
