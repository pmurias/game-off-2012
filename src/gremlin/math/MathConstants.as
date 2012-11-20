package gremlin.math {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    /**
     * ...
     * @author mosowski
     */
    public class MathConstants {
        public const identityMatrix:Matrix3D = new Matrix3D();

        public function squaredDistanceXZ(a:Vector3D, b:Vector3D):Number {
            return (a.x - b.x) * (a.x - b.x) + (a.z - b.z) * (a.z - b.z);
        }

    }

}