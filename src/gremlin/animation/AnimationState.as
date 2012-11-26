package gremlin.animation {
    import gremlin.events.EventDispatcher;

    /**
     * ...
     * @author mosowski
     */
    public class AnimationState extends EventDispatcher {
        public var fps:Number;

        private var animation:Animation;
        private var time:Number;
        private var currentFrame:int;
        public var isPlayingOnce:Boolean;
        public var isActive:Boolean;

        public static const ANIMATION_COMPELTED:String = "animation_completed";

        public function AnimationState(_animation:Animation) {
            animation = _animation;
            time = 0;
            currentFrame = 0;
            fps = 30;
            isPlayingOnce = false;
        }

        public function playOnce():void {
            isPlayingOnce = true;
            isActive = true;
            time = 0;
            currentFrame = 0;
        }

        public function gotoAndPlay(_time:Number = 0):void {
            isPlayingOnce = false;
            isActive = true;
            time = (_time * fps) % animation.length;
            for (var i:int = animation.frames.length - 1; i >=0; --i) {
                if (time >= animation.frames[i]) {
                    currentFrame = i;
                    break;
                }
            }
        }

        public function gotoAndStop(_time:Number = 0):void {
            isPlayingOnce = false;
            isActive = false;
            time = (_time * fps) % animation.length;
            for (var i:int = animation.frames.length - 1; i >=0; --i) {
                if (time >= animation.frames[i]) {
                    currentFrame = i;
                    break;
                }
            }
        }

        public function play():void {
            isActive = true;
        }

        public function stop():void {
            isActive = false;
        }

        public function advance(deltaTime:Number):void {
            if (isActive == true) {
                time = time + deltaTime * fps;
                if (isPlayingOnce == true && time >= animation.length) {
                    time = animation.length-0.001;
                    isActive = false;
                    dispatch(ANIMATION_COMPELTED);
                }
                if (time >= animation.frames[currentFrame + 1]) {
                    currentFrame = (currentFrame + 1) % (animation.frames.length - 1);
                }
                time %= animation.length;
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