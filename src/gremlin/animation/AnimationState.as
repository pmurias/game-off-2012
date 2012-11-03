package gremlin.animation {

    /**
     * ...
     * @author mosowski
     */
    public class AnimationState {
        public var speedScale:Number;

        private var animation:Animation;
        private var time:Number;
        private var currentFrame:int;

        public function AnimationState(_animation:Animation) {
            animation = _animation;
            time = 0;
            currentFrame = 0;
            speedScale = 1;
        }

        public function advance(deltaTime:Number):void {
            time = time + deltaTime * speedScale;
            if (time >= animation.frames[currentFrame + 1]) {
                currentFrame = (currentFrame + 1) % (animation.frames.length - 1);
            }
            time %= animation.length;
        }

        public function setTime(_time:Number):void {
            time = _time % animation.length;
            for (var i:int = animation.frames.length; i >=0; --i) {
                if (time > animation.frames[i]) {
                    currentFrame = i;
                    break;
                }
            }
        }

        public function getAnimation():Animation {
            return animation;
        }

        public function getCurrentFrame():int {
            return currentFrame;
        }

        public function getTime():Number {
            return time;
        }
    }

}