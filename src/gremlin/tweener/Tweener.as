package gremlin.tweener {
    import gremlin.core.Context;
	/**
     * ...
     * @author mosowski
     */
    public class Tweener {
        private var ctx:Context;
        private var tweens:Vector.<Tween>;
        private var numActiveTweens:int;

        public function Tweener(ctx:Context) {
            this.ctx = ctx;
            tweens = new Vector.<Tween>();
            numActiveTweens = 0;
        }

        public function delayedCall(call:Function, delay:Number):void {
            var tween:Tween;
            if (numActiveTweens >= tweens.length) {
                tween = new Tween();
                tween.id = tweens.length;
                tweens.push(tween);
            } else {
                tween = tweens[numActiveTweens];
            }
            tween.object = null;
            tween.duration = delay;
            tween.startTime = ctx.time;
            tween.completeTime = ctx.time + tween.duration;
            tween.onComplete = call;
            numActiveTweens++;
        }

        public function tick():void {
            for (var i:int = numActiveTweens - 1; i >= 0; --i) {
                var tween:Tween = tweens[i];
                if (ctx.time >= tween.completeTime) {
                    if (tween.onComplete != null) {
                        tween.onComplete();
                    }

                    tweens[numActiveTweens - 1].id = tween.id;
                    tweens[tween.id] = tweens[numActiveTweens - 1];
                    tween.id = numActiveTweens - 1;
                    tweens[numActiveTweens - 1] = tween;
                    tween.object = null;
                    tween.onComplete = null;

                    numActiveTweens--;
                } else {
                    // TWEEN
                }
            }
        }

    }

}

