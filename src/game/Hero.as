package game {
    import flash.geom.Vector3D;
    import gremlin.core.Context;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class Hero {
        public var gameCtx:GameContext;
        public var velocity:Vector3D;
        public var position:Vector3D;
        public var moveTarget:Vector3D;
        public var moveTargetSet:Boolean;
        public var speed:Number;
        public var scene:Scene;

        public function Hero(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            velocity = new Vector3D();
            position = new Vector3D();
            moveTarget = new Vector3D();
            speed = 1.0;
        }

        public function setPosition(x:Number, y:Number, z:Number):void {
            position.setTo(x, y, z);
        }

        public function moveTo(x:Number, y:Number, z:Number):void {
            moveTargetSet = true;
            moveTarget.setTo(x, y, z);
        }

        public function setVelocity(x:Number, y:Number, z:Number):void {
            velocity.setTo(x, y, z);
        }

        public function tick():void {
            if (moveTargetSet) {
                velocity.setTo(moveTarget.x - position.x, moveTarget.y - position.y, moveTarget.z - position.z);
                if (velocity.lengthSquared < 0.1) {
                    velocity.setTo(0, 0, 0);
                    moveTargetSet = false;
                } else {
                    velocity.normalize();
                    velocity.scaleBy(speed);
                }
            }
            position.incrementBy(velocity);
            if (gameCtx.level.layers[0].tiles[int(position.x / 2)][int(position.z / 2)].type.name == "block") {
                position.decrementBy(velocity);
            }
        }

        public function setScene(scene:Scene):void {

        }

    }

}