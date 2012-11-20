package game {
    import gremlin.meshes.ModelResource;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class Shadow {
        public var gameCtx:GameContext;
        public var node:Node;
        public var entity:ModelEntity;
        public var caster:Node;

        public function Shadow(gameCtx:GameContext, caster:Node) {
            this.gameCtx = gameCtx;
            this.caster = caster;
            node  = new Node();
            gameCtx.ctx.rootNode.addChild(node);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("RoundShadow"), node);
            entity.addToScene(gameCtx.layer0);
        }

        public function tick():void {
            node.setPosition(caster.position.x, 0.1, caster.position.z);
        }

        public function destroy():void {
            gameCtx.ctx.rootNode.removeChild(node);
            entity.removeFromScene(gameCtx.layer0);
        }

    }

}