package;

import flixel.util.FlxSave;

class GamePersistence
{
    static var SAVE_NAME : String = "SLOT01";
    public static function save()
    {
        var save : FlxSave = new FlxSave();
        save.bind(SAVE_NAME);

        // Player status
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

        // Actors list
        save.data.actors = new Array();
        for (scene in GameState.actors.keys())
        {
            for (actor in GameState.actors.get(scene))
            {
                trace({"scene": scene, "x": actor.x, "y": actor.y, "name": actor.name, "property": actor.property});
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
}
