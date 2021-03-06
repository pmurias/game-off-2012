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
    public class Blade extends SharpItem {
        public var entity:ModelEntity;
        public var rotation:Number;

        public var spinningSpeed:Number;

        public function Blade(_gameCtx:GameContext) {
            super(_gameCtx);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("Blade"), node);
            entity.addToScene(gameCtx.layer0);
            collisionComponent = new CollisionComponent(node);
            collisionComponent.setBounds(entity.modelResource.collisionData.collision2d);
            rotation = 0;
            spinningSpeed = 0.3;
            enableShadow();
        }

        override protected function customTick():void {
            spinningSpeed = 0.3 * Math.sqrt(speed/2);
            rotation += spinningSpeed;

            node.getRotation().identity();
            node.getRotation().multiplyByAngleAxis(Vector3D.Y_AXIS, rotation);
        }

        override public function destroy():void {
            super.destroy();
            entity.removeFromScene(gameCtx.layer0);
        }

    }

}