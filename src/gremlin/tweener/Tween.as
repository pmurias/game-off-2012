package gremlin.tweener {
	/**
     * ...
     * @author mosowski
     */
    public class Tween {
        public var id:int;
        public var object:Object;
        public var propertyName:String;
        public var sourceValue:Number;
        public var destinationValue:Number;
        public var duration:Number;
        public var startTime:Number;
        public var completeTime:Number;

        public var onComplete:Function;
    }

}