package game.pickable {
    import game.GameContext;
    import game.Hero;
    import game.modes.FairMode;
	/**
     * ...
     * @author mosowski
     */
    public class PickableFairMode extends PickableBonus {

        public function PickableFairMode(gameCtx:GameContext) {
            super(gameCtx);
            setMaterial(gameCtx.ctx.materialMgr.getMaterial("PickableF"));
        }

        override protected function pickCallback(hero:Hero):Boolean {
            gameCtx.enterMode(new FairMode(gameCtx));
            return true;
        }

    }

}