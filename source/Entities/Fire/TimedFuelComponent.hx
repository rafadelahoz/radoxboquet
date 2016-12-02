package;

import flixel.util.FlxTimer;

class TimedFuelComponent implements IFuelComponent
{
    var activeTime : Float;
    var inactiveTime : Float;
    var active : Bool;

    var timer : FlxTimer;

    public function new(Active : Bool, ActiveTime : Float, ?InactiveTime : Float = -1)
    {
        active = Active;
        activeTime = ActiveTime;
        inactiveTime = (InactiveTime <= 0 ? ActiveTime : InactiveTime);

        timer = new FlxTimer();
    }

    public function init()
    {
        // Start!
        setTimer();
    }

    public function hasFuel() : Bool
    {
        return active;
    }

    public function drawFuel() : Void
    {
        // Nop
    }

    function setTimer()
    {
        timer.start((active ? activeTime : inactiveTime), onTimer);
    }

    function onTimer(t : FlxTimer)
    {
        active = !active;
        setTimer();
    }
}
