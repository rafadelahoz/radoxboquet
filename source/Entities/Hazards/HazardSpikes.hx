package;

import flixel.util.FlxTimer;

class HazardSpikes extends Hazard
{
    var timer : FlxTimer;

    var enabled : Bool;
    var enabledTime : Float;
    var disabledTime : Float;

    public function new(X : Float, Y : Float, World : World, ?Enabled : Bool = true, ?EnabledTime : Float = -1, ?DisabledTime : Float = -1)
    {
        super(X, Y, World);

        loadGraphic("assets/images/spikes.png", true, 20, 20);
        animation.add("on", [0]);
        animation.add("off", [1]);

        setSize(16, 16);
        centerOffsets(true);

        flat = true;

        enabled = Enabled;
        enabledTime = EnabledTime;
        disabledTime = DisabledTime;

        timer = new FlxTimer();

        if (disabledTime <= 0)
            disabledTime = enabledTime;
        if (enabledTime > 0 && disabledTime > 0)
        {
            handleStateChange();
        }
    }

    override public function update(elapsed : Float)
    {
        if (enabled)
            animation.play("on");
        else
            animation.play("off");

        super.update(elapsed);
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        if (enabled)
            player.onCollisionWithHazard(this);
    }

    function handleStateChange()
    {
        if (timer != null)
            timer.cancel();

        timer.start((enabled ? enabledTime : disabledTime),  function(t:FlxTimer) {
            shake(0.1);
            enabled = !enabled;
            handleStateChange();
        });
    }
}
