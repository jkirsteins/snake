package
{
	import org.flixel.*;
    import caurina.transitions.*;

	public class HallOfFameState extends FlxState implements IMenu
	{
        static public function get scores(): Object { return HallOfFameState._scores; }

        private var _elements: Array;
        private var _index: uint = 0;
        private var _oldIndex: uint = 0;
        private var _pressedItem: Boolean = false;

        private var normalColor: uint = 0x000000;
        private var hoverColor: uint = 0xFFFFFF;

        public function pressItem(): void
        {
            this._pressedItem = true;
        }

        static protected var _scores: Object = 
        { 
            1: { 
                '1': { 'name': '    None', 'score': 0 },
                '2': { 'name': '    None', 'score': 0 },
                '3': { 'name': '    None', 'score': 0 },
                '4': { 'name': '    None', 'score': 0 },
                '5': { 'name': '    None', 'score': 0 },
                '6': { 'name': '    None', 'score': 0 },
                '7': { 'name': '    None', 'score': 0 },
                '8': { 'name': '    None', 'score': 0 },
                '9': { 'name': '    None', 'score': 0 },
                '10': { 'name': '    None', 'score': 0 }
               }, 
            2: { 
                '1': { 'name': '    None', 'score': 0 },
                '2': { 'name': '    None', 'score': 0 },
                '3': { 'name': '    None', 'score': 0 },
                '4': { 'name': '    None', 'score': 0 },
                '5': { 'name': '    None', 'score': 0 },
                '6': { 'name': '    None', 'score': 0 },
                '7': { 'name': '    None', 'score': 0 },
                '8': { 'name': '    None', 'score': 0 },
                '9': { 'name': '    None', 'score': 0 },
                '10': { 'name': '    None', 'score': 0 }
               } 
        };

        static public function onScoreLoad(type: uint, arr: Object): void
        {
            FlxG.log("POPULATING SCORES (type: " + String(type) + ")");
            FlxG.log(arr);

            HallOfFameState._scores[String(type)] = new Array();
            for (var i: uint = 1; i <= 10; i++)
            {
                HallOfFameState._scores[type][String(i)] = arr[String(i)];
                FlxG.log("Received name: " + arr[String(i)]["name"]);
            }
        }

        override public function update(): void
        {
            super.update();

            if (FlxG.keys.justPressed("ESC"))
                FlxG.switchState(MenuState);
            else if (FlxG.keys.justPressed('ENTER'))
                this.pressItem();

            if (this._pressedItem)
            {
                this._pressedItem = false;
                this._elements[this._index].trigger(
                        this._elements[this._index]
                    );
            }

            if (this._oldIndex != this._index)
            {
                this._elements[this._oldIndex].color = this._elements[this._oldIndex].normalColor;
                //this._elements[MenuState._index].color = 0x00FF00;
                Tweener.addTween(this._elements[this._index], {intensity:1.0, time: 1, transition: "easeOutSine"});
                Tweener.addTween(this._elements[this._oldIndex], {intensity:0.0, time: 0, transition: "easeOutSine"});
                
            }
        }

        public function addScoreList(title_string: String, type: uint): void
        {
            for (var i: uint = 1; i <= 10; i++)
            {
                var title: FlxText = new FlxText((FlxG.width/2) * (type-1), 80, FlxG.width/2, title_string);
                title.alignment="center";
                this.add(title);

                var name: FlxText = new FlxText(0 + FlxG.width/2 * (type-1), 100 + i*10, FlxG.width/4, String(i) + ") " + 
                        HallOfFameState._scores[type][String(i)]["name"]);
                name.alignment = "right";
                this.add(name);

                var score: FlxText = new FlxText(FlxG.width/4 + FlxG.width/2 * (type - 1), 100 + i*10, FlxG.width/4, 
                        HallOfFameState._scores[type][String(i)]["score"]);
                score.alignment = "left";
                this.add(score);
            }
        }

        public function setIndex(i: uint): void
        {
            this._oldIndex = this._index;
            this._index = i;
        }

        public function getIndex(): uint
        {
            return this._index;
        }

        public function addItem(item: MenuItem, rx: uint = 0, ry: uint = 0): void
        {
            if (rx == 0)
                item.x = 20;
            else
                item.x = rx;

            if (ry == 0)
                item.y = 20 + _elements.length * item.height;
            else
                item.y = ry;

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

		public function HallOfFameState()
		{
            FlxG.showCursor(null);

            this.add(new FlxSprite(0, 0, Images.HofBG));

            this.addScoreList("Amazosnake Highscores", Score.TYPE_AMAZO);
            this.addScoreList("Classic Highscores", Score.TYPE_CLASSIC);

            this._elements = new Array();

            new MenuItem(this, "Back", function (item: MenuItem): void 
                    { 
                        FlxG.switchState(MenuState); 
                    });

        }

        static public function setScore(score: uint):void
        {
            FlxG.log(score);
        }
    }
}
