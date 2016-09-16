package;

import flixel.util.FlxTimer;

class CorpseActor extends ToolActor
{
    var hits : Int;
    var invulnerable : Bool;

    public function new(X : Float, Y : Float, World : World, ?Property : String = null, ?Slide : Bool = true)
    {
        super(X, Y, World, "CORPSE", Property, false);

        loadGraphic("assets/images/corpse.png");
        setSize(20, 13);
        offset.set(0, 6);

        // The Y is specified as base y
        y -= height;

        hits = 1;
        invulnerable = false;

        if (Slide)
            slide(world.player);
    }

    override public function onCollisionWithTool(tool : Tool)
    {
        if (!invulnerable)
        {
            invulnerable = true;
            hits -= 1;

            flash();

            if (hits < 0)
            {
                new FlxTimer().start(0.2, function(t:FlxTimer){
                    t.cancel();
                    t.destroy();
                    kill();
                    destroy();
                });
            }
            else
            {
                new FlxTimer().start(0.7, function(t:FlxTimer){
                    t.cancel();
                    t.destroy();
                    invulnerable = false;
                });
            }
        }
    }
}
