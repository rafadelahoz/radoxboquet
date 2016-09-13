package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
/*import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;*/

class HUD extends FlxGroup
{
    var deadState : Bool;
    
    var background : FlxSprite;

    var hpValue : Int;
    var hpTween : FlxTween;
    var hpDisplay : FlxSprite;
    var hpOverlay : FlxSprite;

    var itemList : FlxText;
    var cursor : FlxSprite;

    var coinsIcon : FlxSprite;
    var coinsLabel : FlxText;

    public function new()
    {
        super();

        background = new FlxSprite(0, 0).makeGraphic(60, 220, 0xFF000000/*F2F0*/);
        background.scrollFactor.set(0, 0);
        add(background);

        hpDisplay = new FlxSprite(0, 7);
        hpDisplay.makeGraphic(60, 48, 0xFFFF004D);
        hpDisplay.scrollFactor.set(0, 0);
        add(hpDisplay);
        hpValue = -1;
        hpTween = null;
        
        hpOverlay = new FlxSprite(0, 0, "assets/images/hud_hp.png");
        hpOverlay.scrollFactor.set(0, 0);
        add(hpOverlay);

        itemList = buildLabel(1, 59, "");
        itemList.scrollFactor.set(0, 0);
        add(itemList);

        cursor = new FlxSprite(50, 60, "assets/images/cursor.png");
        cursor.scrollFactor.set(0, 0);
        add(cursor);

        coinsIcon = new FlxSprite(0, 200, "assets/images/hud_money.png");
        coinsIcon.scrollFactor.set(0, 0);
        add(coinsIcon);

        coinsLabel = buildLabel(16, 198, "99999");
        coinsLabel.scrollFactor.set(0, 0);
        add(coinsLabel);
        
        deadState = false;
    }

    public static function buildLabel(X : Float, Y : Float, Text : String) : FlxText
    {
        var label : FlxText = new FlxText(X, Y);
        label.text = Text;
        label.setFormat("assets/data/adventurePixels.ttf", 16);
        label.alignment = FlxTextAlign.RIGHT;
        return label;
    }

    override public function update(elapsed : Float)
    {
        if (!deadState)
        {
            updateHP();
            
            if (FlxG.keys.justPressed.SPACE)
            {
                GameState.currentItem = (GameState.currentItem+1)%
                                    (Std.int(Math.min(GameState.items.length, 10)));
                cursor.y = 60 + GameState.currentItem*cursor.height;
            }

            updateItemList();

            coinsLabel.text = "" + GameState.money;
        }

        super.update(elapsed);
    }
    
    function updateHP()
    {
        // DEBUG Increase, Decrease life
        if (FlxG.keys.pressed.L)
            GameState.addHP(1);
        else if (FlxG.keys.pressed.O)
            GameState.addHP(-1);
        
        if (GameState.hp != hpValue)
        {
            // Fill the display to the appropriate level
            FlxSpriteUtil.fill(hpDisplay, 0x00000000);
            var top : Int = Std.int(hpDisplay.height - (GameState.hp * hpDisplay.height / 100));
            FlxSpriteUtil.drawRect(hpDisplay, 0, top, hpDisplay.width, hpDisplay.height - top, 0xFFFF004D);
            
            // Flash in red when losing life, in green when getting it
            if (hpValue > GameState.hp)
                hpOverlay.color = 0xFFFF004D;
            else
                hpOverlay.color = 0xFF00FF4D;
            
            if (hpTween != null)
                hpTween.cancel();
            hpTween = FlxTween.tween(hpOverlay, {color: 0xFFFFFFFF}, 0.5, {onComplete: function(t:FlxTween) {
                t.cancel();
                hpTween = null;
            }});
            
            // And store the value
            hpValue = GameState.hp;
        }
    }

    function updateItemList()
    {
        var itemLabels : String = "";
        var counter : Int = 0;

        for (item in GameState.items)
        {
            if (counter > 9)
            {
                itemLabels += "...";
                break;
            }

            itemLabels += item.name + "\n";
            counter++;
        }

        itemList.text = itemLabels;
    }
    
    public function onPlayerDead()
    {
        deadState = true;
        
        hpOverlay.visible = false;
        hpDisplay.visible = false;
        background.makeGraphic(Std.int(background.width), Std.int(background.height), 0xFFFF004D);
    }
}
