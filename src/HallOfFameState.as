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

		public function HallOfFameState()
		{
            this.add(new FlxSprite(0, 0, Images.HofBG));
            this.add(new buttInput());
        }

        static public function setScore(score: uint):void
        {
            FlxG.log(score);
        }
    }
}
