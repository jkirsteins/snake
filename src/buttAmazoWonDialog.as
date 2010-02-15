package
{
	import org.flixel.*;
    import flash.geom.Rectangle;
    import flash.display.BitmapData;

	public class buttAmazoWonDialog extends buttDialog
	{
        override protected function get bg_width(): uint { return 180; }

        override public function update(): void
        {
            if (FlxG.keys.justPressed("Y"))
            {
                SnakeGame.getInstance().closeDialog();
                FlxG.switchState(AmazoPlayState);
            }
            else if (FlxG.keys.justPressed("N"))
            {
                SnakeGame.getInstance().closeDialog();
                FlxG.switchState(MenuState);
            }

            super.update();
        }

		public function buttAmazoWonDialog()
		{
            super("You cleared the game!", "Do you want to play again? (Y/N)");
		}

	}
}
