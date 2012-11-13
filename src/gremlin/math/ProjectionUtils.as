package gremlin.math {
    import flash.geom.Matrix3D;

    /**
     * ...
     * @author mosowski
     */
    public class ProjectionUtils {
        private var matrixData:Vector.<Number>;

        public function ProjectionUtils() {
            matrixData = new Vector.<Number>(16, true);
        }

        public function makePerspectiveMatrix(mtx:Matrix3D, near:Number, far:Number, fov:Number, aspect:Number):void {
            var top:Number = near * Math.tan(fov * Math.PI / 360.0);
            var right:Number = top * aspect;

            matrixData[0] = near / right;
            matrixData[1] = 0;
            matrixData[2] = 0;
            matrixData[3] = 0;

            matrixData[4] = 0;
            matrixData[5] = near / top;
            matrixData[6] = 0;
            matrixData[7] = 0;

            matrixData[8] = 0;
            matrixData[9] = 0;
            matrixData[10] = (far + near) / (far - near);
            matrixData[11] = 1;

            matrixData[12] = 0;
            matrixData[13] = 0;
            matrixData[14] = -(far * near * 2) / (far - near);
            matrixData[15] = 0;

            mtx.copyRawDataFrom(matrixData);
        }

    }

}