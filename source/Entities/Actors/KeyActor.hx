package;

import flixel.util.FlxTimer;

class KeyActor extends ToolActor
{
    public static var Yellow : String = "YELLOW";
    public static var Green : String = "GREEN";
    public static var Red : String = "RED";
    
    var invulnerable : Bool;

    public function new(X : Float, Y : Float, World : World, Color : String = null, ?Slide : Bool = true)
    {
        super(X, Y, World, "KEY", Color, false);
        
        loadGraphic("assets/images/key.png");
        setSize(12, 20);
        offset.set(4, 0);
        x += 4;
        
        switch (Color)
        {
            case "YELLOW":
                color = 0xFF4DFFFF;
            case "GREEN":
                color = 0xFF00FF4D;
            case "RED":
                color = 0xFFFF004D;
        }
        
        // The Y is specified as base y
        y -= height;

        invulnerable = false;
        
        if (Slide)
            slide(world.player);
    }

    override public function onCollisionWithTool(tool : Tool)
    {
        if (!invulnerable)
        {
            invulnerable = true;
            
            new FlxTimer().start(0.7, function(t:FlxTimer){
                t.cancel();
                t.destroy();
                invulnerable = false;
            });
        }
    }
}
