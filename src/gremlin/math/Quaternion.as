package gremlin.math {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.geom.Orientation3D;

    /**
     * ...
     * @author mosowski
     */
    public class Quaternion {
        public var values:Vector3D;

        private static var vecZero:Vector3D = new Vector3D();
        private static var matrixComponents:Vector.<Vector3D> = new <Vector3D>[vecZero, vecZero, vecZero];
        private static var axisAngleQuat:Quaternion = new Quaternion();

        public function Quaternion(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 1) {
            values = new Vector3D(x, y, z, w);
        }

        public function get x():Number {
            return values.x;
        }

        public function set x(value:Number):void {
            values.x = value;
        }

        public function get y():Number {
            return values.y;
        }

        public function set y(value:Number):void {
            values.y = value;
        }

        public function get z():Number {
            return values.z;
        }

        public function set z(value:Number):void {
            values.z = value;
        }

        public function get w():Number {
            return values.w;
        }

        public function set w(value:Number):void {
            values.w = value;
        }

        public function multiplyBy(b:Quaternion):void {
            this.setTo(values.x * b.values.w + values.w * b.values.x + values.y * b.values.z - values.z * b.values.y, values.y * b.values.w + values.w * b.values.y + values.z * b.values.x - values.x * b.values.z, values.z * b.values.w + values.w * b.values.z + values.x * b.values.y - values.y * b.values.x, values.w * b.values.w - values.x * b.values.x - values.y * b.values.y - values.z * b.values.z);
        }

        public function transformVector(vec:Vector3D):void {
            var ix:Number = values.w * vec.x + values.y * vec.z - values.z * vec.y;
            var iy:Number = values.w * vec.y + values.z * vec.x - values.x * vec.z;
            var iz:Number = values.w * vec.z + values.x * vec.y - values.y * vec.x;
            var iw:Number = -values.x * vec.x - values.y * vec.y - values.z * vec.z;

            vec.setTo(ix * values.w + iw * -values.x + iy * -values.z - iz * -values.y, iy * values.w + iw * -values.y + iz * -values.x - ix * -values.z, iz * values.w + iw * -values.z + ix * -values.y - iy * -values.x);
        }

        public function setTo(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 1):void {
            values.x = x;
            values.y = y;
            values.z = z;
            values.w = w;
        }

        public function copyFrom(q:Quaternion):void {
            values.x = q.x;
            values.y = q.y;
            values.z = q.z;
            values.w = q.w;
        }

        public function identity():void {
            values.x = values.y = values.z = 0;
            values.w = 1;
        }

        public function clone():Quaternion {
            return new Quaternion(values.x, values.y, values.z, values.w);
        }

        public function normalize():void {
            var len:Number = Math.sqrt(values.x * values.x + values.y * values.y + values.z * values.z + values.w * values.w);
            values.x /= len;
            values.y /= len;
            values.z /= len;
            values.w /= len;
        }

        public function toMatrix3D(mtx:Matrix3D):void {
            Quaternion.matrixComponents[1] = values;
            mtx.recompose(Quaternion.matrixComponents, Orientation3D.QUATERNION);
        }

        public function setFromAxisAngle(axis:Vector3D, angle:Number):void {
            var sinAngle:Number = Math.sin(angle * 0.5);
            values.x = sinAngle * axis.x;
            values.y = sinAngle * axis.y;
            values.z = sinAngle * axis.z;
            values.w = Math.cos(angle * 0.5);
        }

        public function toAngleAxis(v:Vector3D):void {
            if (1.0 - values.w * values.w != 0) {
                v.setTo(values.x / Math.sqrt(1.0 - values.w * values.w), values.y / Math.sqrt(1.0 - values.w * values.w), values.z / Math.sqrt(1.0 - values.w * values.w));
                v.w = 2.0 * Math.acos(values.w);
            } else {
                v.setTo(1, 0, 0);
                v.w = 0;
            }
        }

        public function multiplyByAngleAxis(axis:Vector3D, angle:Number):void {
            axisAngleQuat.setFromAxisAngle(axis, angle);
            multiplyBy(axisAngleQuat);
        }

        public static function rotationBetween(dest:Quaternion, a:Vector3D, b:Vector3D):void {
            var d:Number = a.dotProduct(b);
            var axis:Vector3D = new Vector3D();
            if (d >= 1.0) {
                dest.setTo(0.0, 0.0, 0.0, 1.0);
            } else if (d < (0.000001 - 1.0)) {
                axis = Vector3D.X_AXIS.crossProduct(a);
                if (axis.length < 0.000001)
                    axis = Vector3D.Y_AXIS.crossProduct(a);
                if (axis.length < 0.000001)
                    axis = Vector3D.Z_AXIS.crossProduct(a);
                axis.normalize();
                dest.setFromAxisAngle(axis, Math.PI);
            } else {
                var s:Number = Math.sqrt((1.0 + d) * 2.0);
                var sInv:Number = 1.0 / s;
                axis = a.crossProduct(b);
                dest.setTo(axis.x * sInv, axis.y * sInv, axis.z * sInv, s * 0.5);
            }
            dest.normalize();
        }
    }

}