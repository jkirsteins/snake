package
{
	import org.flixel.*;

	public class HallOfFameState extends FlxState
	{
		public function HallOfFameState()
		{
        }

        static public function register_score(score: uint):void
        {
            FlxG.log(score);
        }
    }
}
