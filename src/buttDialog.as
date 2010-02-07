package
{
	import org.flixel.*;
    import flash.geom.Rectangle;
    import flash.display.BitmapData;

	public class buttDialog extends FlxLayer
	{
        protected function get bg_width(): uint { return 160; }
        protected function get text_lines(): uint { return 2; }
        protected function get shadow_offset(): uint { return 2; }

        protected var with_shadow: Boolean = true;

        protected var elements: Array;

        public function buttDialog(h1_text: String, h2_text: String)
        {
        	super();

            this.elements = new Array();

			scrollFactor.x = 0;
			scrollFactor.y = 0;
			var w:uint = 80;
			var h:uint = 92;

            var bg: FlxSprite = this.createBackground();
            var shadow: FlxSprite = this.createShadow();

			x = (FlxG.width-bg.width)/2;
			y = (FlxG.height-bg.height)/2;

            //add(shadow);
            add(bg);

            var h1: buttText;
            h1 = new buttText(0, 8, bg.width, h1_text);
            h1.alignment = "center";
            this.add(h1);
            this.elements["h1"] = h1;

            var h2: buttText;
            h2 = new buttText(0, 24, bg.width, h2_text);
            h2.alignment = "center";
            this.add(h2);
            this.elements["h2"] = h2;

            /*var inp: buttInput;
            inp = new buttInput(0, 42, bg.width, "center");
            this.add(inp);

            var footer: buttText;
            footer = new buttText(0, 62, bg.width, "PRESS ENTER TO SUBMIT");
            //footer.size = 6;
            footer.color = ClassicPlayState.WHITE;
            footer.alignment = "center";
            this.add(footer);*/

        }

        override public function update(): void
        {
            //if (FlxG.keys.justPressed("ENTER"))
            //    SnakeGame.getInstance().closeDialog();

            super.update();
        }

        protected function calc_height(): uint
        {
            FlxG.log("Lines: " + this.text_lines);
            return this.text_lines * 14 + 8 * 2;
        }

        protected function createBackground(): FlxSprite
        {
            var bg: FlxSprite = new FlxSprite().createGraphic(
                                                    this.bg_width,
                                                    this.calc_height(),
                                                    ClassicPlayState.BLACK,
                                                    true);

            /*var bd: BitmapData = bg.pixels;
            var thickness: uint = 2;
            bd.fillRect(new Rectangle(thickness, thickness, 
                            buttClassicInputDialog.BG_WIDTH - 2*thickness, 
                            buttClassicInputDialog.BG_HEIGHT - 2*thickness),
                        ClassicPlayState.BLACK);
            
            var lineWidth: uint = 8 * 10;
            for (var i:uint = 0; i < lineWidth; i++) {
                for (var j: uint = 0; j < thickness; j++)
                    bd.setPixel32(bg.width / 2 - lineWidth / 2 + i, 56 + j, ClassicPlayState.BLACK);
            }

            bg.pixels = bd;*/
            return bg;
        }

        protected function createShadow(): FlxSprite
        {
            var shadow: FlxSprite = new FlxSprite().createGraphic(
                this.bg_width,
                this.calc_height(),
                0xFF000000,
                true
            );
            
            shadow.x = this.shadow_offset;
            shadow.y = this.shadow_offset;

            return shadow;
        }
    }
}
