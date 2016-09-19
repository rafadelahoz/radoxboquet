package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;

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
        
        // Setup transitions
        FlxTransitionableState.defaultTransIn.direction.set(0, 0);
        FlxTransitionableState.defaultTransOut.direction.set(0, 0);
        // And restart
        FlxG.switchState(new World(GameState.savedScene, GameState.savedSpawn));
    }
}