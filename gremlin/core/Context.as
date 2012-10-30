package gremlin.core {
    import flash.display.Stage;
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.events.Event;
    import gremlin.debug.MemoryStats;
    import gremlin.events.EventDispatcher;

    /**
     * ...
     * @author mosowski
     */
    public class Context extends EventDispatcher {
        public var stage:Stage;
        public var ctx3d:Context3D;
        public var stats:MemoryStats;

        public static const CONTEXT_READY:String = "context_ready";
        public static const CONTEXT_LOST:String = "context_lost";

        public function Context(_stage:Stage) {
            stage = _stage;
            stats = new MemoryStats();
        }

        public function requestContext():void {
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextReady);
            stage.stage3Ds[0].requestContext3D();
        }

        private function onContextReady(e:Event = null):void {
            ctx3d = stage.stage3Ds[0].context3D;

            dispatch(CONTEXT_READY);
        }

        public function createTexture(w:Number, h:Number, fmt:String, rt:Boolean = false):Texture {
            stats.textureMemory += w * h * 4;
            return ctx3d.createTexture(w, h, fmt, rt);
        }

    }

}