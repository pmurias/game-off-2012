package gremlin.rendertargets {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.textures.TextureResource;

    /**
     * ...
     * @author mosowski
     */
    public class RenderTargetManager {
        public var ctx:Context;
        public var renderTargets:Dictionary;
        public var defaultRenderTarget:RenderTargetBackbuffer;

        public function RenderTargetManager(_ctx:Context) {
            ctx = _ctx;
            renderTargets = new Dictionary();
            defaultRenderTarget = new RenderTargetBackbuffer(ctx);
        }

        public function createRenderTarget(name:String, width:int, height:int):RenderTargetTexture {
            var renderTarget:RenderTargetTexture = new RenderTargetTexture(ctx);
            renderTarget.setSize(width, height);
            renderTargets[name] = renderTarget;
            return renderTarget;
        }

        public function createRenderTargetFromTexture(name:String, textureResource:TextureResource):RenderTargetTexture {
            var renderTarget:RenderTargetTexture = new RenderTargetTexture(ctx, textureResource);
            renderTargets[name] = renderTarget;
            return renderTarget;
        }

        public function getRenderTarget(name:String):IRenderTarget {
            return renderTargets[name];
        }

    }

}