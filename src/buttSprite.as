package
{
    import org.flixel.FlxSprite;
    import flash.geom.Point;

    public class buttSprite extends FlxSprite
    {
        public function buttSprite(X:int = 0, Y:int = 0, 
                SimpleGraphic:Class = null)
        {
            super(X, Y, SimpleGraphic);
        }

        public function getPixel(x:int, y:int):uint
        {
            return this._pixels.getPixel(x, y);
        }

        public function currentFrame():uint
        {
            return this._curFrame;
        }
    }
}
