package gremlin.animation {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import gremlin.math.Quaternion;

    /**
     * ...
     * @author mosowski
     */
    public class AnimationTrack {
        public var location:Vector.<Vector3D>;
		public var rotation:Vector.<Quaternion>;
		
		public var matrix:Vector.<Matrix3D>;
		public var rawMatrix:Vector.<Vector.<Number>>;

        public function AnimationTrack() {
            location = new Vector.<Vector3D>();
            rotation = new Vector.<Quaternion>();
            matrix = new Vector.<Matrix3D>();
            rawMatrix = new Vector.<Vector.<Number>>();
        }

    }

}