package;

import flixel.FlxG;
import flixel.effects.postprocess.PostProcess;

class ShaderManager
{
    static var instance : ShaderManager = null;

    public static function get() : ShaderManager
    {
        if (instance == null)
            instance = new ShaderManager();

        return instance;
    }

    var shaderNames : Array<String>;
    var shaders : Map<String, PostProcess>;
    var active : Map<String, Bool>;

    function new()
    {
        shaderNames = ["tiltshift", "hq2x", "scanline", "grain", "scanline2x"];

        shaders = new Map<String, PostProcess>();
        active = new Map<String, Bool>();

		for (shader in shaderNames)
        {
			shaders.set(shader, new PostProcess("assets/shaders/" + shader + ".frag"));
            active.set(shader, false);
        }

        enableShader("tiltshift");
    }

    public function switchShader(number : Int)
    {
        var shader : String = shaderNames[number-1];
        if (active.get(shader))
            disableShader(shader);
        else
            enableShader(shader);
    }

    function enableShader(shader : String)
    {
        FlxG.addPostProcess(shaders.get(shader));
        active.set(shader, true);
    }

    function disableShader(shader : String)
    {
        FlxG.removePostProcess(shaders.get(shader));
        active.set(shader, false);
    }
}
