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
            this.scale = new Point(0.5, 0.5);
            this.offset = new Point(2, 2);
        }
    }
}
