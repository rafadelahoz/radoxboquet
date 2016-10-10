package;

class InteractionBuilder
{
    public static function buildList(world : World, actions : Array<String>) : Array<Interaction>
    {
        var interactions : Array<Interaction> = [];
        var interaction : Interaction = null;
        for (action in actions)
        {
            interaction = build(world, action);
            if (interaction != null)
                interactions.push(interaction);
            else
                trace("Nothing built from " + action);
        }

        return interactions;
    }

    public static function build(world : World, commandLine : String) : Interaction
    {
        var command : String = null;
        var spacePos : Int = commandLine.indexOf(" ");

        if (commandLine.charAt(0) == "\"" && commandLine.charAt(commandLine.length-1) == "\"")
        {
            command = "message";
            commandLine = commandLine.substring(1, commandLine.length-1);
        }
        else if (spacePos > 0)
        {
            command = commandLine.substring(0, spacePos);
        }
        else
        {
            command = commandLine;
        }

        switch (command)
        {
            case "message":
                var message : Message = new Message(world, commandLine);
                return message;
            case "give", "remove", "set", "switch", "money", "open", "close":
                var command : Command = new Command(world, commandLine);
                return command;
        }

        return null;
    }
}
