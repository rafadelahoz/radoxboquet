package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

import flixel.system.scaleModes.PixelPerfectScaleMode;

class MenuState extends FlxState
{
	override public function create():Void
	{
		super.create();

		 FlxG.scaleMode = new PixelPerfectScaleMode();
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			GameController.StartGame();
		}

		super.update(elapsed);
	}
}
