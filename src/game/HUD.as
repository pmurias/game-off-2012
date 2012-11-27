package game {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import gremlin.events.KeyCodes;
	/**
     * ...
     * @author mosowski
     */
    public class HUD {
        private var gameCtx:GameContext;
        public var sprite:Sprite;
        public var pointsTextField:TextField;
        public var deathsTextField:TextField;

        public function HUD(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            sprite = new Sprite();
            gameCtx.stage.addChild(sprite);

            pointsTextField = new TextField();
            sprite.addChild(pointsTextField);
            pointsTextField.x = 20;
            pointsTextField.y = 20;
            pointsTextField.width = 200;
            pointsTextField.textColor = 0xFFFFFF;
            pointsTextField.alpha = 0.6;
            pointsTextField.embedFonts = true;
            pointsTextField.defaultTextFormat = new TextFormat("FontGhostWriter", 25);
            pointsTextField.text = "Points: 0";
            pointsTextField.selectable = false;

            deathsTextField = new TextField();
            sprite.addChild(deathsTextField);
            deathsTextField.x = 20;
            deathsTextField.y = 45;
            deathsTextField.width = 200;
            deathsTextField.textColor = 0xFFFFFF;
            deathsTextField.alpha = 0.6;
            deathsTextField.embedFonts = true;
            deathsTextField.defaultTextFormat = new TextFormat("FontGhostWriter", 20);
            deathsTextField.text = "Deaths: 0";
            deathsTextField.selectable = false;

            //createFakeScreenKeys();
        }

        public var keyUp:Sprite;
        public var keyDown:Sprite;
        public var keyRight:Sprite;
        public var keyLeft:Sprite;

        public function createFakeScreenKeys():void {
            keyUp = new Sprite();
            keyUp.x = gameCtx.stage.stageWidth - 200;
            keyUp.y = gameCtx.stage.stageHeight - 200;
            keyUp.graphics.beginFill(0x0000FF, 0.3);
            keyUp.graphics.drawCircle(0, 0, 30);
            keyUp.graphics.endFill();
            keyUp.addEventListener(MouseEvent.MOUSE_DOWN, function(me:MouseEvent):void {
                gameCtx.ctx.keyboardState.setKeyDown(KeyCodes.KC_UP);
            });
            keyUp.addEventListener(MouseEvent.MOUSE_UP, function(me:MouseEvent):void {
                gameCtx.ctx.keyboardState.setKeyUp(KeyCodes.KC_UP);
            });
            gameCtx.stage.addChild(keyUp);

            keyDown = new Sprite();
            keyDown.x = gameCtx.stage.stageWidth - 200;
            keyDown.y = gameCtx.stage.stageHeight - 70;
            keyDown.graphics.beginFill(0x0000FF, 0.3);
            keyDown.graphics.drawCircle(0, 0, 30);
            keyDown.graphics.endFill();
            keyDown.addEventListener(MouseEvent.MOUSE_DOWN, function(me:MouseEvent):void {
                gameCtx.ctx.keyboardState.setKeyDown(KeyCodes.KC_DOWN);
            });
            keyDown.addEventListener(MouseEvent.MOUSE_UP, function(me:MouseEvent):void {
                gameCtx.ctx.keyboardState.setKeyUp(KeyCodes.KC_DOWN);
            });
            gameCtx.stage.addChild(keyDown);

            keyRight = new Sprite();
            keyRight.x = gameCtx.stage.stageWidth - 100;
            keyRight.y = gameCtx.stage.stageHeight - 135;
            keyRight.graphics.beginFill(0x0000FF, 0.3);
            keyRight.graphics.drawCircle(0, 0, 30);
            keyRight.graphics.endFill();
            keyRight.addEventListener(MouseEvent.MOUSE_DOWN, function(me:MouseEvent):void {
                gameCtx.ctx.keyboardState.setKeyDown(KeyCodes.KC_RIGHT);
            });
            keyRight.addEventListener(MouseEvent.MOUSE_UP, function(me:MouseEvent):void {
                gameCtx.ctx.keyboardState.setKeyUp(KeyCodes.KC_RIGHT);
            });
            gameCtx.stage.addChild(keyRight);

            keyLeft = new Sprite();
            keyLeft.x = gameCtx.stage.stageWidth - 300;
            keyLeft.y = gameCtx.stage.stageHeight - 135;
            keyLeft.graphics.beginFill(0x0000FF, 0.3);
            keyLeft.graphics.drawCircle(0, 0, 30);
            keyLeft.graphics.endFill();
            keyLeft.addEventListener(MouseEvent.MOUSE_DOWN, function(me:MouseEvent):void {
                gameCtx.ctx.keyboardState.setKeyDown(KeyCodes.KC_LEFT);
            });
            keyLeft.addEventListener(MouseEvent.MOUSE_UP, function(me:MouseEvent):void {
                gameCtx.ctx.keyboardState.setKeyUp(KeyCodes.KC_LEFT);
            });
            gameCtx.stage.addChild(keyLeft);
        }

    }

}