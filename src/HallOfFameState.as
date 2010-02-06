package
{
	import org.flixel.*;

	public class HallOfFameState extends FlxState
	{
        override public function update(): void
        {
            if (FlxG.keys.justPressed("ESC"))
                FlxG.switchState(MenuState);
        }

        public function populateClassicScores(arr: Object): void
        {
            for (var i: uint = 1; i <= 10; i++)
            {
                var title: FlxText = new FlxText(0, 80, FlxG.width, "Classic Highscores");
                title.alignment="center";
                this.add(title);

                var name: FlxText = new FlxText(0, 100 + i*10, FlxG.width/2, String(i) + ") " + arr[String(i)]["name"]);
                name.alignment = "right";
                this.add(name);

                var score: FlxText = new FlxText(FlxG.width/2, 100 + i*10, FlxG.width/2, arr[String(i)]["score"]);
                score.alignment = "left";
                this.add(score);
            }
        }

		public function HallOfFameState()
		{
            this.add(new FlxSprite(0, 0, Images.HofBG));
            this.add(new buttInput());

            Score.fetch_scores(Score.TYPE_CLASSIC, this.populateClassicScores);
        }

        static public function setScore(score: uint):void
        {
            FlxG.log(score);
        }
    }
}
