package game.levels {
    import game.GameContext;
    import game.Level;
    import game.MusicId;
	/**
     * ...
     * @author mosowski
     */
    public class Level6 extends LevelConfig{

        public function Level6(_gameCtx:GameContext) {
            super(_gameCtx);
            alphaScale = 3.0;
            nextLevelConfig = Level7;
            musicId = MusicId.OJOJOJ;
        }

        override public function init():void {
            level = new Level(gameCtx, 0, 0, 0, gameCtx.ctx.rootNode);
            level.fromObject(gameCtx.ctx.loaderMgr.getLoaderJSON("static/level6.bmap"), gameCtx.tileSet);
            level.layers[0].setScene(gameCtx.layer0);
        }

    }

}