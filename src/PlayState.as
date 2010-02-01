package
{
	import org.flixel.*;
    import flash.geom.Point;

	public class PlayState extends FlxState
	{
        public var gameAreaWidth:int = 80;
        public var gameAreaHeight:int = 25;

        private var curFood:buttSprite = null;

        private var curVector:Point = new Point(1, 0);
        private var growCycles:int = 0;

        public var doWrap:Boolean = true;
        private var snake:Array = new Array();

		public function PlayState()
		{
            for (x = 0; x < 8; x++) {
                snake[x] = new buttSprite(96 - x * 8, 
                    int(gameAreaHeight / 2) * 8);
            }
            
            makeNomNom();
		}

        public override function update():void
        {
            getInput();
            moveSnake();
            renderSnake();

            curFood.render();
        }

        private function getInput():void
        {
            if (FlxG.keys.UP) {
                if (!curVector.x == 0 || !curVector.y == 1) {
                    curVector.x = 0;
                    curVector.y = -1;
                }
            }
            if (FlxG.keys.DOWN) {
                if (!curVector.x == 0 || !curVector.y == -1) {
                    curVector.x = 0;
                    curVector.y = 1;
                }
            }
            if (FlxG.keys.LEFT) {
                if (!curVector.x == 1 || !curVector.y == 0) {
                    curVector.x = -1;
                    curVector.y = 0;
                }
            }
            if (FlxG.keys.RIGHT) {
                if (!curVector.x == -1 || !curVector.y == 0) {
                    curVector.x = 1;
                    curVector.y = 0;
                }
            }
        }

        private function moveSnake():void
        {

            if (growCycles == 0) {
                snake.pop();
            } else {
                growCycles -= 1;
            }

            var newX:int = snake[0].x + curVector.x * 8;
            var newY:int = snake[0].y + curVector.y * 8;

            if (newX == curFood.x && newY == curFood.y) {
                growCycles = 3;
                makeNomNom();
            }

            if (newX >= 320 && doWrap) {
                newX = 0;
            }
            if (newX <= -1 && doWrap) {
                newX = 320;
            }
            if (newY > 240 && doWrap) {
                newY = 0;
            }
            if (newY < 0 && doWrap) {
                newY = 240;
            }

            snake.unshift(new buttSprite(newX, newY));
        }

        private function renderSnake():void
        {
            for (y = 0; y < snake.length; y++) {
                snake[y].render();
            }
        }

        private function randomNumber(low:Number, high:Number):Number
        {
            return Math.floor(Math.random() * (high - low) + low)
        }

        private function makeNomNom():void
        {
            var newX:int = randomNumber(0, gameAreaWidth - 1) * 8;
            var newY:int = randomNumber(0, gameAreaHeight - 1) * 8;
            trace(newX, newY);

            for (y = 0; y < snake.length; y++) {
                if (newX == snake[y].x && newY == snake[y].y) {
                    makeNomNom();
                    return;
                }
            }


            curFood = new buttSprite(newX, newY);
        }
	}
}
