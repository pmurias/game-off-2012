package game.pickable {
    import game.GameContext;
    import game.Hero;
    import game.modes.CloningMode;
    import game.modes.FairMode;
	/**
     * ...
     * @author mosowski
     */
    public class PickableMerge extends PickableBonus {

        public function PickableMerge(gameCtx:GameContext) {
            super(gameCtx);
            setMaterial(gameCtx.ctx.materialMgr.getMaterial("PickableM"));
            enableCollision();
        }

        override protected function pickCallback(hero:Hero):Boolean {
            if (gameCtx.mode is CloningMode) {
                gameCtx.enterMode(new FairMode(gameCtx));
                gameCtx.splasher.splashBitmap(new gameCtx.staticEmbeded.merge_mode());
            }
            return true;
        }

    }

}