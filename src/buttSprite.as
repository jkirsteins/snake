package
{
    import org.flixel.FlxSprite;
    public class buttSprite extends FlxSprite
    {
        public function buttSprite(X:int = 0, Y:int = 0, 
                SimpleGraphic:Class = null)
        {
            super(X, Y, SimpleGraphic);
            this.height = 4;
            this.width = 4;
        }
    }
}
