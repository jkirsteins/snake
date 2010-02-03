package
{
	import org.flixel.*;
    import flash.geom.*;

	public class PlayState extends FlxState
	{
        // Keeping track of stuff
        public var score:uint = 0;
        private var hasEaten:Boolean = false;
        private var dead:Boolean = false;

        // Level variables 
        public var gameAreaWidth:int = 40;
        public var gameAreaHeight:int = 30;
        public var doWrap:Boolean = true;
        private var levelCollision:Array = new Array(
                gameAreaWidth * gameAreaHeight);
        private var levelSprites:Array = new Array(
                gameAreaWidth * gameAreaHeight);
        private var levelImage:buttSprite = null;

        private var levelCount:uint = 0;
        private var currentLevel:uint = 0;
        private var newLevelState:Boolean = true;
        
        // Food variables
        private var curFood:buttSprite = null;
        
        // Snake Variables
        private var snake:Array = new Array();
        private var growCycles:int = 0;
        private var curVector:Point = new Point(1, 0);
        private var tmpVector:Point = new Point(1, 0);

        // Keep track of time
        private var t:Number = 0.0;

		public function PlayState()
		{
            // Load our level image
            this.levelImage = new buttSprite(0, 0, Images.LevelImg);
            // Figure out how many levels there are
            this.levelCount = this.levelImage.height / gameAreaHeight - 1;
            // Load our level into an array
            loadLevel(currentLevel);

            makeNomNom();
		}

        public override function update():void
        {
            getInput();

            if ((!this.newLevelState) && (!this.dead)) {
                t += FlxG.elapsed;
                if (t > 0.15) {
                    this.curVector.x = this.tmpVector.x;
                    this.curVector.y = this.tmpVector.y;
                    moveSnake();
                    t = 0.0;
                }
                curFood.render();
            }
 
            renderLevel();
            renderSnake();
           
            if (this.newLevelState) {
                var text:String = new String("Level ")
                text = text.concat(currentLevel + 1);
                var levelTitle:FlxText = new FlxText(0, 240*0.5 - 5, 320, 
                        text);
                levelTitle.alignment = "center";
                levelTitle.color = 0x00FF00;
                levelTitle.render();
                text = new String("Press space to begin");
                levelTitle = new FlxText(0, 240*0.5 + 5, 320, text);
                levelTitle.alignment = "center";
                levelTitle.color = 0x00FF00;
                levelTitle.render();
            } else if (this.dead) {
                var scoreText:String = new String("Score: ");
                scoreText = scoreText.concat(score);
                var scoreTitle:FlxText = new FlxText(0, 240*0.5 - 5, 320, 
                        scoreText);
                scoreTitle.alignment = "center";
                scoreTitle.color = 0xFF0000;
                scoreTitle.render();
                scoreText = new String("Press space to go back to the menu");
                levelTitle = new FlxText(0, 240*0.5 + 5, 320, scoreText);
                levelTitle.alignment = "center";
                levelTitle.color = 0xFF0000;
                levelTitle.render();

            }

        }

        private function clearedLevel():void
        {
            if (this.currentLevel < this.levelCount) {
                this.t = 0.0;
                this.currentLevel += 1;
                this.newLevelState = true;
                loadLevel(this.currentLevel);
            } else {
                FlxG.switchState(MenuState);
            }
        }

        private function died():void
        {
            this.dead = true;
        }

        private function loadLevel(num:uint):void
        {
            this.hasEaten = false;
            // Figure out the original syntax
            var snakeStart:Point = null;
            var snakeEnd:Point = null;
            for (var gY:uint = gameAreaHeight * num; gY < gameAreaHeight * 
                    (num + 1); gY++) {
                for (var gX:uint = 0; gX < gameAreaWidth; gX++) {
                    var val:uint = levelImage.getPixel(gX, gY); 

                    var index:int = gY % (gameAreaHeight) * 
                            gameAreaWidth + gX;

                    if (val == 0xFFFFFF) {
                        levelCollision[index] = 0;
                        levelSprites[index] = null;
                    } else if (val == 0x000000) {
                        levelCollision[index] = 1;
                        levelSprites[index] = new buttSprite(gX * 8,
                                gY % gameAreaHeight * 8);
                    } else if (val == 0xFF0000) {
                        levelCollision[index] = 0;
                        snakeStart = new Point(gX, gY % gameAreaHeight - 1);
                    } else if (val == 0x0000FF) {
                        levelCollision[index] = 0;
                        snakeEnd = new Point(gX, gY % gameAreaHeight - 1);
                    }
                }
            }

            // Create a new snake
            this.snake = new Array();
            
            // Direction vector
            var v:Point = new Point(snakeEnd.x - snakeStart.x,
                    snakeEnd.y - snakeStart.y);

            var length:Number = Math.sqrt(v.x * v.x + 
                    v.y * v.y);
            v.x = v.x / length;
            v.y = v.y / length;
            this.curVector.x = -1 * v.x;
            this.curVector.y = -1 * v.y;
            this.tmpVector.x = this.curVector.x;
            this.tmpVector.y = this.curVector.y;

            // Create our snake elements
            for (var j:Number = 0; j < length + 1; j++) {
                var curPos:Point = new Point(snakeStart.x + (v.x * j),
                        snakeStart.y + (v.y * j));
                snake.push(new buttSprite(curPos.x * 8, curPos.y * 8));
                this.levelCollision[curPos.y * gameAreaWidth + curPos.x] = 2;
            }
        }

        private function renderLevel():void
        {
            for (var gY:uint = 0; gY < gameAreaHeight; gY++) {
                for (var gX:uint = 0; gX < gameAreaWidth; gX++) {
                    var index:Number = gY * gameAreaWidth + gX;
                    if (this.levelCollision[index] == 1) {
                        this.levelSprites[index].render();
                    }
                }
            }
        }

        private function getInput():void
        {
            if (FlxG.keys.justPressed("ESC"))
                FlxG.switchState(MenuState);

            if (this.newLevelState) {
                if (FlxG.keys.justPressed('SPACE')) {
                    this.newLevelState = false;
                }
                return;
            }

            if (this.dead) {
                if (FlxG.keys.justPressed('SPACE')) {
                    FlxG.switchState(MenuState);
                }
                return;
            }

            if (FlxG.keys.justPressed('UP')) {
                if (curVector.y != 1) {
                    this.tmpVector.x = 0;
                    this.tmpVector.y = -1;
                }
            }
            if (FlxG.keys.justPressed('DOWN')) {
                if (curVector.y != -1) {
                    this.tmpVector.x = 0;
                    this.tmpVector.y = 1;
                }
            }
            if (FlxG.keys.justPressed('LEFT')) {
                if (this.curVector.x != 1) {
                    this.tmpVector.x = -1;
                    this.tmpVector.y = 0;
                }
            }
            if (FlxG.keys.justPressed('RIGHT')) {
                if (curVector.x != -1) {
                    this.tmpVector.x = 1;
                    this.tmpVector.y = 0;
                }
            }
        }

        private function isColliding(x:int, y:int):Boolean
        {
            var index:int = y * gameAreaWidth + x;
            if (this.levelCollision[index] != 0) {
                return true;
            }
            return false;
        }

        private function moveSnake():void
        {
            var newX:int = snake[0].x + curVector.x * 8;
            var newY:int = snake[0].y + curVector.y * 8;


            if (newX == curFood.x && newY == curFood.y) {
                this.score += 100;
                this.hasEaten = true;
                if ((this.score % 200 == 0) && (this.hasEaten)) {
                    clearedLevel();
                    return;
                }
                this.growCycles += 3;
                makeNomNom();
            }


            var hasWrapped:Boolean = false;

            if (newX == 320 && doWrap) {
                newX = 0;
                hasWrapped = true;
            }
            if (newX == -8 && doWrap && !hasWrapped) {
                newX = 320 - 8;
                hasWrapped = true;
            }
            if (newY == 240 && doWrap && !hasWrapped) {
                newY = 0;
                hasWrapped = true;
            }
            if (newY == -8 && doWrap && !hasWrapped) {
                newY = 240 - 8;
                hasWrapped = true;
            }

            if (isColliding(newX / 8, newY / 8)) {
                died();
                return;
            } else {
                this.levelCollision[(newY / 8) *
                        gameAreaWidth + (newX / 8)] = 2;
            }

            if (growCycles > 0) {
                growCycles -= 1;
            } else {
                var tmp:buttSprite = snake.pop();
                this.levelCollision[(tmp.y / 8) * gameAreaWidth 
                        + (tmp.x / 8)] = 0;
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
            var newX:int = randomNumber(0, gameAreaWidth);
            var newY:int = randomNumber(0, gameAreaHeight);
        
            if (isColliding(newX, newY)) {
                makeNomNom();
                return;
            }

            newX = newX * 8;
            newY = newY * 8;

            curFood = new buttSprite(newX, newY);
            curFood.color = 0xFF0000;
        }
	}
}
