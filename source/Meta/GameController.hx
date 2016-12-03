package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;

class GameController
{
    public static function StartGame()
    {
        GameState.init();
        if (!GamePersistence.peek())
            trace("No data found, starting new game");
        else
        {
            trace("Save data found, resuming game");
            GamePersistence.load();
        }

        var initialScene : String = GameState.savedScene;
        var initialSpawn : String = GameState.savedSpawn;

        var hospitalScene : String = GameState.findHospital();
        if (hospitalScene != null)
        {
            initialScene = hospitalScene;
            initialSpawn = null;
        }

        FlxG.switchState(new World(initialScene, initialSpawn));
    }

    public static function DeadContinue()
    {
        // Setup player state
        GameState.setHP(50);

        // Setup transitions
        FlxTransitionableState.defaultTransIn.direction.set(0, 0);
        FlxTransitionableState.defaultTransOut.direction.set(0, 0);

        // And restart
        var scene : String = null;
        var spawn : String = null;

        var hospitalScene : String = GameState.findHospital();
        if (hospitalScene == null)
        {
            scene = GameState.savedScene;
            spawn = GameState.savedSpawn;
        }
        else
        {
            scene = hospitalScene;
            spawn = null;
        }

        FlxG.switchState(new World(scene, spawn));
    }
}
