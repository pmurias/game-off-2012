package game.pickable {
    import game.GameContext;
    import game.Hero;
    import gremlin.scene.ModelEntity;
	/**
     * ...
     * @author mosowski
     */
    public class PickableEye extends Pickable {

        public function PickableEye(gameCtx:GameContext) {
            super(gameCtx);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("PickableEye"), node);
            entity.addToScene(gameCtx.layer0);
            enableCollision();
        }

        override protected function pickCallback(hero:Hero):Boolean {
            gameCtx.setCheckpoint(node.position);
            return true;
        }

    }

}