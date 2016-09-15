package;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class Enemy extends Entity
{
    var InvincibilityTime : Float = 0.2;
    
    var player : Player;
    
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
    }
    
    public function onCollisionWithPlayer(player : Player)
    {
        // override
    }
    
    public function onCollisionWithTool(tool : Tool)
    {
        if (!invincible)
        {
            invincible = true;
            
            color = 0xFFFF004D;
            FlxTween.tween(this, {color: 0xFFFFFFFF}, 0.2);
            
            hurtTimer.cancel();
            hurtTimer.start(InvincibilityTime, finishInvincibility);
            
            hurtSlide(tool);
        }
    }
    
    function finishInvincibility(?t:FlxTimer = null)
    {
        if (t != null)
            t.cancel();
        invincible = false;
    }
    
    function hurtSlide(cause : FlxObject)
    {
        var force : FlxPoint = getMidpoint();
        var ccenter : FlxPoint = cause.getMidpoint();

        force.x -= ccenter.x;
        force.y -= ccenter.y;

        force.x *= 5;
        force.y *= 5;

        velocity.set(force.x, force.y);
        drag.set(400, 400);

        flipX = (force.x > 0);
    }
}