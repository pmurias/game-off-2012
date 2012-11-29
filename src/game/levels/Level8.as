package game.levels {
    import game.GameContext;
    import game.Level;
    import game.MusicId;
	/**
     * ...
     * @author mosowski
     */
    public class Level8 extends LevelConfig{

        public function Level8(_gameCtx:GameContext) {
            super(_gameCtx);
            alphaScale = 6.0;
            nextLevelConfig = Level0;
            musicId = MusicId.MANIA;
        }

        override public function init():void {
            level = new Level(gameCtx, 0, 0, 0, gameCtx.ctx.rootNode);
            level.fromObject(gameCtx.ctx.loaderMgr.getLoaderJSON("static/level8.bmap"), gameCtx.tileSet);
            level.layers[0].setScene(gameCtx.layer0);
        }

    }

}