package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class HUD extends FlxGroup
{
    var background : FlxSprite;

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

        hpDisplay = new FlxSprite(0, 0);
        hpDisplay.makeGraphic(60, 60, 0xFFFF004D);
        hpDisplay.scrollFactor.set(0, 0);
        add(hpDisplay);
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
    }

    public function buildLabel(X : Float, Y : Float, Text : String) : FlxText
    {
        var label : FlxText = new FlxText(X, Y);
        label.text = Text;
        label.setFormat("assets/data/adventurePixels.ttf", 16);
        label.alignment = FlxTextAlign.RIGHT;
        return label;
    }

    override public function update(elapsed : Float)
    {
        if (FlxG.keys.justPressed.SPACE)
        {
            GameState.currentItem = (GameState.currentItem+1)%
                                (Std.int(Math.min(GameState.items.length, 10)));
            cursor.y = 60 + GameState.currentItem*cursor.height;
        }

        updateItemList();

        coinsLabel.text = "" + GameState.money;

        super.update(elapsed);
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
}
