package game {
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class BeholderDead extends Doodad {
        public function BeholderDead(gameCtx:GameContext, caster:Node) {
            super(gameCtx, caster);
            gameCtx.deadBodies.push(this);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("BeholderDead"), node);
            entity.addToScene(gameCtx.layer0);
        }

        override public function destroy():void {
            super.destroy();
            gameCtx.deadBodies.splice(gameCtx.deadBodies.indexOf(this), 1);
        }
    }

}