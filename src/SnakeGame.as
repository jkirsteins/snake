package
{
	import org.flixel.*;
    import flash.display.*;
    import flash.events.*;

	[SWF(width="640", height="480", backgroundColor="#005e8a")]
	[Frame(factoryClass="Preloader")]

	public class SnakeGame extends FlxGame
	{
        protected static var _inst: SnakeGame = null;

        public static function getInstance(): SnakeGame { return SnakeGame._inst; }

        override public function onCreated(): void
        {
            FlxG.log("created");
            Score.fetch_scores(Score.TYPE_CLASSIC, HallOfFameState.onScoreLoad);
            Score.fetch_scores(Score.TYPE_AMAZO, HallOfFameState.onScoreLoad);
        }

		public function SnakeGame()
		{
			super(320,240,MenuState,2);
			showLogo = false;

            SnakeGame._inst = this;
		}
	}
}
