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
            case "shop":
                var shopLine : String =
                        commandLine.substring(spacePos, commandLine.length);
                var shop : Shop = buildShop(world, shopLine);
                return shop;
            case "give", "remove", "set", "switch", "money", "open", "close", "sound":
                var command : Command = new Command(world, commandLine);
                return command;
        }

        return null;
    }

    public static function buildShop(world : World, shopLine : String) : Shop
    {
        shopLine = StringTools.trim(shopLine);

        var productList : Array<Item> = [];
        var prices : Map<Item, Int> = new Map<Item, Int>();

        var messageEnd : Int = shopLine.lastIndexOf("\"");
        var message : String = shopLine.substring(1, messageEnd);

        var productsLine : String = shopLine.substring(messageEnd+1, shopLine.length);
        productsLine = StringTools.trim(productsLine);

        var tokens : Array<String> = null;
        var product : Item = null;
        var price : Int = 0;

        var productsStr : Array<String> = productsLine.split(",");
        for (productStr in productsStr)
        {
            productStr = StringTools.trim(productStr);
            tokens = productStr.split(" ");

            product = new Item(tokens[0]);

            if (tokens.length == 3)
            {
                product.property = tokens[1];
                price = Std.parseInt(tokens[2]);
            }
            else if (tokens.length == 2)
            {
                price = Std.parseInt(tokens[1]);
            }
            else
            {
                trace("No price specified for " + tokens[0]);
                price = 0;
            }

            productList.push(product);
            prices.set(product, price);
        }

        var shop : Shop = new Shop(world, message, productList, prices);
        return shop;
    }
}
