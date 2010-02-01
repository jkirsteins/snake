package
{
    import org.flixel.*;

    public class MenuItem extends FlxText
    {
        private var _menu: MenuState = null;
        private var _thisIndex: int = 0;

        private var _intensity: Number = 0;

        private var _trigger: Function;
        public function trigger(): void { this._trigger(); }

        public function get intensity(): Number { return _intensity; }
        public function set intensity(value: Number): void 
        { 
            this._intensity = value;

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
            
            this.color = (r << 16) | (g << 8) | b;
        }

        public var normalColor: uint;
        public var hoverColor: uint;

        public function setIndex(i: int): void
        {
            this._thisIndex = i;
        }

        public function MenuItem(Menu: MenuState, Caption: String, trigger: Function)
        {
            super(0, 0, FlxG.width, Caption);
            this._trigger = trigger;
            Menu.addItem(this);
            this._menu = Menu;
        }

    }
}

