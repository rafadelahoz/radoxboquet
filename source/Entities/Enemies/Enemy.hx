package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class Enemy extends Entity
{
    var InvincibilityTime : Float = 0.2;

    var hurtSfxSet : Array<String>;

    public var power : Int = 5;

    public var hp : Int;
    public var invincible : Bool;

    var hurtTimer : FlxTimer;
    var rewards : Array<Int> = [1];

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        invincible = false;
        hurtTimer = new FlxTimer();

        hurtSfxSet = ["enemy_a-hurt1", "enemy_a-hurt2", "enemy_a-hurt3", "enemy_a-hurt4", "enemy_a-hurt5"];
    }

    override public function destroy()
    {
        hurtTimer.cancel();
        hurtTimer.destroy();

        super.destroy();
    }

    override public function onInit()
    {
        // override
        hp = 1;
        power = 5;
    }

    public function onCollisionWithPlayer(player : Player)
    {
        player.onCollisionWithEnemy(this);
    }

    public function onCollisionWithTool(tool : Tool)
    {
        if (!invincible)
        {
            if (tool.power > 0)
            {
                playSfx(hurtSfxSet, false);

                hp -= tool.power;
                invincible = true;

                flash();

                hurtTimer.cancel();
                if (hp > 0)
                    hurtTimer.start(InvincibilityTime, finishInvincibility);
                else
                    hurtTimer.start(InvincibilityTime, onDeath);
            }

            hurtSlide(tool);
        }
    }

    public function spawnCorpse()
    {
        var baseX : Float = x;
        var baseY : Float = y + height;

        var corpse = new CorpseActor(baseX, baseY, world, true);
        world.addEntity(corpse);
    }

    public function spawnReward()
    {
        for (i in 0...FlxG.random.int(1, 5))
        {
            var value : Int = FlxG.random.getObject(rewards);

            var spawnPos : FlxPoint = getMidpoint();
            spawnPos.x += FlxG.random.float(-5, 5);
            spawnPos.y += FlxG.random.float(-5, 5);

            var money : Money = new Money(spawnPos.x, spawnPos.y, world, value, this);
            world.addEntity(money);
        }
    }

    function onDeath(?t:FlxTimer = null)
    {
        if (t != null)
            t.cancel();

        spawnCorpse();
        spawnReward();

        kill();
        destroy();
    }

    function finishInvincibility(?t:FlxTimer = null)
    {
        if (t != null)
            t.cancel();
        invincible = false;
    }

    function hurtSlide(cause : FlxObject)
    {
        doSlide(getMidpoint(), cause.getMidpoint(), 8.5, 24, 400);
        flipX = (velocity.x > 0);
    }
}
