package game {
    import gremlin.scene.ModelEntity;
	/**
     * ...
     * @author mosowski
     */
    public class Crate extends GameObject {
        public var entity:ModelEntity;

        public function Crate(gameCtx:GameContext) {
            super(gameCtx);
            gameCtx.crates.push(this);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("Crate"), node);
            entity.addToScene(gameCtx.layer0);
            enableShadow();
            shadow.node.setScale(3, 1, 3);

            collisionComponent = new CollisionComponent(node);
            collisionComponent.setBounds(entity.modelResource.collisionData.collision2d);
        }

        override public function destroy():void {
            super.destroy();
            entity.removeFromAllScenes();
            gameCtx.crates.splice(gameCtx.crates.indexOf(this), 1);
        }

    }

}