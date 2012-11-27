package game.levels {
    import game.GameContext;
    import game.Level;
    import game.MusicId;
	/**
     * ...
     * @author mosowski
     */
    public class Level1 extends LevelConfig{

        public function Level1(_gameCtx:GameContext) {
            super(_gameCtx);
            alphaScale = 0;
            nextLevelConfig = Level2;
            musicId = MusicId.AVEMARIJKA;
        }

        override public function init():void {
            level = new Level(gameCtx, 0, 0, 0, gameCtx.ctx.rootNode);
            level.fromObject(gameCtx.ctx.loaderMgr.getLoaderJSON("static/level1.bmap"), gameCtx.tileSet);
            level.layers[0].setScene(gameCtx.layer0);
        }

    }

}