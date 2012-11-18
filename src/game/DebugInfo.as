package game {
    import flash.display.Sprite;
    import flash.text.TextField;
    import gremlin.core.Context;
	/**
     * ...
     * @author mosowski
     */
    public class DebugInfo extends Sprite {
        public var ctx:Context;
        public var fpsTimor:Number;
        public var fpsCounter:int;
        public var fpsText:TextField;


        public function DebugInfo(_ctx:Context) {
            ctx = _ctx;
            fpsText = new TextField();
            fpsText.x = 0;
            fpsText.y = 0;
            fpsText.textColor = 0xFFFF00;
            addChild(fpsText);
            fpsTimor = ctx.time;
            fpsCounter = 0;
        }

        public function tick():void {
            if (ctx.time > fpsTimor + 1.0) {
                fpsText.text = fpsCounter.toString();
                fpsCounter = 0;
                fpsTimor = ctx.time;
            }
            fpsCounter++;
        }

    }

}