package gremlin.scene {
    import flash.geom.Matrix3D;

    /**
     * ...
     * @author mosowski
     */
    public class Camera {
        public var viewMatrix:Matrix3D;
        public var projectionMatrix:Matrix3D;
        public var cameraMatrix:Matrix3D;

        public function Camera() {
            viewMatrix = new Matrix3D();
            projectionMatrix = new Matrix3D();
            cameraMatrix = new Matrix3D();
        }

        public function update():void {
            cameraMatrix.copyFrom(viewMatrix);
            cameraMatrix.append(projectionMatrix);
        }

    }

}