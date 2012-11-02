package gremlin.animation {

    /**
     * ...
     * @author mosowski
     */
    public class Animation {
        public var name:String;
		public var length:Number;
		public var frames:Vector.<Number>;
		public var tracks:Vector.<AnimationTrack>;

        public function Animation() {
            frames = new Vector.<Number>();
            tracks = new Vector.<AnimationTrack>();
        }

    }

}