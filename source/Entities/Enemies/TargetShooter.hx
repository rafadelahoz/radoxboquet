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

        hp = 3;
        power = 5;

        InvincibilityTime = 2;

        immovable = true;

        loadGraphic("assets/images/thrower.png", true, 20, 20);
        animation.add("idle", [0]);
        animation.add("open", [1]);
        animation.play("idle");

        setSize(18, 18);
        offset.set(1, 1);

        timer = new FlxTimer();
        fxTimer = new FlxTimer();
        wait();
    }

    override public function update(elapsed : Float)
    {
        if (!invincible)
        {
            flipX = (world.player.getMidpoint().x < getMidpoint().x);
            scale.set(1, 1);
            color = 0xFFFFFFFF;
        }
        else
        {
            scale.set(0.9, 0.9);
            color = 0xFF888888;
        }

        super.update(elapsed);
    }

    function wait(?t:FlxTimer = null)
    {
        timer.cancel();
        state = IDLE;
        var length : Float = WaitTime + FlxG.random.float(-2.5, 2.5);
        timer.start(length, shoot);
        fxTimer.start(length-0.25, doShake);

        animation.play("idle");
    }

    function shoot(?t:FlxTimer = null)
    {
        timer.cancel();
        // Shoot
        flash(0xFF000000, ShootTime);
        animation.play("open");

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

    override function onDeath(?t:FlxTimer = null)
    {
        timer.cancel();
        fxTimer.cancel();

        super.onDeath(t);
    }

    override function hurtSlide(cause : FlxObject)
    {
        // Nothing?
    }

    override public function spawnCorpse()
    {
        // No corpse for you
    }
}
