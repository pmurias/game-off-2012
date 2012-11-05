package gremlin.rendertargets {
    import gremlin.core.Context;

    /**
     * ...
     * @author mosowski
     */
    public class RenderTargetBackbuffer implements IRenderTarget {
        public var ctx:Context;
        private var requiresClear:Boolean = true;

        public function RenderTargetBackbuffer(_ctx:Context) {
            ctx = _ctx;
        }

        public function beginFrame():void {
            ctx.setRenderToBackBuffer();
            if (requiresClear == true) {
                ctx.clear(0.3, 0.125, 0.6);
                requiresClear = false;
            }
        }

        public function endFrame():void {
            ctx.present();
            requiresClear = true;
        }

    }

}