package game {
    import flash.display.Bitmap;
    import flash.display.Stage;
	/**
     * ...
     * @author mosowski
     */
    public class Splasher {
        public var gameCtx:GameContext

        public function Splasher(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
        }

        public function splashBitmap(bitmap:Bitmap):void {
            var splash:SplashEffect = new SplashEffect(bitmap, gameCtx.time);
            gameCtx.stage.addChild(splash.sprite);
            splash.sprite.x = gameCtx.stage.stageWidth / 2;
            splash.sprite.y = gameCtx.stage.stageHeight / 2;
            splash.sprite.scaleX = 0;
            splash.sprite.scaleY = 0;
            gameCtx.ctx.tweener.tween(splash.sprite, "rotation", 0, 370, 0.5, null);
            gameCtx.ctx.tweener.tween(splash.sprite, "scaleX", 0, 0.9, 0.5, null);
            gameCtx.ctx.tweener.tween(splash.sprite, "scaleY", 0, 0.9, 0.5, function():void {
                gameCtx.ctx.tweener.tween(splash.sprite, "scaleX", 0.9, 1, 2.0, null);
                gameCtx.ctx.tweener.tween(splash.sprite, "scaleY", 0.9, 1, 2.0, function():void {
                    gameCtx.ctx.tweener.tween(splash.sprite, "alpha", 1, 0, 0.5, null);
                    gameCtx.ctx.tweener.tween(splash.sprite, "scaleX", 1, 10, 0.5, null);
                    gameCtx.ctx.tweener.tween(splash.sprite, "scaleY", 1, 10, 0.5, function():void {
                        gameCtx.stage.removeChild(splash.sprite);
                    });
                });
            });
        }
    }
}