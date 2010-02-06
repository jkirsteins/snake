package
{
	import org.flixel.*;

	public class HallOfFameState extends FlxState
	{
        static protected var _scores: Array = new Array();

        static public function onScoreLoad(type: uint, arr: Object): void
        {
            FlxG.log("POPULATING SCORES (type: " + String(type) + ")");
            FlxG.log(arr);

            HallOfFameState._scores[String(type)] = new Array();
            for (var i: uint = 1; i <= 10; i++)
            {
                HallOfFameState._scores[type][String(i)] = arr[String(i)];
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
            this.add(new buttInput());

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
