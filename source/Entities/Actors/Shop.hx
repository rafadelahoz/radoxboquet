package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class Shop extends Message
{

    var productsBg : FlxSprite;
    var productLabels : Map<Item, FlxText>;
    var cursor : FlxSprite;

    var prices : Map<Item, Int>;
    var productList : Array<Item>;

    var productsNumber : Int;
    var selection : Int;
    var baseY : Int;

    public function new(World : World, Text : String, Products : Array<Item>, Prices : Map<Item, Int>)
    {
        super(World, Text);

        /*remove(topBorder);
        remove(bottomBorder);
        topBorder.destroy();
        bottomBorder.destroy();*/

        productList = Products;
        prices = Prices;

        productLabels = new Map<Item, FlxText>();

        // Add the exit "item"
        productList.push(new Item("- THANKS BYE"));

        // Setup variables
        productsNumber = productList.length;
        baseY = Std.int(y+bg.height);

        var productLabel = null;
        var labelX : Float = x + bg.width/2;

        var longest : Float = -1;
        var height : Int = 0;

        for (product in productList)
        {
            productLabel = new FlxText(labelX, baseY + height);
            productLabel.setFormat("assets/data/adventurePixels.ttf", 16);
            productLabel.text = product.name;

            if (prices.get(product) != null)
                productLabel.text += " - " + prices.get(product);

            productLabel.scrollFactor.set(0, 0);

            if (productLabel.width > longest)
                longest = productLabel.width;

            height += Std.int(productLabel.height - 4);

            productLabels.set(product, productLabel);
        }

        labelX = bg.x + bg.width - longest - 10;
        for (product in productList)
        {
            productLabels.get(product).x = labelX;
        }

        productsBg = new FlxSprite(labelX - 10, baseY);
        productsBg.makeGraphic(Std.int(longest + 20),
                               Std.int(height + 10),
                               0xFF000000);
        productsBg.scrollFactor.set(0, 0);

        add(productsBg);

        for (product in productList)
        {
            add(productLabels.get(product));
        }

        cursor = new FlxSprite(productsBg.x + productsBg.width - 10, baseY+1, "assets/images/cursor.png");
        cursor.scrollFactor.set(0, 0);
        add(cursor);

        selection = 0;
    }

    override public function destroy()
    {
        world.removeMessage(this);
        super.destroy();
    }

    override public function cancel()
    {
        kill();
    }

    override public function update(elapsed : Float)
    {
        if (state == 1)
        {
            if (FlxG.keys.justPressed.SPACE)
            {
                selection = Std.int((selection + 1) % productsNumber);
                cursor.y = baseY + 1 + cursor.height*selection;
            }
            else if (FlxG.keys.justPressed.A)
            {
                handleSelection();
            }
        }

        if (state == 1 && FlxG.keys.justPressed.S)
        {
            state = 3;
            textField.scale.set(1, 0.5);
        }
        else if (state == 3 && FlxG.keys.pressed.A)
        {
            textField.scale.set(1, 0.5);
        }
        else if (state == 3 && (FlxG.keys.justReleased.S || FlxG.keys.justReleased.A))
        {
            world.onInteractionEnd();

            kill();
            destroy();
            return;
        }

        super.update(elapsed);
    }

    function handleSelection()
    {
        state = 2;

        var item : Item = getProduct(selection);
        var price : Int = prices.get(item);

        var itemLabel : FlxText = productLabels.get(item);
        var oldText : String = itemLabel.text;

        // Temporarily alter item label
        // Depending on the action
        // If there is enough money available
        if (price == null)
        {
            // Exiting
            state = 3;
            return;
        }
        else if (GameState.money >= price)
        {
            if (GameState.isItemSlotAvailable())
            {
                itemLabel.text = "!! SOLD !!";
                itemLabel.color = 0xFF00FF4D;

                GameState.addItem(item.name, item.property);
                GameState.addMoney(-price);
            }
            else
            {
                itemLabel.text = "! NO SPACE !";
                itemLabel.color = 0xFFFF004D;
            }
        }
        else
        {
            itemLabel.text = "! NO MONEY !";
            itemLabel.color = 0xFFFF004D;
        }

        // And return to the original after a while
        new FlxTimer().start(0.5, function(t:FlxTimer) {
            t.cancel();
            t.destroy();
            itemLabel.text = oldText;
            itemLabel.color = 0xFFFFFFFF;
            state = 1;
        });
    }

    function getProduct(index : Int) : Item
    {
        if (index < 0 || index >= productList.length)
            return null;
        else
            return productList[index];
    }

    static function pad(text : String, length : Int, ?with : String = " ") : String
    {
        trace("Padding [" + text + "] until " + length);
        while (text.length < length)
        {
            text = with + text;
            trace("- [" + text + "]");
        }

        return text;
    }
}
