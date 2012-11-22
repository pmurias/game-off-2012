package game.pickable {
    import game.GameContext;
    import game.Hero;
    import game.modes.CloningMode;
	/**
     * ...
     * @author mosowski
     */
    public class PickableCloningMode extends PickableBonus{

        public function PickableCloningMode(gameCtx:GameContext) {
            super(gameCtx);
            setMaterial(gameCtx.ctx.materialMgr.getMaterial("PickableC"));
            enableCollision();
        }

        override protected function pickCallback(hero:Hero):Boolean {
            gameCtx.enterMode(new CloningMode(gameCtx));
            return true;
        }

    }

}