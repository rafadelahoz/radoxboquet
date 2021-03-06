package;

import openfl.Assets;
import flixel.addons.editors.tiled.TiledObject;

class NPCParser
{
    var o : TiledObject;
    var world : World;

    public function new(World : World)
    {
        world = World;
    }

    public function parse(x : Float, y : Float, O : TiledObject) : NPC
    {
        o = O;
        if (world == null || o == null)
            throw "Null object or world provided";

        var npc : NPC = null;

        var canTurn : Bool = o.properties.get("cantturn") != "true";
        var canFlip : Bool = !o.properties.contains("canflip") || o.properties.get("canflip") == "true";
        npc = new NPC(x, y, world, o.properties.get("message"), o.properties.get("face"), canTurn, canFlip);
        npc.setupGraphic(o.properties.get("graphic_asset"), o.width, o.height,
                    o.properties.get("graphic_frames"),
                    Std.parseInt(o.properties.get("graphic_speed")));

        // NPCs can be defined in two ways
        // Basic or scripted
        if (o.properties.contains("script"))
        {
            var script : String = o.properties.get("script");
            var configs : Array<NPCConfig> = parseScript(script);
            npc.setupConfigurations(configs);
        }
        else
        {
            if (o.properties.get("solid") == "false")
                npc.solid = false;
        }

        world.addEntity(npc);

        return npc;
    }

    var config : NPCConfig;
    var configs : Array<NPCConfig>;

    function parseScript(script) : Array<NPCConfig>
    {
        var basePath : String = "assets/scripts/";

        configs = [];

		var fileContents : String = Assets.getText(basePath + script);
		var lines : Array<String> = fileContents.split("\n");

        config = null;

        for (line in lines)
		{
            parseLine(line);
		}

		return configs;
    }

    function parseLine(line : String)
    {
        // Is it a comment?
		if (line.charAt(0) == "#")
			return;

		// Trim the line
		line = StringTools.trim(line);

        if (line.length <= 0)
            return;

		// Locate property
        var propName : String = null;
        var spacePos : Int = line.indexOf(" ");

        if (line.charAt(0) == "\"" && line.charAt(line.length-1) == "\"")
        {
            propName = "message";
        }
        else if (spacePos > 0)
        {
            propName = line.substring(0, spacePos);
            line = line.substring(spacePos+1, line.length);
        }
        else
        {
            propName = line;
        }

        switch (propName)
        {
            case "default":
                config = new NPCConfig("default");
                configs.push(config);
            case "if":
                config = new NPCConfig(line);
                configs.push(config);
            case "enabled":
                config.enabled = (line == "true");
            case "cantturn":
                config.canturn = (line != "true");
            case "canflip":
                config.canflip = (line == "true");
            case "face":
                config.face = line;
            case "solid":
                config.solid = (line == "true");
            case "visible":
                config.visible = (line == "true");
            case "flat":
                config.flat = (line == "true");
            case "graphic":
                parseGraphic(line);
            case "behaviour":
                trace("behavour not implemented");
            case "message":
                config.interactions.push(line);
            case "give", "remove", "set", "switch", "money", "open", "close", "shop", "sound":
                config.interactions.push(propName + " " + line);
            default:
                throw "Unrecognized property " + propName;
        }
    }

    function parseGraphic(line : String)
    {
        // Line in format:
        // wombat 20 20 [3,4,5,4,3] 10
        // wombat 20 20 2 10
        var tokens : Array<String> = line.split(" ");
        config.graphic_asset = tokens[0];
        config.graphic_width = Std.parseInt(tokens[1]);
        config.graphic_height = Std.parseInt(tokens[2]);
        config.graphic_frames = tokens[3];
        config.graphic_speed = Std.parseInt(tokens[4]);
    }
}
