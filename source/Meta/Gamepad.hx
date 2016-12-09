package;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

class Gamepad
{
    public static function left() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.pressed.LEFT || (usepad && pad.analog.value.LEFT_STICK_X < -0.5);
    }

    public static function right() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.pressed.RIGHT || (usepad && pad.analog.value.LEFT_STICK_X > 0.5);
    }

    public static function up() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.pressed.UP || (usepad && pad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) < -0.5);
    }

    public static function down() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.pressed.DOWN || (usepad && pad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK) > 0.5);
    }

    public static function justPressedAction() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.justPressed.A || (usepad && pad.justPressed.X);
    }

    public static function Action() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.pressed.A || (usepad && pad.pressed.X);
    }

    public static function justReleasedAction() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.justReleased.A || (usepad && pad.justReleased.X);
    }

    public static function justPressedInteraction() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.justPressed.S || (usepad && pad.justPressed.A);
    }

    public static function Interaction() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.pressed.S || (usepad && pad.pressed.A);
    }

    public static function justReleasedInteraction() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.justReleased.S || (usepad && pad.justReleased.A);
    }

    public static function justPressedStart() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.justPressed.ENTER || (usepad && pad.justPressed.START);
    }

    public static function justPressedSelect() : Bool
    {
        var pad : FlxGamepad = FlxG.gamepads.getFirstActiveGamepad();
        var usepad : Bool = pad != null;

        return FlxG.keys.justPressed.SPACE || (usepad && (pad.justPressed.BACK || pad.justPressed.B));
    }
}
