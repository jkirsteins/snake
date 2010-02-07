package
{
	import org.flixel.*;
    import caurina.transitions.*;

	public class MenuState extends FlxState implements IMenu
	{
        static private var _index: uint = 0;
        private var _oldIndex: uint = 0; 
        private var _elements: Array;

        private var _pressedItem: Boolean = false;

        private var normalColor: uint = 0x000000;
        private var hoverColor: uint = 0xFFFFFF;

		public function MenuState()
		{
            FlxG.showCursor(null);

            this.add(new FlxSprite(0, 0, Images.MenuBG));

            this._elements = new Array();


            new MenuItem(this, "Amazosnake", function (item: MenuItem): void 
                    { 
                        FlxG.switchState(AmazoPlayState); 
                    });
            new MenuItem(this, "Classic snake", function (item: MenuItem): void 
                    { 
                        FlxG.switchState(ClassicPlayState); 
                    });
            new MenuItem(this, "Hall of Fame", function (item: MenuItem): void 
                    { 
                        FlxG.switchState(HallOfFameState);
                    });
            
            new ImageItem(this, Images.Speakers, 16, function (item: ImageItem): void
                    {
                    // in ImageItem.trigger
                    });

            var title: FlxText = new FlxText(40, FlxG.height - 30, FlxG.width/2, "amazosnake v0.8");
            title.alignment = "left";
            this.add(title);


		}

        public function getIndex(): uint
        {
            return MenuState._index;
        }

        public function addItem(item: MenuItem, rx: uint = 0, ry: uint = 0): void
        {
            if (rx == 0)
                item.x = 40;
            else
                item.x = rx;

            if (ry == 0)
                item.y = FlxG.height - 70 + _elements.length * item.height;
            else
                item.y = ry;

            item.alignment = "left";

            item.normalColor = 0x444444;
            item.hoverColor = 0xFFFFFF;

            item.width = 80;
            
            item.color = this.normalColor; //item.normalColor;

            item.setIndex(_elements.length);

            if (_elements.length == MenuState._index)
                item.color = item.hoverColor;
            else
                item.color = item.normalColor;

            _elements.push(item);
            this.add(item);
        }

        public function setIndex(i: uint): void
        {
            this._oldIndex = MenuState._index;
            MenuState._index = i;
        }

        public function pressItem(): void
        {
            this._pressedItem = true;
        }

		override public function update():void
		{
			super.update();
            if (FlxG.keys.justPressed('UP'))
            {
                this.setIndex(MenuState._index == 0 ? 
                                   this._elements.length-1 : 
                                   MenuState._index - 1);
            }

            else if (FlxG.keys.justPressed('DOWN'))
            {
                this.setIndex(MenuState._index == this._elements.length-1 ? 
                                   0 : 
                                   MenuState._index + 1);
            }
            else if (FlxG.keys.justPressed('ENTER'))
                this.pressItem();

            if (this._pressedItem)
            {
                this._pressedItem = false;
                this._elements[MenuState._index].trigger(
                        this._elements[MenuState._index]
                    );
            }

            if (this._oldIndex != MenuState._index)
            {
                this._elements[this._oldIndex].color = this._elements[this._oldIndex].normalColor;

                //this._elements[MenuState._index].color = 0x00FF00;
                Tweener.addTween(this._elements[MenuState._index], {intensity:1.0, time: 1, transition: "easeOutSine"});
                Tweener.addTween(this._elements[this._oldIndex], {intensity:0.0, time: 0, transition: "easeOutSine"});
                
            }
		}
	}
}
