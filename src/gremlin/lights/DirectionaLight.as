package gremlin.lights {
    import flash.geom.Vector3D;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class DirectionaLight implements ILight {
        public var direction:Vector3D;
        public var scene:Scene;

        public function DirectionaLight() {
            direction = new Vector3D(0,-1,0);
        }

        public function setDirection(x:Number, y:Number, z:Number):void {
            direction.setTo(x, y, z);
            direction.normalize();
        }

        public function setDirectionFromVector(directionVector:Vector3D):void {
            direction.copyFrom(directionVector);
            direction.normalize();
        }

        public function setScene(_scene:Scene):void {
            if (scene) {
                scene.removeDirectionalLight(this);
            }
            scene = _scene;
            scene.addDirectionalLight(this);
        }

        public function getPosition():Vector3D {
            return direction;
        }

    }

}