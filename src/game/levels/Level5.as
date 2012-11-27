package game.levels {
    import game.GameContext;
    import game.Level;
    import game.MusicId;
	/**
     * ...
     * @author mosowski
     */
    public class Level5 extends LevelConfig{

        public function Level5(_gameCtx:GameContext) {
            super(_gameCtx);
            alphaScale = 1.0;
            nextLevelConfig = Level6;
            musicId = MusicId.NOTSOHARD;
        }

        override public function init():void {
            level = new Level(gameCtx, 0, 0, 0, gameCtx.ctx.rootNode);
            level.fromObject(gameCtx.ctx.loaderMgr.getLoaderJSON("static/level5.bmap"), gameCtx.tileSet);
            level.layers[0].setScene(gameCtx.layer0);
        }

    }

}