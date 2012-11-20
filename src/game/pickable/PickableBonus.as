package game.pickable {
    import game.GameContext;
    import game.Hero;
    import gremlin.materials.Material;
    import gremlin.scene.ModelEntity;
	/**
     * ...
     * @author mosowski
     */
    public class PickableBonus extends Pickable {

        public function PickableBonus(gameCtx:GameContext) {
            super(gameCtx);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("Pickable"), node);
            entity.addToScene(gameCtx.layer0);
        }

        public function setMaterial(material:Material):void {
            entity.getSubmeshEntityByMaterial(gameCtx.ctx.materialMgr.getMaterial("Pickable")).setMaterial(material);
        }

        override protected function pickCallback(hero:Hero):Boolean {
            return true;
        }

    }

}