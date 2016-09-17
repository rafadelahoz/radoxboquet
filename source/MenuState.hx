package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;

import flixel.system.scaleModes.PixelPerfectScaleMode;

class MenuState extends FlxState
{
	override public function create():Void
	{
		super.create();

		var transIn : TransitionData = new TransitionData(TILES, new FlxPoint(1.0, 1.0));
        transIn.duration = 2.5;
        transIn.color = 0xFFFFFFFF;
        FlxTransitionableState.defaultTransIn = transIn;

        var transOut : TransitionData = new TransitionData(TILES, new FlxPoint(1.0, 1.0));
        transOut.duration = 0.55;
        transOut.color = 0xFF000000;
        FlxTransitionableState.defaultTransOut = transOut;

		// FlxG.scaleMode = new PixelPerfectScaleMode();
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
