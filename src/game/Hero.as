package game {
    import flash.geom.Vector3D;
    import gremlin.core.Context;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class Hero extends GameObject {
        public var velocity:Vector3D;
        public var moveTarget:Vector3D;
        public var moveTargetSet:Boolean;
        public var speed:Number;
        public var scene:Scene;

        public function Hero(gameCtx:GameContext) {
            super(gameCtx);
            gameCtx.heroes.push(this);
            gameCtx.heroesById[id] = this;

            velocity = new Vector3D();
            moveTarget = new Vector3D();
            speed = 1.0;
            enableShadow();
        }

        public function setPosition(x:Number, y:Number, z:Number):void {
            node.setPosition(x, y, z);
        }

        public function moveTo(x:Number, y:Number, z:Number):void {
            moveTargetSet = true;
            moveTarget.setTo(x, y, z);
        }

        public function setVelocity(x:Number, y:Number, z:Number):void {
            velocity.setTo(x, y, z);
        }

        override public function tick():void {
            super.tick();
            if (moveTargetSet) {
                velocity.setTo(moveTarget.x - node.position.x, moveTarget.y - node.position.y, moveTarget.z - node.position.z);
                if (velocity.lengthSquared < 0.1) {
                    velocity.setTo(0, 0, 0);
                    moveTargetSet = false;
                } else {
                    velocity.normalize();
                    velocity.scaleBy(speed);
                }
            }
            node.position.incrementBy(velocity);
            if (gameCtx.level.getTileAtPosition(node.position, 0).type.blocking) {
                node.position.decrementBy(velocity);
            }
            if (velocity.lengthSquared > 0) {
                node.markAsDirty();
            }
        }

        override public function destroy():void {
            super.destroy();
            gameCtx.heroes.splice(gameCtx.heroes.indexOf(this), 1);
            delete gameCtx.heroesById[id];
        }

    }

}