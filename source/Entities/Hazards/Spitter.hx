package;

import flixel.util.FlxTimer;
import flixel.math.FlxPoint;

class Spitter extends Hazard
{
    var face : String;
    var shootDelay : Float;
    var startDelay : Float;
    var shootSpeed : Int;

    var timer : FlxTimer;
    var shootOrigin : FlxPoint;
    var target : FlxPoint;

    public function new(X : Float, Y : Float, World : World, Facing : String, ShootDelay : Float = 4, ?StartDelay : Float = 2, ?ShootSpeed : Int = 100)
    {
        super(X, Y, World);

        // Fetch configuration values
        shootDelay = ShootDelay;
        startDelay = StartDelay;
        shootSpeed = ShootSpeed;
        face = Facing.toLowerCase();
        // Parse facing
        if (["left", "right", "up", "down"].indexOf(face) < 0)
            throw "Invalid facing for Spitter at " + x + ", " + y + ": " + face;

        // TODO: Load appropriate graphic
        loadGraphic("assets/images/transition.png");
        // makeGraphic(20, 20, 0xFFFFFFFF);
        setSize(20, 20);
        centerOffsets(true);

        // Rotate according to facing
        switch (face)
        {
            case "down":    angle = 0;
            case "left":    angle = 90;
            case "up":      angle = 180;
            case "right":   angle = 270;
        }

        timer = new FlxTimer();
        shootOrigin = new FlxPoint();
        target = new FlxPoint();

        timer.start(startDelay, onShoot);
    }

    override public function destroy()
    {
        timer.cancel();
        timer.destroy();

        shootOrigin.destroy();
        target.destroy();

        super.destroy();
    }

    function onShoot(t : FlxTimer) : Void
    {
        shootOrigin = getMidpoint(shootOrigin);
        target.set();
        switch (face)
        {
            case "down":    shootOrigin.y += 15; target.y += 20;
            case "right":   shootOrigin.x += 15; target.x += 20;
            case "up":      shootOrigin.y -= 17.5; target.y -= 20;
            case "left":    shootOrigin.x -= 17.5; target.x -= 20;
        }

        shake(0.5);

        world.addEntity(new Bullet(shootOrigin.x, shootOrigin.y, world, null, null, target, shootSpeed));

        timer.start(shootDelay, onShoot);
    }
}
