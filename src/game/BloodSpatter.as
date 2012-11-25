package game {
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class BloodSpatter extends Doodad {
        public function BloodSpatter(gameCtx:GameContext, caster:Node) {
            super(gameCtx, caster);
            gameCtx.bloodSpatters.push(this);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("BloodSpatter"), node);
            entity.addToScene(gameCtx.layer0);
        }

        override public function destroy():void {
            super.destroy();
            gameCtx.bloodSpatters.splice(gameCtx.bloodSpatters.indexOf(this), 1);
        }
    }

}