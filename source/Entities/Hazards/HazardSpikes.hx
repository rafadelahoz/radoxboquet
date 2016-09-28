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

        makeGraphic(20, 20, 0xFF323232);
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
            alpha = 1;
        else
            alpha = 0.2;

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
            enabled = !enabled;
            handleStateChange();
        });
    }
}
