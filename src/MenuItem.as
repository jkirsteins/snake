package
{
    import org.flixel.*;

    public class MenuItem extends FlxText
    {
        private var _thisIndex: int = 0;
        private var _menu: IMenu;

        private var _intensity: Number = 0;

        private var _trigger: Function;
        public function trigger(item: MenuItem): void { this._trigger(item); }

        public function get intensity(): Number { return _intensity; }

        public function getIntensityColor(): uint
        {
            var r: uint, g: uint, b: uint;
            r = (this.normalColor >> 16) & 255;
            g = (this.normalColor >> 8) & 255;
            b = (this.normalColor) & 255;

            var tr: uint, tg: uint, tb: uint;
            tr = (this.hoverColor >> 16) & 255;
            tg = (this.hoverColor >> 8) & 255;
            tb = (this.hoverColor) & 255;

            var rstep: uint, gstep: uint, bstep: uint;
            rstep = tr - r;
            gstep = tg - g;
            bstep = tb - b;

            r += rstep * this._intensity;
            g += gstep * this._intensity;
            b += bstep * this._intensity;

            return (r << 16) | (g << 8) | b;
        }

        public function set intensity(value: Number): void 
        { 
            this._intensity = value;
            this.color = this.getIntensityColor();
        }

        public var normalColor: uint;
        public var hoverColor: uint;

        override public function update(): void
        {
            super.update();

            if (FlxG.mouse.x > this.x && FlxG.mouse.x < this.x + this.width)
            {
                if (FlxG.mouse.y > this.y && FlxG.mouse.y < this.y + this.height)
                {
                    if (this._menu.getIndex() != this._thisIndex)
                    {
                        this._menu.setIndex(this._thisIndex);
                    }

                    if (this._menu.getIndex() == this._thisIndex &&
                        FlxG.mouse.justPressed())
                    {
                        this._menu.pressItem();
                    }
                }
            }
        }

        public function setIndex(i: int): void
        {
            this._thisIndex = i;
        }

        public function MenuItem(Menu: IMenu, Caption: String, trigger: Function)
        {
            super(0, 0, FlxG.width, Caption);

            this.height = 10;
            this._trigger = trigger;
            Menu.addItem(this);
            this._menu = Menu;
        }

    }
}

