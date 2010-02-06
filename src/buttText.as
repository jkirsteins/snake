package
{
	import org.flixel.*;
    import flash.geom.Rectangle;
    import flash.display.BitmapData;

	public class buttText extends FlxText
    {
        public function buttText(X: uint, Y: uint, W: uint, Text: String)
        {
            super(X, Y, W, Text);
        }

        override public function render(): void
        {
            var old_color: uint = this.color;

            this.color = 0xFF000000;
            this.x += 1;
            this.y += 1;
            super.render();

            this.color = old_color;
            this.x -= 1;
            this.y -= 1;
            super.render();
        }
    }
}


