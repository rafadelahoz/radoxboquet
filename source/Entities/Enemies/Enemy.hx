package;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class Enemy extends Entity
{
    var InvincibilityTime : Float = 0.2;
    
    var player : Player;
    
    var hp : Int;
    var invincible : Bool;
    var hurtTimer : FlxTimer;
    
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);
        
        player = world.player;
        
        invincible = false;
        hurtTimer = new FlxTimer();
        
        onInit();
    }
    
    public function onInit()
    {
        // override
        hp = 1;
    }
    
    public function onCollisionWithPlayer(player : Player)
    {
        // override
    }
    
    public function onCollisionWithTool(tool : Tool)
    {
        if (!invincible)
        {
            if (tool.power > 0)
            {
                hp -= tool.power;
                invincible = true;
                
                color = 0xFFFF004D;
                FlxTween.tween(this, {color: 0xFFFFFFFF}, 0.2);
                
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
        
    function onDeath(?t:FlxTimer = null)
    {
        if (t != null)
            t.cancel();
            
        spawnCorpse();
            
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
        doSlide(getMidpoint(), cause.getMidpoint(), 5, 24, 400);
        flipX = (velocity.x > 0);
    }
}