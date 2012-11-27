package game.levels {
    import game.GameContext;
    import game.Level;
    import game.MusicId;
	/**
     * ...
     * @author mosowski
     */
    public class Level4 extends LevelConfig{

        public function Level4(_gameCtx:GameContext) {
            super(_gameCtx);
            alphaScale = 0.8;
            nextLevelConfig = Level5;
            musicId = MusicId.AVEMARIJKA;
        }

        override public function init():void {
            level = new Level(gameCtx, 0, 0, 0, gameCtx.ctx.rootNode);
            level.fromObject(gameCtx.ctx.loaderMgr.getLoaderJSON("static/level4.bmap"), gameCtx.tileSet);
            level.layers[0].setScene(gameCtx.layer0);
        }

    }

}