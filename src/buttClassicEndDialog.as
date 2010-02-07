package
{
	import org.flixel.*;
    import flash.geom.Rectangle;
    import flash.display.BitmapData;

	public class buttClassicEndDialog extends buttDialog
	{
        override protected function get bg_width(): uint { return 180; }

        override public function update(): void
        {
            if (FlxG.keys.justPressed("Y"))
            {
                SnakeGame.getInstance().closeDialog();
                FlxG.switchState(ClassicPlayState);
            }
            else if (FlxG.keys.justPressed("N"))
            {
                SnakeGame.getInstance().closeDialog();
                FlxG.switchState(MenuState);
            }

            super.update();
        }

        override protected function createBackground(): FlxSprite
        {
            var bg: FlxSprite = new FlxSprite().createGraphic(
                                                    this.bg_width,
                                                    this.calc_height(),
                                                    ClassicPlayState.WHITE,
                                                    true);

            return bg;
        }

        override protected function get text_lines(): uint { return 3; }

		public function buttClassicEndDialog(score: uint)
		{
            this.with_shadow = false;

            super("YOU DIED!", "SCORE: " + String(score));

            var footer: FlxText;
            footer = new FlxText(0, 40, this.bg_width, "Do you want to play again? (y/n)");
            footer.color = ClassicPlayState.BLACK;
            footer.alignment = "center";
            this.add(footer);

            this.elements["h1"].color = ClassicPlayState.BLACK;
            this.elements["h1"].with_shadow = false;
            this.elements["h2"].color = ClassicPlayState.BLACK;
            this.elements["h2"].with_shadow = false;
		}

	}
}
