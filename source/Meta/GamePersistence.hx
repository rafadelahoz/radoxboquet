package;

import flixel.util.FlxSave;

class GamePersistence
{
    static var SAVE_NAME : String = "SLOT01";

    public static function peek() : Bool
    {
        var save : FlxSave = new FlxSave();
        save.bind(SAVE_NAME);

        return (save.data.name != null);
    }

    public static function save()
    {
        var save : FlxSave = new FlxSave();
        save.bind(SAVE_NAME);

        // Player status
        save.data.name = GameState.name;
        save.data.hp = GameState.hp;
        save.data.money = GameState.money;

        // Why store current item?
        // save.data.currentItem = GameState.currentItem;

        // Carried items list
        save.data.items = new Array();
        for (item in GameState.items)
        {
            save.data.items.push({"name": item.name, "property": item.property});
        }

        // FLag list
        save.data.flags = new Array();
        for (flag in GameState.flags.keys())
        {
            save.data.flags.push({"flag": flag, "value": GameState.flags.get(flag)});
        }

        // Doors list
        save.data.doors = new Array();
        for (scene in GameState.doors.keys())
        {
            for (door in GameState.doors.get(scene).keys())
            {
                save.data.doors.push({"scene": scene, "door": door, "open": GameState.doors.get(scene).get(door)});
            }
        }

        // Actors list
        save.data.actors = new Array();
        for (scene in GameState.actors.keys())
        {
            for (actor in GameState.actors.get(scene))
            {
                save.data.actors.push({"scene": scene, "x": actor.x, "y": actor.y, "name": actor.name, "property": actor.property});
            }
        }

        // Location settings
        save.data.savedScene = GameState.savedScene;
        save.data.savedSpawn = GameState.savedSpawn;

        save.close();

        trace("SAVED");
    }

    public static function load() : Bool
    {
        var save : FlxSave = new FlxSave();
        save.bind(SAVE_NAME);

        if (save.data.name == null)
        {
            return false;
        }

        // Player status
        GameState.name = save.data.name;
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

        // Doors list
        GameState.doors = new Map<String, Map<String, Bool>>();
        for (door in cast(save.data.doors, Array<Dynamic>))
        {
            if (GameState.doors.get(door.scene) == null)
                GameState.doors.set(door.scene, new Map<String, Bool>());
            GameState.doors.get(door.scene).set(door.door, door.open);
        }

        // Actors list
        GameState.actors = new Map<String, Array<PositionItem>>();
        for (actor in cast(save.data.actors, Array<Dynamic>))
        {
            if (GameState.actors.get(actor.scene) == null)
                GameState.actors.set(actor.scene, new Array<PositionItem>());
            GameState.actors.get(actor.scene).push(new PositionItem(actor.x, actor.y, new Item(actor.name, actor.property)));
        }

        // Location settings
        GameState.savedScene = save.data.savedScene;
        GameState.savedSpawn = save.data.savedSpawn;

        save.destroy();

        trace("LOADED");

        return true;
    }

    public static function erase()
    {
        var save : FlxSave = new FlxSave();
        save.bind(SAVE_NAME);

        save.data.name = null;
        save.data.hp = null;
        save.data.money = null;
        save.data.items = null;
        save.data.doors = null;
        save.data.actors = null;
        save.data.savedScene = null;
        save.data.savedSpawn = null;

        save.close();

        trace("ERASED");
    }
}
