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
            if (FlxG.keys.justPressed("ENTER")
                    &&
                this.inp.content.replace(/^[\s\t]+$/, '').length > 0)
            {

                Score.submit_score(this.inp.content, _score, this._score_type); 
                SnakeGame.getInstance().closeDialog();
                FlxG.switchState(HallOfFameState);
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

		public function buttClassicInputDialog(type: uint, score: uint)
		{
            this.with_shadow = false;

			super("NEW HIGH SCORE!", "Enter your name: ");


            this.elements["h1"].color = ClassicPlayState.BLACK;
            this.elements["h1"].with_shadow = false;
            this.elements["h2"].color = ClassicPlayState.BLACK;
            this.elements["h2"].with_shadow = false;

            this._score = score;
            this._score_type = type;

            this.inp = new buttInput(0, 42, this.bg_width, "center");
            this.inp.setColor(ClassicPlayState.BLACK);
            this.inp.setShadow(false);
            this.add(inp);

            var footer: buttText;
            footer = new buttText(0, 62, this.bg_width, "PRESS ENTER TO SUBMIT");
            footer.color = ClassicPlayState.BLACK;
            footer.with_shadow = false;
            footer.alignment = "center";
            this.add(footer);
		}

        override protected function calc_height(): uint
        {
            return super.calc_height() + 8;
        }

	}
}
