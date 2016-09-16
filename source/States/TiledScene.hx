package;

import haxe.io.Path;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
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
				collidableTileLayers.push(tilemap);
				// tilemap.ignoreDrawDebug = false;
			}
			else
			{
				backgroundTiles.add(tilemap);
			}
		}
	}

	private function loadObject(state:World, o:TiledObject, g:TiledObjectLayer)
	{
		var x : Int = o.x + this.x;
		var y : Int = o.y + this.y;

		// The Y position of objects created from tiles must be corrected by the object height
		/*if (o.gid != -1) {
			y -= o.height;
		}*/
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;

		trace(o.name);

		switch (o.name.toLowerCase())
		{
			case "twitcher":
				var twitcher : Twitcher = new Twitcher(x, y, state);
				state.addEntity(twitcher);
			case "exit":
				// trace("Exit at ("+x+","+y+")");
				/*var dir : String = o.custom.get("direction");
				var name : String = o.custom.get("name");

				var exit : Exit = new Exit(x, y, state, this, o.width, o.height);
				exit.init(name, dir);
				state.exits.add(exit);*/

			/*case "oneway":
				var oneway : FlxObject = new FlxObject(x, y, o.width, o.height);
				oneway.allowCollisions = FlxObject.UP;
				oneway.immovable = true;
				state.oneways.add(oneway);*/

		/** Collectibles **/

		/** Elements **/
			case "solid":
				/*var solid : SceneEntity = new SceneEntity(x, y, state, this);
				solid.makeGraphic(o.width, o.height, 0x00DDDDDD);
				solid.immovable = true;
				state.ground.add(solid);*/
			case "decoration":
				// trace("adding decoration!");
				/*var gid = o.gid;
				var tiledImage : TiledImage = getImageSource(gid);
				if (tiledImage == null)
				{
					trace("Could not locate image source for gid=" + gid + "!");
				}
				else
				{
					var decoration : Decoration = new Decoration(x, y, state, this, tiledImage);
					state.decoration.add(decoration);
				}*/

			case "backdrop":
				/*var gid = o.gid;
				var tiledImage : TiledImage = getImageSource(gid);
				if (tiledImage == null)
				{
					trace("Could not locate image source for gid=" + gid + "!");
				}

				var scrollX : Float = 1;
				var scrollY : Float = 1;

				if (o.custom.contains("scrollX"))
					scrollX = Std.parseFloat(o.custom.get("scrollX"));

				if (o.custom.contains("scrollY"))
					scrollY = Std.parseFloat(o.custom.get("scrollY"));

				x = Std.int(x * scrollX);
				y = Std.int(y * scrollY);

				var decoration : Decoration = new Decoration(x, y, state, this, tiledImage);
				decoration.scrollFactor.x = scrollX;
				decoration.scrollFactor.y = scrollY;
				state.decoration.add(decoration);*/

			// TODO: Just a draft!
			case "background":
				/*var gid = o.gid;
				var tiledImage : TiledImage = getImageSource(gid);
				if (tiledImage == null)
				{
					trace("Could not locate image source for gid=" + gid + "!");
				}

				var scrollX : Float = 1;
				var scrollY : Float = 1;

				if (o.custom.contains("scrollX"))
					scrollX = Std.parseFloat(o.custom.get("scrollX"));

				if (o.custom.contains("scrollY"))
					scrollY = Std.parseFloat(o.custom.get("scrollY"));

				var background : FlxBackdrop = new FlxBackdrop(tiledImage.imagePath, scrollX, scrollY);
				state.ground.add(background);
				*/
			default:
				// !
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

	public function loadObjects(state : World)
	{
		var layer:TiledObjectLayer;
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT)
				continue;
			var objectLayer:TiledObjectLayer = cast layer;

			//collection of images layer
			/*if (layer.name == "images")
			{
				for (o in objectLayer.objects)
				{
					loadImageObject(o);
				}
			}*/

			//objects layer
			if (layer.name == "Actors")
			{
				for (o in objectLayer.objects)
				{
					loadObject(state, o, objectLayer);
				}
			}
		}
	}

	/*private function loadImageObject(object:TiledObject)
	{
		var tilesImageCollection:TiledTileSet = this.getTileSet("imageCollection");
		var tileImagesSource:TiledImageTile = tilesImageCollection.getImageSourceByGid(object.gid);

		//decorative sprites
		var levelsDir:String = "assets/tiled/";

		var decoSprite:FlxSprite = new FlxSprite(0, 0, levelsDir + tileImagesSource.source);
		if (decoSprite.width != object.width ||
			decoSprite.height != object.height)
		{
			decoSprite.antialiasing = true;
			decoSprite.setGraphicSize(object.width, object.height);
		}
		decoSprite.setPosition(object.x, object.y - decoSprite.height);
		decoSprite.origin.set(0, decoSprite.height);
		if (object.angle != 0)
		{
			decoSprite.angle = object.angle;
			decoSprite.antialiasing = true;
		}

		//Custom Properties
		if (object.properties.contains("depth"))
		{
			var depth = Std.parseFloat( object.properties.get("depth"));
			decoSprite.scrollFactor.set(depth,depth);
		}

		backgroundLayer.add(decoSprite);
	}*/

	/*public function loadImages()
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.IMAGE)
				continue;

			var image:TiledImageLayer = cast layer;
			var sprite = new FlxSprite(image.x, image.y, tilesetPath + image.imagePath);
			imagesLayer.add(sprite);
		}
	}*/

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
}
