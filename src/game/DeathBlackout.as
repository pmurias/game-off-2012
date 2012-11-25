package game {
    import gremlin.core.Context;
    import gremlin.events.EventDispatcher;
    import gremlin.gremlin2d.Quad2d;
	/**
     * ...
     * @author mosowski
     */
    public class DeathBlackout extends EventDispatcher {
        public var gameCtx:GameContext;
        public var animating:Boolean;
        public var alpha:Number;
        public var quad:Quad2d;

        public static const BLACKOUT_COMPLETED:String = "blackout_completed";

        public function DeathBlackout(_gameCtx:GameContext) {
            gameCtx = _gameCtx;

            quad = new Quad2d();
            quad.setMaterial(gameCtx.ctx.materialMgr.getMaterial("Black2d"));
            gameCtx.ctx.addListener(Context.RESIZE, resizeQuad);
            resizeQuad();
        }

        public function resizeQuad(params:Object = null):void {
            quad.transformation.identity();
            quad.transformation.scale(gameCtx.ctx.stage.stageWidth, gameCtx.ctx.stage.stageHeight);
            quad.transformation.translate(gameCtx.ctx.stage.stageWidth / 2, gameCtx.ctx.stage.stageHeight / 2);
        }

        public function begin():void {
            alpha = 0;
            animating = true;
            quad.setScene(gameCtx.layerGUI);
            quad.color.w = 0;
        }

        public function dismiss():void {
            removeAllListeners(BLACKOUT_COMPLETED);
            end();
        }

        public function end():void {
            quad.setScene(null);
            animating = false;
        }

        public function tick():void {
            if (alpha < 1 && animating == true) {
                alpha += gameCtx.timeStep * 0.35;
                if (alpha >= 1) {
                    alpha = 1;
                    dispatch(BLACKOUT_COMPLETED);
                }
            }
            quad.color.w = alpha;
        }

    }

}