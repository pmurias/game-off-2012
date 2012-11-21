package gremlin.rendertargets {
    import gremlin.core.Context;
    import gremlin.textures.TextureResource;

    /**
     * ...
     * @author mosowski
     */
    public class RenderTargetTexture implements IRenderTarget {
        public var ctx:Context;
        public var textureResource:TextureResource;
        public var depthAndStencilEnabled:Boolean;

        public function RenderTargetTexture(_ctx:Context, _textureResource:TextureResource = null) {
            ctx = _ctx;
            depthAndStencilEnabled = true;
            if (_textureResource != null) {
                textureResource = _textureResource;
            }
        }

        public function setSize(width:int, height:int):void {
            if (textureResource == null) {
                textureResource = new TextureResource(ctx);
            }
            textureResource.prepareAsRenderTarget(width, height);
        }

        public function activate():void {
            ctx.setRenderToTexture(textureResource, depthAndStencilEnabled);
            ctx.clear(0.0,0,0.0,1);
        }

        public function finish():void {
        }

    }

}