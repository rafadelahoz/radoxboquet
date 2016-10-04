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

    var state : Int;
    var timer : FlxTimer;

    override public function onInit()
    {
        super.onInit();

        hp = 5;
        power = 5;

        InvincibilityTime = 2;

        immovable = true;

        loadGraphic("assets/images/transition.png");

        timer = new FlxTimer();
        wait();
    }

    function wait(?t:FlxTimer = null)
    {
        timer.cancel();
        state = IDLE;
        timer.start(WaitTime + FlxG.random.float(-2.5, 2.5), shoot);
    }

    function shoot(?t:FlxTimer = null)
    {
        timer.cancel();
        // Shoot
        flash(0xFF000000, ShootTime);

        world.addEntity(new Bullet(getMidpoint().x, getMidpoint().y, world, player));

        timer.start(ShootTime, wait);
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        FlxObject.separate(this, player);
    }

    /*override function hurtSlide(cause : FlxObject)
    {
        if (state != HURT)
        {
            state = HURT;

            // Don't shoot again until slide finishes (please?)
            if (timer != null)
            {
                timer.cancel();
            }

            // If you are still alive, then please continue
            if (hp > 0)
            {
                timer.start(HurtTime, function(t:FlxTimer) {
                    timer.cancel();
                    wait();
                });
            }
        }
    }*/
}
