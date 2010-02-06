package
{
	import org.flixel.*;

	public class HallOfFameState extends FlxState
	{
        static public function get scores(): Object { return HallOfFameState._scores; }

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
            if (FlxG.keys.justPressed("ESC"))
                FlxG.switchState(MenuState);
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

		public function HallOfFameState()
		{
            this.add(new FlxSprite(0, 0, Images.HofBG));

            this.addScoreList("Amazosnake Highscores", Score.TYPE_AMAZO);
            this.addScoreList("Classic Highscores", Score.TYPE_CLASSIC);
            //Score.fetch_scores(Score.TYPE_CLASSIC, this.populateClassicScores);
            //Score.fetch_scores(Score.TYPE_CLASSIC, this.populateClassicScores);
        }

        static public function setScore(score: uint):void
        {
            FlxG.log(score);
        }
    }
}
