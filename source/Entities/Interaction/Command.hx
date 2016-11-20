package;

import flixel.FlxObject;

class Command extends FlxObject implements Interaction
{
    var world : World;
    var commandLine : String;
    var tokens : Array<String>;

    public function new(World : World, Command : String)
    {
        super(-1, -1);

        world = World;
        commandLine = Command;

        tokens = commandLine.split(" ");
    }

    override public function update(elapsed : Float)
    {
        // TODO: Some commands may not finish instantaneously!
        executeCommand();
        world.onInteractionEnd();

        kill();
        destroy();
    }

    public function cancel()
    {
        kill();
    }

    override public function destroy()
    {
        world.removeInteraction(this);
        super.destroy();
    }

    // To be relocated to Command Interaction!
    function executeCommand()
    {
        switch (tokens[0])
        {
            case "give":
                var name : String = tokens[1];
                var prop : String = null;
                if (tokens.length > 1)
                    prop = tokens[2];

                GameState.addItem(name, prop);
            case "remove":
                var name : String = tokens[1];
                var prop : String = null;
                if (tokens.length > 1)
                    prop = tokens[2];
                GameState.removeItemWithData(name, prop);
            case "set":
                var value : Bool = tokens.length == 2 ||
                                    tokens[2].toLowerCase() == "true";
                GameState.setFlag(tokens[1], value);
            case "switch":
                GameState.setFlag(tokens[1], !GameState.getFlag(tokens[1]));
            case "money":
                var ammount : Null<Int> = Std.parseInt(tokens[1]);
                if (ammount == null)
                    ammount = 0;
                GameState.addMoney(ammount);
            case "open":
                var name : String = tokens[1];
                GameState.openDoor(world.sceneName, name);
            case "close":
                var name : String = tokens[1];
                GameState.closeDoor(world.sceneName, name);
        }
    }
}
