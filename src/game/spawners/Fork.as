package game.spawners {
    import flash.geom.Vector3D;
    import game.CollisionComponent;
    import game.GameContext;
    import gremlin.math.Quaternion;
    import gremlin.scene.ModelEntity;
	/**
     * ...
     * @author mosowski
     */
    public class Fork extends SharpItem {
        public var entity:ModelEntity;

        public function Fork(_gameCtx:GameContext) {
            super(_gameCtx);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("Fork"), node);
            entity.addToScene(gameCtx.layer0);
            collisionComponent = new CollisionComponent(node);
            collisionComponent.setBounds(entity.modelResource.collisionData.collision2d[0]);
            collisionComponent.useFullTransformation = true;
            enableShadow();
            shadow.node.setScale(1, 1, 0.2);
        }

        override protected function customTick():void {
            var rotation:Number = Math.atan2(direction.x, direction.z);
            node.getRotation().setFromAxisAngle(Vector3D.Y_AXIS, rotation);
        }

        override public function destroy():void {
            super.destroy();
            entity.removeFromScene(gameCtx.layer0);
        }

    }

}