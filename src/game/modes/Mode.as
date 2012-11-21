package game.modes {
    import game.GameContext;
    import gremlin.core.Context;
    import gremlin.events.EventDispatcher;
	/**
     * ...
     * @author mosowski
     */
    public class Mode extends EventDispatcher {
        public var gameCtx:GameContext;
        public var ctx:Context;

        public static const MODE_EXITED:String = "mode_exited";

        public function Mode(gameCtx:GameContext) {
            this.gameCtx = gameCtx;
            ctx = gameCtx.ctx;
        }

        public function enter():void {

        }

        public function exit():void {

        }

        public function render():void {

        }

        public function tick():void {

        }

        public function processInput():void {
        }

    }

}