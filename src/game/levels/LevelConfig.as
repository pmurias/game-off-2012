package game.levels {
    import game.GameContext;
    import game.Level;
	/**
     * ...
     * @author mosowski
     */
    public class LevelConfig {
        public var gameCtx:GameContext;
        public var level:Level;
        public var alphaScale:Number;
        public var nextLevelConfig:Class;
        public var musicId:String;

        public function LevelConfig(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            alphaScale = 1.0;
        }

        public function init():void {

        }
    }

}