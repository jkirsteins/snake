package
{
	import org.flixel.*;

	public class HallOfFameState extends FlxState
	{
		public function HallOfFameState()
		{
        }

        static public function setScore(score: uint):void
        {
            FlxG.log(score);
        }
    }
}
