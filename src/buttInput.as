package
{
	import org.flixel.*;
    import flash.events.*;
    import flash.ui.*;

	public class buttInput extends FlxCore
	{
        protected var text: buttText;
        protected var shift_pressed: Boolean = false;

        protected var max_length: uint = 8;

        public function get content(): String { return this.text.text; }

		public function buttInput(X: uint, Y: uint, W: uint, AL: String)
		{
			super();

		    SnakeGame.getInstance().stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			SnakeGame.getInstance().stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);

            this.text = new buttText(X, Y, W, "");
            this.text.alignment = AL;
		}

		protected function onKeyUp(event:KeyboardEvent):void
        {
            if (event.keyCode == 16)
                this.shift_pressed = false;

            if (FlxG.pause) return;
        }

		protected function onKeyDown(event:KeyboardEvent):void
		{
            if (event.keyCode == 13) return;

            if (event.keyCode == 8)
                this.text.text = this.text.text.substr(0, this.text.text.length-1);
            else if (event.keyCode == 16)
                this.shift_pressed = true;
            else if (this.text.text.length >= this.max_length) 
                return;
            else
            {
                if ( 
                        (this.shift_pressed && !flash.ui.Keyboard.capsLock) ||
                        (flash.ui.Keyboard.capsLock && !this.shift_pressed)
                   )
                    this.text.text += String.fromCharCode(event.charCode).toLocaleUpperCase();
                else
                    this.text.text += String.fromCharCode(event.charCode).toLocaleLowerCase();
            }

		}
		
        override public function render(): void
        {
            // TODO: draw some frame?
            this.text.render();
        }

        override public function update(): void
        {
            var mx:Number;
			var my:Number;
			var moved:Boolean = false;
            
			if((this.x != this.last.x) || (this.y != this.last.y))
			{
				moved = true;
				mx = this.x - this.last.x;
				my = this.y - this.last.y;
			}
			super.update();
			
			if(moved)
			{
				this.text.x += mx;
				this.text.y += my;
			}
        }
	}
}
