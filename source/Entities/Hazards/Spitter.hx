package;

import flixel.util.FlxTimer;
import flixel.math.FlxPoint;

class Spitter extends Hazard
{
    public static var ThemeBullets : String = "bullets";
    public static var ThemeRocks : String = "rocks";

    var theme : String;

    var face : String;
    var shootDelay : Float;
    var startDelay : Float;
    var shootSpeed : Int;

    var timer : FlxTimer;
    var animTimer : FlxTimer;
    var shootOrigin : FlxPoint;
    var target : FlxPoint;

    public function new(X : Float, Y : Float, World : World, Facing : String, ?Theme : String = null, ShootDelay : Float = 4, ?StartDelay : Float = 2, ?ShootSpeed : Int = 100)
    {
        super(X, Y, World);

        theme = Theme;
        if (theme == null)
            theme = ThemeBullets;

        // Fetch configuration values
        shootDelay = ShootDelay;
        startDelay = StartDelay;
        shootSpeed = ShootSpeed;

        face = Facing.toLowerCase();
        // Parse facing
        if (["left", "right", "up", "down"].indexOf(face) < 0)
            throw "Invalid facing for Spitter at " + x + ", " + y + ": " + face;

        switch (theme)
        {
            case Spitter.ThemeBullets:
                loadGraphic("assets/images/spitter.png", true, 20, 20);
            case Spitter.ThemeRocks:
                loadGraphic("assets/images/spitter_rock.png", true, 20, 20);
            default:
                throw "Unknown Spitter theme: " + theme;
        }

        animation.add("closed", [0]);
        animation.add("open", [1, 1, 1], 10, false);

        setSize(5, 5);
        centerOffsets(true);

        animation.play("closed");

        // Rotate according to facing
        switch (face)
        {
            case "down":    angle = 0;
            case "left":    angle = 90;
            case "up":      angle = 180;
            case "right":   angle = 270;
        }

        timer = new FlxTimer();
        animTimer = new FlxTimer();
        shootOrigin = new FlxPoint();
        target = new FlxPoint();

        animTimer.start(startDelay*0.95, onPreShoot);
        timer.start(startDelay, onShoot);
    }

    override public function destroy()
    {
        timer.cancel();
        timer.destroy();
        animTimer.cancel();
        animTimer.destroy();

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

        var bulletType : String = null;
        switch (theme)
        {
            case Spitter.ThemeBullets:
                bulletType = "purple";
                playSfx("bump");
            case Spitter.ThemeRocks:
                bulletType = "purpleball";
                playSfx("bump");
        }
        world.addEntity(new Bullet(shootOrigin.x, shootOrigin.y, world, bulletType, null, target, shootSpeed));

        animTimer.start(shootDelay*0.95, onPreShoot);
        timer.start(shootDelay, onShoot);
    }

    function onPreShoot(t : FlxTimer) : Void
    {
        animation.play("open");
        shake(0.15);
    }

    override public function update(elapsed : Float)
    {
        if (animation.name == "open" && animation.finished)
            animation.play("closed");

        super.update(elapsed);
    }
}
