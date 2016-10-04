package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;

class TargetShooter extends Enemy
{
    static var IDLE : Int = 0;
    static var SHOOT : Int = 1;
    static var HURT : Int = 2;

    var WaitTime : Float = 5;
    var ShootTime : Float = 0.65;
    var HurtTime : Float = 0.4;
    var BulletSpeed : Int = 200;

    var state : Int;
    var timer : FlxTimer;
    var fxTimer : FlxTimer;

    override public function onInit()
    {
        super.onInit();

        hp = 5;
        power = 5;

        InvincibilityTime = 2;

        immovable = true;

        loadGraphic("assets/images/transition.png");

        timer = new FlxTimer();
        fxTimer = new FlxTimer();
        wait();
    }

    function wait(?t:FlxTimer = null)
    {
        timer.cancel();
        state = IDLE;
        var length : Float = WaitTime + FlxG.random.float(-2.5, 2.5);
        timer.start(length, shoot);
        fxTimer.start(length-0.25, doShake);
    }

    function shoot(?t:FlxTimer = null)
    {
        timer.cancel();
        // Shoot
        flash(0xFF000000, ShootTime);

        world.addEntity(new Bullet(getMidpoint().x, getMidpoint().y, world, world.player, BulletSpeed));

        timer.start(ShootTime, wait);
    }

    function doShake(?t:FlxTimer = null)
    {
        fxTimer.cancel();
        shake(0.5);
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        FlxObject.separate(this, player);
    }

    override public function onCollisionWithTool(tool : Tool)
    {
        super.onCollisionWithTool(tool);

        if (invincible)
        {
            tool.cancel();
        }
    }

    override function hurtSlide(cause : FlxObject)
    {
        // Nothing?
    }
}
