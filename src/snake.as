package
{
	import org.flixel.*;
	[SWF(width="640", height="480", backgroundColor="#005e8a")]
	[Frame(factoryClass="Preloader")]

	public class snake extends FlxGame
	{
		public function snake()
		{
			super(320,240,MenuState,2);
			showLogo = false;
		}
	}
}
