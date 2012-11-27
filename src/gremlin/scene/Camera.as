package gremlin.scene {
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import gremlin.core.Context;

    /**
     * ...
     * @author mosowski
     */
    public class Camera {
        public var ctx:Context;
        public var viewMatrix:Matrix3D;
        public var projectionMatrix:Matrix3D;
        public var cameraMatrix:Matrix3D;

        public function Camera(ctx:Context) {
            this.ctx = ctx;
            viewMatrix = new Matrix3D();
            projectionMatrix = new Matrix3D();
            cameraMatrix = new Matrix3D();
        }

        public function update():void {
            cameraMatrix.copyFrom(viewMatrix);
            cameraMatrix.append(projectionMatrix);
        }

        public function getScreenPosition(v:Vector3D, out:Point):void {
            var outVec:Vector3D = cameraMatrix.transformVector(v);

            if (outVec.z < 0) {
                out.x = 10000;
                out.y = 10000;
            } else {
                out.x = (outVec.x / outVec.w + 1) * ctx.stage.stageWidth * 0.5;
                out.y = (outVec.y / outVec.w - 1) * -ctx.stage.stageHeight * 0.5;
            }
        }

    }

}