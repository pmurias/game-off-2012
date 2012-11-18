package game {
    import flash.geom.Vector3D;
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
        public var node:Node;
        public var rotation:Number;

        public function HeroPlayer(_gameCtx:GameContext) {
            super(_gameCtx);
            node = new Node();
            gameCtx.ctx.rootNode.addChild(node);
            entity = new ModelEntity(gameCtx.ctx.modelMgr.getModelResource("Hero"), node);
            rotation = 0;
        }

        override public function setScene(_scene:Scene):void {
            scene = _scene;
            entity.addToScene(scene);
        }

        override public function tick():void {
            super.tick();

            if (velocity.x != 0 || velocity.z != 0) {
                var newRot:Number = Math.atan2( -velocity.x, -velocity.z);

                if (newRot - rotation > Math.PI) {
                    rotation += Math.PI * 2;
                } else if (rotation - newRot > Math.PI) {
                    newRot += Math.PI * 2;
                }
                rotation += (newRot - rotation) * 0.1;
                rotation = (rotation + Math.PI) % (Math.PI * 2) - Math.PI;
            }

            node.getRotation().setFromAxisAngle(Vector3D.Y_AXIS, rotation);


            node.copyPositionFrom(position);
        }
    }

}