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

import flixel.effects.postprocess.PostProcess;

class MenuState extends FlxState
{
	override public function create():Void
	{
		super.create();

		var transIn : TransitionData = new TransitionData(TILES, new FlxPoint(1.0, 1.0));
        transIn.duration = 0.55;
        transIn.color = 0xFF000000;
        FlxTransitionableState.defaultTransIn = transIn;

        var transOut : TransitionData = new TransitionData(TILES, new FlxPoint(1.0, 1.0));
        transOut.duration = 0.55;
        transOut.color = 0xFF000000;
        FlxTransitionableState.defaultTransOut = transOut;

		FlxG.scaleMode = new PixelPerfectScaleMode();

		var shaders : Array<String> = ["tiltshift", /*"hq2x",*/ "scanline", "grain"];
		for (shader in shaders)
			FlxG.addPostProcess(new PostProcess("assets/shaders/" + shader + ".frag"));
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			GameController.StartGame();
		}
		else if (FlxG.keys.justPressed.E)
		{
			GamePersistence.erase();
			if (GamePersistence.peek())
				trace("Data still exists");
			else
				trace("Data deleted");
		}
		else if (FlxG.keys.justPressed.P)
		{
			if (GamePersistence.peek())
				trace("Data still exists");
			else
				trace("Data deleted");
		}

		super.update(elapsed);
	}
}
