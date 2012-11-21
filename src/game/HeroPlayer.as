package game {
    import flash.geom.Vector3D;
    import game.pickable.Pickable;
    import gremlin.core.Context;
    import gremlin.scene.AnimatedEntity;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class HeroPlayer extends Hero {
        public var entity:ModelEntity;
        public var rotation:Number;

        public function HeroPlayer(gameCtx:GameContext) {
            super(gameCtx);

            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("Hero"), node);
            entity.addToScene(gameCtx.layer0);
            rotation = 0;
            shadow.node.setScale(1.5, 1, 1.5);
            radius = 0.5;
        }

        override public function tick():void {
            super.tick();

            if (velocity.x != 0 || velocity.z != 0) {
                var newRot:Number = Math.atan2( -velocity.x, -velocity.z);

                rotation = gameCtx.ctx.mathUtils.getSmoothlyBlendedAngle(rotation, newRot, 0.1);
            }

            node.getRotation().setFromAxisAngle(Vector3D.Y_AXIS, rotation);

            for (var i:int = 0; i < gameCtx.pickables.length; ++i) {
                var pickable:Pickable = gameCtx.pickables[i];
                if (gameCtx.ctx.mathUtils.squaredDistanceXZ(pickable.node.position, node.position) < (pickable.radius+radius)*(pickable.radius+radius)) {
                    pickable.onPick(this);
                }
            }
        }

        override public function destroy():void {
            super.destroy();
        }
    }

}