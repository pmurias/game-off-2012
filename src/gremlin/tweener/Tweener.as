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
            var tween:Tween = getTween();
            tween.object = null;
            tween.duration = delay;
            tween.startTime = ctx.time;
            tween.completeTime = ctx.time + tween.duration;
            tween.onComplete = call;
            numActiveTweens++;
        }

        public function tween(object:Object, property:String, from:Number, to:Number, duration:Number, onComplete:Function):void {
            var tween:Tween = getTween();
            tween.object = object;
            tween.propertyName = property;
            tween.sourceValue = from;
            tween.destinationValue = to;
            tween.duration = duration;
            tween.startTime = ctx.time;
            tween.completeTime = ctx.time + tween.duration;
            tween.onComplete = onComplete;
            numActiveTweens++;
        }

        private function getTween():Tween {
            var tween:Tween;
            if (numActiveTweens >= tweens.length) {
                tween = new Tween();
                tween.id = tweens.length;
                tweens.push(tween);
            } else {
                tween = tweens[numActiveTweens];
            }
            return tween;
        }

        public function tick():void {
            for (var i:int = numActiveTweens - 1; i >= 0; --i) {
                var tween:Tween = tweens[i];
                if (ctx.time >= tween.completeTime) {
                    if (tween.onComplete != null) {
                        tween.onComplete();
                    }
                    if (tween.object != null) {
                        tween.object[tween.propertyName] = tween.destinationValue;
                    }

                    tweens[numActiveTweens - 1].id = tween.id;
                    tweens[tween.id] = tweens[numActiveTweens - 1];
                    tween.id = numActiveTweens - 1;
                    tweens[numActiveTweens - 1] = tween;
                    tween.object = null;
                    tween.onComplete = null;

                    numActiveTweens--;
                } else {
                    if (tween.object != null) {
                        var f:Number = (ctx.time - tween.startTime) / tween.duration;
                        tween.object[tween.propertyName] = tween.sourceValue + (tween.destinationValue - tween.sourceValue) * f;
                    }
                }
            }
        }

    }

}

