package
{
	import org.flixel.*;
    import flash.geom.Point;

	public class PlayState extends FlxState
	{
        public var gameAreaWidth:int = 80;
        public var gameAreaHeight:int = 60;

        private var curFood:buttSprite = null;

        private var curVector:Point = new Point(1, 0);
        private var growCycles:int = 0;

        public var doWrap:Boolean = true;
        private var snake:Array = new Array();

        private var t:Number = 0.0;

		public function PlayState()
		{
            for (x = 0; x < 4; x++) {
                snake[x] = new buttSprite(96 - x * 4, 
                    int(gameAreaHeight / 2) * 4);
            }
            
            makeNomNom();
		}

        public override function update():void
        {
            getInput();

            t += FlxG.elapsed;
            if (t > 0.05) {
                moveSnake();
                t = 0.0;
            }
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
            var newX:int = snake[0].x + curVector.x * 4;
            var newY:int = snake[0].y + curVector.y * 4;
            trace(newX, newY);

            if (newX == curFood.x && newY == curFood.y) {
                growCycles += 3;
                makeNomNom();
            }

            if (growCycles > 0) {
                growCycles -= 1;
            } else {
                snake.pop();
            }

            var hasWrapped:Boolean = false;

            if (newX == 320 && doWrap) {
                newX = 0;
                hasWrapped = true;
            }
            if (newX == -4 && doWrap && !hasWrapped) {
                newX = 320 - 4;
                hasWrapped = true;
            }
            if (newY == 240 && doWrap && !hasWrapped) {
                newY = 0;
                hasWrapped = true;
            }
            if (newY == -4 && doWrap && !hasWrapped) {
                newY = 240 - 4;
                hasWrapped = true;
            }

            /* Has wrapped basically mean we've collided as well,
               Just exploit this :P */

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
            var newX:int = randomNumber(0, gameAreaWidth / 2 - 1) * 4;
            var newY:int = randomNumber(0, gameAreaHeight - 1) * 4;

            for (y = 0; y < snake.length; y++) {
                if (newX == snake[y].x && newY == snake[y].y) {
                    makeNomNom();
                    return;
                }
            }

            curFood = new buttSprite(newX, newY);
            curFood.color = 0xFF0000;
        }
	}
}
