package
{
	import org.flixel.*;
    import caurina.transitions.*;

	public class MenuState extends FlxState
	{
        private var _index: int = 0;
        private var _elements: Array;

        private var normalColor: uint = 0x000000;
        private var hoverColor: uint = 0xFFFFFF;

		public function MenuState()
		{
            FlxG.showCursor(null);

            this.add(new FlxSprite(0, 0, Images.MenuBG));

            this._elements = new Array();


            new MenuItem(this, "Amazosnake", function (): void 
                    { 
                        FlxG.switchState(AmazoPlayState); 
                    });
            new MenuItem(this, "Classic snake", function (): void 
                    { 
                        FlxG.switchState(ClassicPlayState); 
                    });
            new MenuItem(this, "Hall of Fame", function (): void 
                    { 
                        FlxG.switchState(HallOfFameState);
                    });

            var title: FlxText = new FlxText(40, FlxG.height - 30, FlxG.width/2, "amazosnake v0.8");
            title.alignment = "left";
            this.add(title);
		}

        public function getIndex(): int
        {
            return this._index;
        }

        public function addItem(item: MenuItem): void
        {
            item.x = 40;
            item.y = FlxG.height - 70 + _elements.length * 10;
            item.alignment = "left";

            item.normalColor = 0x444444;
            item.hoverColor = 0xFFFFFF;
            
            item.color = this.normalColor; //item.normalColor;

            item.setIndex(_elements.length);

            if (_elements.length == this._index)
                item.color = item.hoverColor;
            else
                item.color = item.normalColor;

            _elements.push(item);
            this.add(item);
        }

		override public function update():void
		{
            var _oldIndex: int = this._index;

			super.update();
            if (FlxG.keys.justPressed('UP'))
                this._index = (this._index == 0 ? 
                                   this._elements.length-1 : 
                                   this._index - 1);

            else if (FlxG.keys.justPressed('DOWN'))
                this._index = (this._index == this._elements.length-1 ? 
                                   0 : 
                                   this._index + 1);
            else if (FlxG.keys.justPressed('ENTER'))
                this._elements[this._index].trigger();

            if (FlxG.keys.justPressed('UP') || FlxG.keys.justPressed('DOWN'))
            {
                this._elements[_oldIndex].color = this._elements[_oldIndex].normalColor;

                //this._elements[this._index].color = 0x00FF00;
                Tweener.addTween(this._elements[this._index], {intensity:1.0, time: 1, transition: "easeOutSine"});
                Tweener.addTween(this._elements[_oldIndex], {intensity:0.0, time: 0, transition: "easeOutSine"});
                
            }
		}
	}
}
