package
{
	import org.flixel.*;
    import flash.geom.*;
    import mx.controls.TextInput;

	public class ClassicPlayState extends FlxState
	{
        static public function get BLACK(): uint { return 0xFF32332C; }
        static public function get WHITE(): uint { return 0xFF777863; }

        // Keeping track of stuff
        public var score:uint = 0;
        private var hasEaten:uint = 0;
        private var mustEat:uint = 8;
        private var dead:Boolean = false;
        private var newLevelState:Boolean = true;
        private var currentLevel:uint = 0;
        private var speedUp:Number = 0.0;
        private var oldSpeedUp:Number = 0.0

        // Key press stack
        private var keyStack:Array = new Array();

        // Level variables 
        public var gameAreaWidth:int = 32;
        public var gameAreaHeight:int = 24;
        public var doWrap:Boolean = true;
        private var levelCollision:Array = new Array(
                gameAreaWidth * gameAreaHeight);
        private var levelSprites:Array = new Array(
                gameAreaWidth * gameAreaHeight);
        private var levelExits:Array = new Array(
                gameAreaWidth * gameAreaHeight);
        private var levelImage:buttSprite = null;
        private var levelCount:uint = 0;
        
        // Food variables
        private var curFood:buttSprite = null;
        
        // Snake Variables
        private var snake:Array = new Array();
        private var growCycles:int = 0;
        private var curVector:Point = new Point(1, 0);
        private var tmpVector:Point = new Point(1, 0);

        // Keep track of time
        private var t:Number = 0.0;

        // Background
        private var bg:buttSprite = null;

		public function ClassicPlayState()
		{
            // Load background
            this.bg = new buttSprite(160 - 5, 120 - 5);
            this.bg.createGraphic(320, 240);
            this.bg.color = 0x787964;
            this.bg.offset = new Point(156, 116);
            // Load our level image
            this.levelImage = new buttSprite(0, 0, Images.ClassicLevel);
            // Figure out how many levels there are
            this.levelCount = this.levelImage.height / gameAreaHeight - 1;
            // Load our level into an array
            loadLevel(currentLevel);

            var _input:TextInput = new TextInput();
            _input.editable = true;

            this.addChild(_input);
		}

        public override function update():void
        {
            getInput();
            
            // Render the BG
            this.bg.render();

            if ((!this.newLevelState) && (!this.dead)) {
                t += FlxG.elapsed;
                curFood.render();
                var step:Number = 0.1 - speedUp;
                while (t >= step) {
                    processKeystroke();
                    this.curVector.x = this.tmpVector.x;
                    this.curVector.y = this.tmpVector.y;
                    moveSnake();
                    t -= step;
                }
            }
 
            renderLevel();
            renderSnake();
           
            if (this.newLevelState) {
                var text:String = new String("Press a direction key to begin!");
                var levelTitle:FlxText = new FlxText(0, 70, 320, text);
                levelTitle.alignment = "center";
                levelTitle.color = 0x32332C;
                levelTitle.render();
            } else if (this.dead) {
                var scoreText:String = new String("Score: ");
                scoreText = scoreText.concat(score);
                var scoreTitle:FlxText = new FlxText(0, 240*0.5 - 5, 320, 
                        scoreText);
                scoreTitle.alignment = "center";
                scoreTitle.color = 0xFF0000;
                //scoreTitle.render();
                scoreText = new String(
                        "Press esc or enter to go back to the menu");
                levelTitle = new FlxText(0, 240*0.5 + 5, 320, scoreText);
                levelTitle.alignment = "center";
                levelTitle.color = 0xFF0000;
                //levelTitle.render();
            }
        }

        private function died():void
        {
            this.dead = true;
            
            if (Score.check(Score.TYPE_CLASSIC, this.score))
            {
                SnakeGame.getInstance().showDialog(
                        new buttClassicInputDialog(Score.TYPE_CLASSIC, this.score));
            }
            else
            {
                SnakeGame.getInstance().showDialog(new buttClassicEndDialog(this.score));
            }
        }

        private function loadLevel(num:uint):void
        {
            this.hasEaten = 0;
            // Figure out the original syntax
            var snakeStart:Point = null;
            var snakeEnd:Point = null;
            var tmpSprite:buttSprite = null;
            for (var gY:uint = gameAreaHeight * num; gY < gameAreaHeight * 
                    (num + 1); gY++) {
                for (var gX:uint = 0; gX < gameAreaWidth; gX++) {
                    var val:uint = levelImage.getPixel(gX, gY); 

                    var index:int = gY % (gameAreaHeight) * 
                            gameAreaWidth + gX;

                    // Make sure we fill levelExits with null
                    this.levelExits[index] = null;
                    if (val == 0xFFFFFF) {
                        levelCollision[index] = 0;
                        levelSprites[index] = null;
                    } else if (val == 0x000000) {
                        levelCollision[index] = 1;
                        tmpSprite = new buttSprite(gX * 10,
                                gY % gameAreaHeight * 10);
                        tmpSprite.createGraphic(10, 10);
                        tmpSprite.color = 0x32332C;
                        tmpSprite.offset = new Point(-1, -1);
                        levelSprites[index] = tmpSprite;
                    } else if (val == 0xFF0000) {
                        levelCollision[index] = 0;
                        snakeStart = new Point(gX, gY % gameAreaHeight);
                    } else if (val == 0x0000FF) {
                        levelCollision[index] = 0;
                        snakeEnd = new Point(gX, gY % gameAreaHeight);
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
                tmpSprite = new buttSprite(curPos.x * 10, curPos.y * 10)
                tmpSprite.createGraphic(10, 10);
                tmpSprite.color = 0x32332C;
                tmpSprite.offset = new Point(-1, -1);
                snake.push(tmpSprite);
                this.levelCollision[curPos.y * gameAreaWidth + curPos.x] = 2;
            }

            makeNomNom();
        }

        private function renderLevel():void
        {
            for (var gY:uint = 0; gY < gameAreaHeight; gY++) {
                for (var gX:uint = 0; gX < gameAreaWidth; gX++) {
                    var index:int = gY * gameAreaWidth + gX;
                    var tileVal:int = this.levelCollision[index];

                    if (tileVal != 0) {
                        if (tileVal != 2) {
                            this.levelSprites[index].render();
                        }
                    }
                }
            }
        }

        private function getInput():void
        {
            if (FlxG.keys.justPressed("ESC"))
                FlxG.switchState(MenuState);

            if (this.dead) {
                if (FlxG.keys.justPressed('ENTER')) {
                    FlxG.switchState(MenuState);
                }
                return;
            }

            var didPush:Boolean = false;
            if (keyStack.length < 5) {
                if (FlxG.keys.justPressed('UP')) {
                    keyStack.push('UP');
                    didPush = true;
                } else if (FlxG.keys.justPressed('DOWN')) {
                    keyStack.push('DOWN');
                    didPush = true;
                } else if (FlxG.keys.justPressed('LEFT')) {
                    keyStack.push('LEFT');
                    didPush = true;
                } else if (FlxG.keys.justPressed('RIGHT')) {
                    keyStack.push('RIGHT');
                    didPush = true;
                }
            }
            if (this.newLevelState && didPush) {
                this.newLevelState = false;
                processKeystroke();
            }

        }

        private function processKeystroke():void
        {
            var gotValid:Boolean = false;

            while ((gotValid == false) && (this.keyStack.length > 0)) {
                var key:String = keyStack.shift();
                if (key == 'UP') {
                    if (curVector.y != 1) {
                        this.tmpVector.x = 0;
                        this.tmpVector.y = -1;
                        gotValid = true;
                    }
                } else if (key == 'DOWN') {
                    if (curVector.y != -1) {
                        this.tmpVector.x = 0;
                        this.tmpVector.y = 1;
                        gotValid = true;
                    }
                } else if (key == 'LEFT') {
                    if (this.curVector.x != 1) {
                        this.tmpVector.x = -1;
                        this.tmpVector.y = 0;
                        gotValid = true;
                    }
                } else if (key == 'RIGHT') {
                    if (curVector.x != -1) {
                        this.tmpVector.x = 1;
                        this.tmpVector.y = 0;
                        gotValid = true;
                    }
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
            var newX:int = snake[0].x + curVector.x * 10;
            var newY:int = snake[0].y + curVector.y * 10;
            var hasWrapped:Boolean = false;

            if (newX == 320 && doWrap) {
                newX = 0;
                hasWrapped = true;
            }
            if (newX == -10 && doWrap && !hasWrapped) {
                newX = 320 - 10;
                hasWrapped = true;
            }
            if (newY == 240 && doWrap && !hasWrapped) {
                newY = 0;
                hasWrapped = true;
            }
            if (newY == -10 && doWrap && !hasWrapped) {
                newY = 240 - 10;
                hasWrapped = true;
            }

            if (newX == curFood.x && newY == curFood.y) {
                this.score += 21 + (5 * this.hasEaten);
                this.hasEaten += 1;
                this.growCycles += 3;
                if (this.hasEaten < 15) {
                    this.speedUp += 0.002;
                } else if (this.speedUp <= 0.065) {
                    this.speedUp += 0.0005;
                }
                trace(0.1 - this.speedUp);
                makeNomNom();
            }

            if (isColliding(newX / 10, newY / 10)) {
                died();
            }

            if (growCycles > 0) {
                growCycles -= 1;
            } else {
                // pop snake
                var tmp:buttSprite = snake.pop();
                this.levelCollision[(tmp.y / 10) * gameAreaWidth 
                        + (tmp.x / 10)] = 0;
            }

            // Push snake
            this.levelCollision[(newY / 10) *
                    gameAreaWidth + (newX / 10)] = 2;
            var head:buttSprite = new buttSprite(newX, newY)
            head.createGraphic(10, 10);
            head.offset = new Point(-1, -1);
            head.color = 0x32332C;
            snake.unshift(head);
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

            newX = newX * 10;
            newY = newY * 10;

            curFood = new buttSprite(newX, newY, Images.ClassicFood);
        }
	}
}
