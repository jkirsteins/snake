package
{
	import org.flixel.*;
    import flash.geom.*;
    import mx.controls.TextInput;

    // for http requests (- janis)
    import mx.rpc.http.*;
    import mx.rpc.events.*;

	public class PlayState extends FlxState
	{
        // Keeping track of stuff
        public var score:uint = 0;
        private var hasEaten:uint = 0;
        private var mustEat:uint = 8;
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

            var _input:TextInput = new TextInput();
            _input.editable = true;

            this.addChild(_input);
		}

        public override function update():void
        {
            getInput();

            if ((!this.newLevelState) && (!this.dead)) {
                t += FlxG.elapsed;
                curFood.render();
                var step:Number = 0.06 - speedUp;
                while (t > step) {
                    trace(t, step, this.isExiting);
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
                //this.oldSpeedUp = this.speedUp;
                return;
            } else if (this.currentLevel < this.levelCount) {
                // Next level
                this.score += 500 * (this.currentLevel + 1);
                this.isExiting = false;
                this.speedUp = this.oldSpeedUp;
                this.t = 0.0;
                this.speedUp += 0.02 / (this.levelCount + 1);
                this.currentLevel += 1;
                this.newLevelState = true;
                loadLevel(this.currentLevel);
            } else {
                // No more levels
                FlxG.switchState(MenuState);
            }
        }

        private function uploadScore():Boolean
        {
            var transport: HTTPService = new HTTPService();
            transport.url = "http://janiskirsteins.org/snake.php";
            transport.method = "GET";
            transport.resultFormat = "text";
            //this.score };

            transport.addEventListener("result", 
                    function (event: ResultEvent): void
                    {
                        FlxG.log("Result: ");
                        FlxG.log(event.result);
                    });
            transport.addEventListener("fault",
                    function (event: FaultEvent): void 
                    {
                        var faultstring: String = event.fault.faultString;
                        FlxG.log("FAILED: " + faultstring);
                    });
            transport.send({name: 'kirsis', score: this.score});
            FlxG.log('sent');
            return true;
        }
        private function died():void
        {
            this.dead = true;
            uploadScore();
        }

        private function loadLevel(num:uint):void
        {
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
                                gY % gameAreaHeight * 8);
                    } else if (val == 0xFF0000) {
                        levelCollision[index] = 0;
                        snakeStart = new Point(gX, gY % gameAreaHeight);
                    } else if (val == 0x0000FF) {
                        levelCollision[index] = 0;
                        snakeEnd = new Point(gX, gY % gameAreaHeight);
                    } else if (val == 0x00FF00) {
                        var tmpSprite:buttSprite = new buttSprite(gX * 8,
                                gY % gameAreaHeight * 8);
                        tmpSprite.color = 0x00FF00;
                        levelCollision[index] = 3;
                        levelExits[index] = tmpSprite;
                        levelSprites[index] = new buttSprite(gX * 8,
                                gY % gameAreaHeight * 8);
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

            /*
            if (this.newLevelState) {
                if (FlxG.keys.justPressed('SPACE')) {
                    this.newLevelState = false;
                }
                return;
            }
            */

            if (this.dead) {
                if (FlxG.keys.justPressed('ENTER')) {
                    FlxG.switchState(MenuState);
                }
                return;
            }

            var didPush:Boolean = false;
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
                return true;
            } else {
                return false;
            }
        }

        private function moveSnake():void
        {
            var newX:int = snake[0].x + curVector.x * 8;
            var newY:int = snake[0].y + curVector.y * 8;
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

            if (newX == curFood.x && newY == curFood.y) {
                this.score += 20 * (this.currentLevel + 1);
                this.hasEaten += 1;
                this.growCycles += 3;
                if (this.hasEaten == this.mustEat) {
                    this.showExits = true;
                }
                makeNomNom();
            }
            if (this.hasEaten > this.mustEat) {
                if (this.speedUp < 0.02) {
                    this.speedUp += 0.0001;
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
            }

            // Push snake
            this.levelCollision[(newY / 8) *
                    gameAreaWidth + (newX / 8)] = 2;
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
