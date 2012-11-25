package gremlin.math {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    /**
     * ...
     * @author mosowski
     */
    public class MathUtils {
        public const identityMatrix:Matrix3D = new Matrix3D();

        public function squaredDistanceXZ(a:Vector3D, b:Vector3D):Number {
            return (a.x - b.x) * (a.x - b.x) + (a.z - b.z) * (a.z - b.z);
        }

        public function getSmoothlyBlendedAngle(from:Number, to:Number, factor:Number):Number {
            if (to - from > Math.PI) {
                from += Math.PI * 2;
            } else if (from - to > Math.PI) {
                to += Math.PI * 2;
            }
            from += (to - from) * 0.1;
            return (from + Math.PI) % (Math.PI * 2) - Math.PI;
        }

        // return angle @from shifted to @to (0..2PI) in a shorter way by @shift
        public function getShiftedAngle(from:Number, to:Number, shift:Number):Number {
            if (to - from > Math.PI) {
                return (from - shift) % (Math.PI * 2);
            } else if (to - from < -Math.PI) {
                return (from + shift) % (Math.PI * 2);
            } else if (to > from) {
                return (from + shift) % (Math.PI * 2);
            } else {
                return (from - shift) % (Math.PI * 2);
            }
        }

        public function getAngleDistance(from:Number, to:Number):Number {
            if (to - from > Math.PI) {
                from += Math.PI * 2;
            } else if (from - to > Math.PI) {
                to += Math.PI * 2;
            }
            return to - from;
        }

    }

}