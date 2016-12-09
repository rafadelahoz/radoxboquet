package;

import flixel.FlxG;
import flixel.FlxObject;

class Command extends FlxObject implements Interaction
{
    var world : World;
    var commandLine : String;
    var tokens : Array<String>;
    var executed : Bool;

    public function new(World : World, Command : String)
    {
        super(-1, -1);

        world = World;
        commandLine = Command;

        tokens = commandLine.split(" ");
        executed = false;
    }

    override public function update(elapsed : Float)
    {
        if (!executed)
        {
            // Commands that shall finish return true
            if (executeCommand())
                finish();
            executed = true;
        }
    }

    function finish()
    {
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

    function executeCommand() : Bool
    {
        var finished : Bool = true;

        switch (tokens[0])
        {
            case "give":
                var name : String = tokens[1];
                var prop : String = null;
                if (tokens.length > 1)
                    prop = tokens[2];

                GameState.addItem(name, prop);
                finished = true;
            case "remove":
                var name : String = tokens[1];
                var prop : String = null;
                if (tokens.length > 1)
                    prop = tokens[2];
                GameState.removeItemWithData(name, prop);
                finished = true;
            case "set":
                var value : Bool = tokens.length == 2 ||
                                    tokens[2].toLowerCase() == "true";
                GameState.setFlag(tokens[1], value);
                finished = true;
            case "switch":
                GameState.setFlag(tokens[1], !GameState.getFlag(tokens[1]));
                finished = true;
            case "money":
                var ammount : Null<Int> = Std.parseInt(tokens[1]);
                if (ammount == null)
                    ammount = 0;
                GameState.addMoney(ammount);
                playSound("money");
                finished = false;
            case "open":
                var name : String = tokens[1];
                GameState.openDoor(world.sceneName, name);
                // TODO: Play something?
                finished = true;
            case "close":
                var name : String = tokens[1];
                GameState.closeDoor(world.sceneName, name);
                // Play something?
                finished = true;
            case "sound":
                var name : String = tokens[1];
                playSound(name);
                finished = false;
        }

        return finished;
    }

    function playSound(name : String, ?WaitForFinish : Bool = true) {
        var sfx : String = "assets/sounds/" + name + ".ogg";
        if (WaitForFinish)
            FlxG.sound.play(sfx, function() {
                finish();
            });
        else
            FlxG.sound.play(sfx);
    }
}
