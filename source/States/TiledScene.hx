package;

import haxe.io.Path;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;
import flixel.addons.display.FlxBackdrop;

import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledTilePropertySet;

class TiledScene extends TiledMap
{
	private inline static var spritesPath = "assets/images/";
	private inline static var tilesetPath = "assets/scenery/";

	public var world : World;

	public var name : String;

	public var x : Int;
	public var y : Int;

	// public var overlayTiles    : FlxGroup;
	public var backgroundTiles : FlxGroup;
	public var collidableTileLayers : Array<FlxTilemap>;

	public function new(World : World, sceneName : String)
	{
		world = World;

		name = sceneName;
		var tiledLevel : String = "assets/scenes/" + sceneName + ".tmx";

		super(tiledLevel);

		x = 0;
		y = 0;

		// overlayTiles = new FlxGroup();
		backgroundTiles = new FlxGroup();
		collidableTileLayers = new Array<FlxTilemap>();

		/* Read config info */

		/* Read tile info */
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE) continue;
			var tileLayer:TiledTileLayer = cast layer;

			var tilesetName : String = tileLayer.properties.get("tileset");
			if (tilesetName == null)
				throw "'tileset' property not defined for the " + tileLayer.name + " layer. Please, add the property to the layer.";

			// Locate the tileset
			var tileset : TiledTileSet = null;
			for (ts in tilesets) {
				if (ts.name == tilesetName)
				{
					tileset = ts;
					break;
				}
			}

			if (tileset == null)
				throw "Tileset " + tilesetName + " could not be found. Check the name in the layer 'tileset' property or something.";

			var processedPath = buildPath(tileset);

			var tilemap : FlxTilemap = new FlxTilemap();
			/*tilemap.widthInTiles = width;
			tilemap.heightInTiles = height;*/
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath,
				tileset.tileWidth, tileset.tileHeight, OFF, tileset.firstGID, 1, 1);

			tilemap.x = x;
			tilemap.y = y;
			tilemap.ignoreDrawDebug = true;

			if (tileLayer.properties.contains("overlay"))
			{
				// overlayTiles.add(tilemap);
			}
			else if (tileLayer.properties.contains("solid"))
			{
				// collidableTileLayers.push(tilemap);
				// tilemap.ignoreDrawDebug = false;
			}
			else
			{
				backgroundTiles.add(tilemap);
			}
		}

		if (backgroundColor != 0)
		{
			world.bgColor = backgroundColor;
		}
	}

	private function loadObject(state:World, o:TiledObject, g:TiledObjectLayer, roomStorageUsed : Bool)
	{
		var x : Int = o.x + this.x;
		var y : Int = o.y + this.y;

		// The Y position of objects created from tiles must be corrected by the object height
		if (o.gid != -1 && o.objectType != TiledObject.TILE)
		{
			y -= g.map.getGidOwner(o.gid).tileHeight;
		}

		// Load imaged objects as such!
		if (o.objectType == TiledObject.TILE)
		{
			var imageData : TiledImageTile = locateImageData(g.map, o.gid);
			var imageProps : TiledTilePropertySet = locateImageProperties(g.map, o.gid);
			// Extract image path
			var imagePath = imageData.source;
			var sourceImage : String = imagePath.substring(imagePath.lastIndexOf("/")+1);
			// Consider image height
			y -= Std.int(imageData.height);
			// Consider solid height
			var solidHeight : Int = 0;
			if (imageProps.contains("solidheight"))
			{
				solidHeight = Std.parseInt(imageProps.get("solidheight"));
			}

			var scenery : SceneryImage = new SceneryImage(x, y, state, sourceImage, solidHeight);
			if (o.properties.contains("color"))
			{
				scenery.color = FlxColor.fromString(o.properties.get("color"));
			}

			state.addEntity(scenery);
		}
		/** Enemies **/
		else if (EnemySpawner.isEnemy(o.type.toLowerCase()))
		{
			if (!roomStorageUsed)
				state.addEntity(EnemySpawner.spawn(x, y, o.type, state));
		}
		else
		{
			switch (o.type.toLowerCase())
			{
			/** Enemies **/
				case "area":
					if (!roomStorageUsed)
					{
						var elements : Map<String, String> = new Map<String, String>();
						for (prop in o.properties.keysIterator())
							elements.set(prop, o.properties.get(prop));
						new SpawnArea(x, y, state, o.width, o.height, elements);
					}
			/** Hazards **/
				case "fire":
					var fire : Fire = new Fire(x, y, state);
					var type : String = o.properties.get("type");
					if (type == null || type == "Endless")
						fire.setupEndlessFire();
					else if (type == "Timed")
					{
						var active : Bool = (o.properties.contains("timedActive") && o.properties.get("timedActive") == "true");
						var activeTime : Float = Std.parseFloat(o.properties.get("timedActiveTime"));
						var inactiveTime : Null<Float> = null;
						if (o.properties.contains("inactiveTime"))
							inactiveTime = Std.parseFloat(o.properties.get("inactiveTime"));
						fire.setupTimedFire(active, activeTime, inactiveTime);
					}
					else if (type == "Fuel")
					{
						fire.setupFuelCanisterFire(Std.parseInt(o.properties.get("fueledFuel")));
					}

					state.addEntity(fire);
				case "spikes":
					var enabled : Bool = (o.properties.get("enabled") != "false");
					var enabledTime : Float = -1;
					var disabledTime : Float = -1;
					if (o.properties.contains("enabledTime"))
						enabledTime = Std.parseFloat(o.properties.get("enabledTime"));
					if (o.properties.contains("disabledTime"))
						disabledTime = Std.parseFloat(o.properties.get("disabledTime"));

					var spikes : HazardSpikes = new HazardSpikes(x, y, state, enabled, enabledTime, disabledTime);
					state.addEntity(spikes);
				case "spitter":
					var theme : String = o.properties.get("theme");
					var facing : String = o.properties.get("facing");
					if (facing == null)
						throw "No facing specified for Spitter at " + x + ", " + y;
					var startDelay : Null<Float> = Std.parseFloat(o.properties.get("startDelay"));
					if (Math.isNaN(startDelay))
						startDelay = null;
					var shootDelay : Float = Std.parseFloat(o.properties.get("shootDelay"));
					if (Math.isNaN(shootDelay))
						throw "No shoot delay specified for Spitter at " + x + ", " + y;
					var shootSpeed : Null<Int> = Std.parseInt(o.properties.get("shootSpeed"));
					if (Math.isNaN(shootSpeed))
						throw "No shoot speed specified for Spitter at " + x + ", " + y;
					var spitter : Spitter = new Spitter(x, y, state, facing, theme, shootDelay, startDelay, shootSpeed);
					state.addEntity(spitter);

			/** NPCs **/
				case "npc":
					var parser : NPCParser = new NPCParser(state);
					parser.parse(x, y, o);

			/** Collectibles **/
				case "key":
					var color : String = o.properties.get("color");
					KeyActor.spawn(x, y+20, state, color, o.name);
					// the spawner adds the key to the world
			/** Elements **/
				case "solid":
					var solid : Entity = new Solid(x, y, state, o.width, o.height);
					state.addEntity(solid);
				case "hole":
					var hole : Entity = new Hole(x, y, state, o.width, o.height);
					state.addEntity(hole);
				case "teleport":
					var target : String = o.properties.get("target");
					var door : String = o.properties.get("door");
					var dir : String = o.properties.get("dir");
					var tport : Teleport = new Teleport(x, y, state, o.width, o.height, o.name, target, door, dir);
					state.addEntity(tport);
				case "door":
					var door : Door = new Door(x, y, state, o.name);
					if (o.properties.contains("graphic_asset"))
						door.setupGrahic(o.properties.get("graphic_asset"));
					state.addEntity(door);
					door.angle = o.angle;
				case "lockdoor":
					var color : String = o.properties.get("color");
					var door : KeyDoor = new KeyDoor(x, y, state, o.name, color);
					state.addEntity(door);
					door.angle = o.angle;

			/** Puzzles **/
				case "plate":
					var color : Int = backgroundColor;
					if (o.properties.contains("color"))
						color = flixel.util.FlxColor.fromString(o.properties.get("color"));
					var door : String = o.properties.get("door");
					var enemy : String = o.properties.get("enemy");
					var plate : Plate = new Plate(x, y, state, color, door, enemy);
					state.addEntity(plate);
				default:
					// !
			}
		}
	}

	private function buildPath(tileset : TiledTileSet, ?spritesCase : Bool  = false) : String
	{
		var imagePath = new Path(tileset.imageSource);
		var processedPath = (spritesCase ? spritesPath : tilesetPath) +
			imagePath.file + "." + imagePath.ext;

		return processedPath;
	}

	public function destroy()
	{
		backgroundTiles.clear();
		backgroundTiles.destroy();

		/*overlayTiles.clear();
		overlayTiles.destroy();*/

		for (layer in collidableTileLayers)
			layer.destroy();

		collidableTileLayers = null;

		/*world.decoration.forEachOfType(SceneEntity, removeCurrentSceneEntities);
		world.exits.forEachOfType(SceneEntity, removeCurrentSceneEntities);
		world.ground.forEachOfType(SceneEntity, removeCurrentSceneEntities);*/
	}

	public function getBounds() : FlxRect
	{
		return new FlxRect(x, y, fullWidth, fullHeight);
	}

	public function loadObjects(state : World, roomStorageUsed : Bool)
	{
		var layer:TiledObjectLayer;
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT)
				continue;
			var objectLayer:TiledObjectLayer = cast layer;

			for (o in objectLayer.objects)
			{
				loadObject(state, o, objectLayer, roomStorageUsed);
			}
		}
	}

	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers == null)
			return false;

		for (map in collidableTileLayers)
		{
			// IMPORTANT: Always collide the map with objects, not the other way around.
			//			  This prevents odd collision errors (collision separation code off by 1 px).
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}

	public function overlapsWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers == null)
			return false;

		for (map in collidableTileLayers)
		{
			// IMPORTANT: Always collide the map with objects, not the other way around.
			//			  This prevents odd collision errors (collision separation code off by 1 px).
			if (FlxG.overlap(map, obj, notifyCallback, processCallback))
			{
				return true;
			}
		}

		return false;
	}

	public function locateImageData(map : TiledMap, gid : Int) : TiledImageTile
	{
		var containerTileset : TiledTileSet = locateTilesetOfGid(map, gid);

		if (containerTileset != null)
		{
			// Now lets locate the actual image
			var target : Int = gid - containerTileset.firstGID;
			return containerTileset.tileImagesSources[target];
		}
		else
		{
			return null;
		}
	}

	public function locateImageProperties(map : TiledMap, gid : Int) : TiledTilePropertySet
	{
		var containerTileset : TiledTileSet = locateTilesetOfGid(map, gid);

		if (containerTileset != null)
		{
			// Now lets locate the actual image
			var target : Int = gid - containerTileset.firstGID;
			return containerTileset.tileProps[target];
		}
		else
		{
			return null;
		}
	}

	function locateTilesetOfGid(map : TiledMap, gid : Int) : TiledTileSet
	{
		for (set in map.tilesets)
		{
			if (set.firstGID <= gid && set.tileImagesSources != null)
			{
				if (set.firstGID + set.tileImagesSources.length > gid)
					return set;
			}
		}

		return null;
	}
}
