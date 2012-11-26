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
        public var driverText:TextField;


        public function DebugInfo(_ctx:Context) {
            ctx = _ctx;
            fpsText = new TextField();
            fpsText.x = 0;
            fpsText.y = 0;
            fpsText.textColor = 0xFFFF00;
            fpsText.selectable = false;
            addChild(fpsText);
            fpsTimor = ctx.time;
            fpsCounter = 0;

            driverText = new TextField();
            driverText.x = 0;
            driverText.y = 10;
            driverText.selectable = false;
            driverText.textColor = 0xFFFF00;
            addChild(driverText);
        }

        public function tick():void {
            if (ctx.time > fpsTimor + 1.0) {
                fpsText.text = fpsCounter.toString();
                fpsCounter = 0;
                fpsTimor = ctx.time;
                driverText.text = ctx.ctx3d.driverInfo;
            }
            fpsCounter++;
        }

    }

}