package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		var gameWidth:Int = 384; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
		var gameHeight:Int = 216; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		var initialState:Class<FlxState> = MenuState; // The FlxState the game starts with.
		var zoom:Float = 1; // If -1, zoom is automatically calculated to fit the window dimensions.
		var framerate:Int = 60; // How many frames per second the game should run at.
		var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
		var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		trace(stageWidth + ", " + stageHeight);

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
	}
}
