package
{
    import org.flixel.*;

    public class ImageItem extends MenuItem
    {
        protected var sprite: FlxSprite;
        protected var _cf: uint = 0;

        override public function render(): void
        {
            sprite.render();
        }

        override public function update(): void
        {
            var expected: uint = (FlxG.mute ? 1 : 0);
            if (expected != this._cf)
                this.trigger(this);
        }

        override public function getIntensityColor(): uint 
        {
            var col: uint = super.getIntensityColor();
            this.sprite.color = col;
            return col;
        }

        //public function MenuItem(Menu: MenuState, Caption: String, trigger: Function)
        public function nextFrame(): void
        {
            this._cf = (this._cf == 0 ? 1 : 0);
            this.sprite.specificFrame (this._cf);
        }

        override public function trigger(item: MenuItem): void 
        { 
            FlxG.log("Triggering this shit");
            this.nextFrame();
            FlxG.mute = (this._cf == 1);
        }

        public function ImageItem(  Menu: IMenu, 
                                    sheet: Class, 
                                    frameSize: uint, 
                                    trigger: Function)
        {
            super(Menu, "", trigger);

            this.x = FlxG.width - 24;
            this.y = FlxG.height - 24;

            this.sprite = 
                new FlxSprite(this.x, this.y).loadGraphic(sheet, true, false, frameSize, frameSize);

            this.getIntensityColor();

        }
    }
}

