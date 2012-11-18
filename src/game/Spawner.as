package game {
    import flash.geom.Vector3D;
	/**
     * ...
     * @author mosowski
     */
    public class Spawner {
        public var position:Vector3D;
        public var direction:Vector3D;
        public var speed:Number;
        public var delay:Number;

        public var lastSpawnTime:Number;

        public function Spawner() {
            position = new Vector3D();
            direction = new Vector3D();
        }

        public function fromObject(object:Object):void {
            speed = object.speed;
            delay = object.delay;
            direction.setTo(Math.sin(object.angle), 0, Math.cos(object.angle));
            position.setTo(object.position[0], object.position[1], object.position[2]);
        }

    }

}