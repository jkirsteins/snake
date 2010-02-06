package
{
	import org.flixel.*;
    import flash.geom.Rectangle;
    import flash.display.BitmapData;

	public class buttClassicInputDialog extends buttDialog
	{
        override protected function get text_lines(): uint { return 4; }
        protected var inp: buttInput;

        protected var _score: uint;
        protected var _score_type: uint;

        override public function update(): void
        {
            if (FlxG.keys.justPressed("ENTER"))
            {
                Score.submit_score(this.inp.content, _score, this._score_type); 
                SnakeGame.getInstance().closeDialog();
                FlxG.switchState(HallOfFameState);
            }

            super.update();
        }

		public function buttClassicInputDialog(type: uint, score: uint)
		{
			super("NEW HIGH SCORE!", "Enter your name: ");

            this._score = score;
            this._score_type = type;

            this.inp = new buttInput(0, 42, this.bg_width, "center");
            this.add(inp);

            var footer: buttText;
            footer = new buttText(0, 62, this.bg_width, "PRESS ENTER TO SUBMIT");
            footer.color = ClassicPlayState.WHITE;
            footer.alignment = "center";
            this.add(footer);
		}

        override protected function calc_height(): uint
        {
            return super.calc_height() + 8;
        }

	}
}
