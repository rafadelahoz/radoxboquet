package;

import flixel.util.FlxTimer;

class Emotion extends Entity
{
    public function new(Actor : Entity, ?Duration : Float = 0.7)
    {
        super(Actor.x, Actor.y, Actor.world);

        loadGraphic("assets/images/emo_surprise.png");
        centerOffsets();

        x = Actor.x + (Actor.flipX ? - width : Actor.width);
        y = Actor.y - height;

        flipX = Actor.flipX;
        solid = false;

        new FlxTimer().start(Duration, function(t:FlxTimer){
            t.cancel();
            t.destroy();
            kill();
            destroy();
        });
    }
}
