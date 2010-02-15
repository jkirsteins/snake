package
{
	import org.flixel.*;
    import flash.geom.*;
    import mx.controls.TextInput;


	public class AmazoPlayState extends FlxState
	{
        // Keeping track of stuff
        public var score:uint = 0;
        private var hasEaten:uint = 0;
        private var mustEat:uint = 2;
        private var dead:Boolean = false;
        private var newLevelState:Boolean = true;
        private var currentLevel:uint = 0;
        private var showExits:Boolean = false;
        private var isExiting:Boolean = false;
        private var speedUp:Number = 0.0;
        private var oldSpeedUp:Number = 0.0

        // Key press stack
        private var keyStack:Array = new Array();

        // Level variables 
        public var gameAreaWidth:int = 40;
        public var gameAreaHeight:int = 30;
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
        private var unwrappedSnake:Array = null;
        
        // Score text
        private var scoreText:FlxText = null;
        private var scoreTextShadow:FlxText = null;

        // Keep track of time
        private var t:Number = 0.0;

        // Background
        private var bg:buttSprite = null;

		public function AmazoPlayState()
		{
            // Load background
            this.bg = new buttSprite(0, 0, Images.AmazoBG);
            this.bg.color = 0xFFFFFF;
            // Load our level image
            this.levelImage = new buttSprite(0, 0, Images.LevelImg);
            // Figure out how many levels there are
            this.levelCount = this.levelImage.height / gameAreaHeight - 1;
            // Load our level into an array
            loadLevel(currentLevel);

            // Score text
            this.scoreText = new FlxText(0, 0, 320, "0");
            this.scoreText.color = 0xFFFFFF;
            this.scoreText.alpha = 0.5;
            this.scoreText.alignment = "right";
            this.scoreTextShadow = new FlxText(1, 1, 320, "0");
            this.scoreTextShadow.color = 0x000000;
            this.scoreTextShadow.alpha = 0.5;
            this.scoreTextShadow.alignment = "right";


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
                    if (this.isExiting) {
                        if (!popSnake()) {
                            clearedLevel();
                        }
                        if (this.speedUp < 0.02) {
                            this.speedUp += 0.001;
                        }
                    } else {
                        processKeystroke();
                        this.curVector.x = this.tmpVector.x;
                        this.curVector.y = this.tmpVector.y;
                        moveSnake();
                    }
                    t -= step;
                }
            }
 
            renderLevel();
            renderSnake();

            this.scoreTextShadow.render();
            this.scoreText.render();
           
            if (this.newLevelState) {
                var text:String = new String("Level ")
                text = text.concat(currentLevel + 1);
                var levelTitle:FlxText = new FlxText(0, 240*0.5 - 5, 320, 
                        text);
                levelTitle.alignment = "center";
                levelTitle.color = 0x00FF00;
                levelTitle.render();
                text = new String("Press a direction key to begin!");
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
                scoreText = new String(
                        "Press esc or enter to go back to the menu");
                levelTitle = new FlxText(0, 240*0.5 + 5, 320, scoreText);
                levelTitle.alignment = "center";
                levelTitle.color = 0xFF0000;
                levelTitle.render();
            }
            
        }

        private function clearedLevel():void
        {
            if (!this.isExiting) {
                // Exit animation
                this.isExiting = true;
                return;
            } else if (this.currentLevel < this.levelCount) {
                // Next level
                this.score += 500 * (this.currentLevel + 1);
                this.scoreText.text = this.score.toString();
                this.scoreTextShadow.text = this.score.toString();
                this.isExiting = false;
                this.speedUp = this.oldSpeedUp;
                this.t = 0.0;
                this.speedUp += 0.045 / (this.levelCount + 1);
                this.currentLevel += 1;
                this.newLevelState = true;
                loadLevel(this.currentLevel);
            } else {
                // No more levels
                wonGame();
            }
        }

        private function died():void
        {
            this.dead = true;

            if (Score.check(Score.TYPE_AMAZO, this.score))
            {
                SnakeGame.getInstance().showDialog(
                        new buttAmazoInputDialog(Score.TYPE_AMAZO, this.score));
            }
            else
            {
                SnakeGame.getInstance().showDialog(new buttAmazoEndDialog());
            }
        }

        private function wonGame():void
        {
            if (Score.check(Score.TYPE_AMAZO, this.score))
            {
                SnakeGame.getInstance().showDialog(
                        new buttAmazoInputDialog(Score.TYPE_AMAZO, this.score));
            }
            else
            {
                SnakeGame.getInstance().showDialog(new buttAmazoWonDialog());
            }
        }

        private function loadLevel(num:uint):void
        {
            this.keyStack.length = 0;
            this.hasEaten = 0;
            this.showExits = false;
            // Figure out the original syntax
            var snakeStart:Point = null;
            var snakeEnd:Point = null;
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
                        levelSprites[index] = new buttSprite(gX * 8,
                                gY % gameAreaHeight * 8, Images.AmazoBlock);
                    } else if (val == 0xFF0000) {
                        levelCollision[index] = 0;
                        snakeStart = new Point(gX, gY % gameAreaHeight);
                    } else if (val == 0x0000FF) {
                        levelCollision[index] = 0;
                        snakeEnd = new Point(gX, gY % gameAreaHeight);
                    } else if (val == 0x00FF00) {
                        var tmpSprite:buttSprite = new buttSprite(gX * 8,
                                gY % gameAreaHeight * 8, Images.AmazoExit);
                        tmpSprite.color = 0xFFFFFF;
                        levelCollision[index] = 3;
                        levelExits[index] = tmpSprite;
                        levelSprites[index] = new buttSprite(gX * 8,
                                gY % gameAreaHeight * 8, Images.AmazoBlock);
                    }
                }
            }

            // Create a new snake
            this.snake.length = 0;
            
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
                
                var frameIndex:int = 0;
                var snakeSkin:buttSprite = new buttSprite(curPos.x * 8, 
                        curPos.y * 8)
                snakeSkin.loadGraphic(Images.AmazoSnake, true, false,
                        8, 8, false);

                // Figure out which frame to use
                if (j == length) {
                    // Tail
                    frameIndex = 8;
                } else if (j == 0) {
                    // Head
                    frameIndex = 0;
                } else {
                    // Body
                    frameIndex = 4;
                }

                if ((curVector.x == 1) && (curVector.y == 0)) {
                    frameIndex += 0;
                } else if ((curVector.x == -1) && (curVector.y == 0)) {
                    frameIndex += 1;
                } else if ((curVector.x == 0) && (curVector.y == 1)) {
                    frameIndex += 3;
                } else if ((curVector.x == 0) && (curVector.y == -1)) {
                    frameIndex += 4;
                }
                
                snakeSkin.specificFrame(frameIndex);
                snake.push(snakeSkin);
                this.levelCollision[curPos.y * gameAreaWidth + curPos.x] = 2;
            }

            // Create our inital unwrapped snake
            this.unwrappedSnake = new Array();
            for (j = 0; j < 3; j++) {
                var unwrappedPart:Point = new Point(this.snake[j].x / 8,
                        this.snake[j].y / 8);
                this.unwrappedSnake.push(unwrappedPart);
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
                        if ((this.showExits) && (tileVal == 3)) {
                            this.levelExits[index].render();
                        } else if (tileVal != 2) {
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

            var didPush:Boolean = false;
            if (this.keyStack.length < 5) {
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

        // Returns false when there is no more snake :P
        // Should ONLY be used by the exit animation
        private function popSnake():Boolean
        {
            if (this.snake.length > 0) {
                var tmp:buttSprite = snake.pop();

                if (this.snake.length > 2) {
                    // Tail
                    var lastItem:int = snake.length - 1;
                    var tmpPos:Point = new Point(snake[lastItem].x,
                            snake[lastItem].y);
                    var tmpIndex:uint = 8;
                    // left or right
                    if (snake[lastItem - 1].x < tmpPos.x) {
                        tmpIndex += 1;
                    } else if (snake[lastItem - 1].x > tmpPos.x) {
                        tmpIndex += 0;
                    } else {
                        // Up or down
                        if (snake[lastItem - 1].y < tmpPos.y) {
                            tmpIndex += 2;
                        } else {
                            tmpIndex += 3;
                        }
                    }
                    snake[lastItem].specificFrame(tmpIndex);
                }
                return true;
            } else {
                return false;
            }
        }

        private function moveSnake():void
        {
            var tmpIndex:int = 0;
            var tmpPos:Point = null;
            var tmpSprite:buttSprite = null;
            var newX:int = snake[0].x + curVector.x * 8;
            var newY:int = snake[0].y + curVector.y * 8;
            var hasWrapped:Boolean = false;

            // Update the unwrappedSnake
            tmpPos = this.unwrappedSnake.pop()
            tmpPos.x = this.unwrappedSnake[0].x + curVector.x;
            tmpPos.y = this.unwrappedSnake[0].y + curVector.y;
            this.unwrappedSnake.unshift(tmpPos);

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

            if (newX == curFood.x && newY == curFood.y) {
                this.score += 20 * (this.currentLevel + 1) + 
                        this.currentLevel +1;
                this.hasEaten += 1;
                this.growCycles += 3;
                this.scoreText.text = this.score.toString();
                this.scoreTextShadow.text = this.score.toString();
                if (this.hasEaten == this.mustEat) {
                    this.showExits = true;
                    this.oldSpeedUp = this.speedUp;
                }
                makeNomNom();
            }
            if (this.hasEaten > this.mustEat) {
                if (this.speedUp <= 0.07) {
                    this.speedUp += 0.0002;
                }
            }
            
            if (isColliding(newX / 8, newY / 8)) {
                if ((this.levelCollision[(newY / 8) *
                        gameAreaWidth + (newX / 8)] == 3) && this.showExits) {
                    clearedLevel();
                } else {
                    died();
                }
                return;
            }

            if (growCycles > 0) {
                growCycles -= 1;
            } else {
                // pop snake
                var tmp:buttSprite = snake.pop();
                this.levelCollision[(tmp.y / 8) * gameAreaWidth 
                        + (tmp.x / 8)] = 0;

                // Tail
                var lastItem:int = snake.length - 1;
                tmpPos = new Point(snake[lastItem].x,
                        snake[lastItem].y);
                tmpIndex = 8;
                // left or right
                if (snake[lastItem - 1].x < tmpPos.x) {
                    tmpIndex += 1;
                } else if (snake[lastItem - 1].x > tmpPos.x) {
                    tmpIndex += 0;
                } else {
                    // Up or down
                    if (snake[lastItem - 1].y < tmpPos.y) {
                        tmpIndex += 2;
                    } else {
                        tmpIndex += 3;
                    }
                }
                snake[lastItem].specificFrame(tmpIndex);
            }

            // Body / Turn
            var uwTail:Point = this.unwrappedSnake[2];
            var uwBody:Point = this.unwrappedSnake[1];
            var uwHead:Point = this.unwrappedSnake[0];
            if (Math.sqrt(Math.pow(uwHead.x - uwTail.x, 2) + 
                    Math.pow(uwHead.y - uwTail.y, 2)) != 2) {
                tmpIndex = 12;
                // Turn body part
                if (uwBody.x > uwTail.x) {
                    // Right
                    if (uwHead.y < uwBody.y) {
                        // up
                        tmpIndex += 0;
                    } else if (uwHead.y > uwBody.y) {
                        // down
                        tmpIndex += 1;
                    }
                } else if (uwBody.x < uwTail.x) {
                    // Left
                    if (uwHead.y < uwBody.y) {
                        // up
                        tmpIndex += 5;
                    } else if (uwHead.y > uwBody.y) {
                        // down
                        tmpIndex += 4;
                    }
                } else {
                    if (uwBody.y < uwTail.y) {
                        // up
                        if (uwHead.x > uwBody.x) {
                            // right
                            tmpIndex += 2;
                        } else if (uwHead.x < uwBody.x) {
                            // left
                            tmpIndex += 3;
                        }
                    } else {
                        // Down
                        if (uwHead.x > uwBody.x) {
                            // right
                            tmpIndex += 7;
                        } else if (uwHead.x < uwBody.x) {
                            // left
                            tmpIndex += 6;
                        }
                    }
                }
            } else {
                // Straight body part
                // Right/left
                tmpIndex = 4;
                if (uwBody.x > uwTail.x) {
                    tmpIndex += 0;
                } else if (uwBody.x < uwTail.x) {
                    tmpIndex += 1;
                } else {
                    // Top/bottom
                    if (uwBody.y > uwTail.y) {
                        tmpIndex += 3;
                    } else {
                        tmpIndex += 2;
                    }
                }
            }
            snake[0].specificFrame(tmpIndex);

            // Head
            tmpIndex = 0;
            // left/right
            if (this.curVector.x == 1) {
                tmpIndex += 0;
            } else if (this.curVector.x == -1) {
                tmpIndex += 1;
            } else {
                // up/down
                if (this.curVector.y == -1) {
                    tmpIndex += 2;
                } else {
                    tmpIndex += 3;
                }
            }

            // Push snake
            this.levelCollision[(newY / 8) *
                    gameAreaWidth + (newX / 8)] = 2;
            tmpSprite = new buttSprite(newX, newY);
            tmpSprite.loadGraphic(Images.AmazoSnake, true, false,
                        8, 8, false);
            tmpSprite.specificFrame(tmpIndex);
            snake.unshift(tmpSprite);
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

            curFood = new buttSprite(newX, newY, Images.AmazoFood);
            curFood.color = 0xFFFFFF;
        }
	}
}
