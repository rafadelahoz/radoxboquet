package;

import flixel.FlxG;

class GameController
{
    public static function StartGame()
    {
        GameState.init();
        FlxG.switchState(new World());
    }
    
    public static function DeadContinue()
    {
        GameState.setHP(50);
        // Lose money?
        FlxG.resetState();
    }
}