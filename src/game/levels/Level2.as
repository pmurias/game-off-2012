package game.levels {
    import game.GameContext;
    import game.Level;
    import game.MusicId;
	/**
     * ...
     * @author mosowski
     */
    public class Level2 extends LevelConfig{

        public function Level2(_gameCtx:GameContext) {
            super(_gameCtx);
            alphaScale = 0.1;
            nextLevelConfig = Level3;
            musicId = MusicId.AVEMARIJKA;
        }

        override public function init():void {
            level = new Level(gameCtx, 0, 0, 0, gameCtx.ctx.rootNode);
            level.fromObject(gameCtx.ctx.loaderMgr.getLoaderJSON("static/level2.bmap"), gameCtx.tileSet);
            level.layers[0].setScene(gameCtx.layer0);
        }

    }

}