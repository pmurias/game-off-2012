package gremlin.textures {
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.ResourceManager;
    import gremlin.loading.LoaderManager;

    /**
     * ...
     * @author mosowski
     */
    public class TextureManager extends ResourceManager {
        private var dynamicTextures:Dictionary;
        public var fallbackTexture:TextureResource;

        public function TextureManager(_ctx:Context) {
            super(this, _ctx, TextureResource);
            dynamicTextures = new Dictionary();
            fallbackTexture = new TextureResource(ctx);
            ctx.addListener(Context.CONTEXT_READY, onContextReady);
        }

        private function onContextReady(params:Object = null):void {
            fallbackTexture.setBitmapSource(new BitmapData(1, 1, true, 0xFF008888));
        }

        override protected function onResourceLoaded(url:String):void {
            resources[url].setBitmapSource(ctx.loaderMgr.getLoaderBitmap(url).bitmapData);
            super.onResourceLoaded(url);
        }

        override protected function callLoader(url:String, onLoaderComplete:Function):void {
            ctx.loaderMgr.loadImage(url, onLoaderComplete);
        }

        public function getTextureResource(url:String):TextureResource {
            var textureResource:TextureResource = resources[url];
            if (textureResource == null) {
                return dynamicTextures[url];
            } else {
                return textureResource;
            }
        }

        public function loadTextureResource(url:String, onReadyCb:Function = null):TextureResource {
            return loadResource(url, onReadyCb) as TextureResource;
        }

        public function createTextureResource(name:String, width:int, height:int):TextureResource {
            var textureResource:TextureResource = new TextureResource(ctx);
            textureResource.setBitmapSource(new BitmapData(width, height, true, 0));
            dynamicTextures[name] = textureResource;
            return textureResource;
        }

        public function createRenderTargetTextureResource(name:String, width:int, height:int):TextureResource {
            var textureResource:TextureResource = new TextureResource(ctx);
            textureResource.prepareAsRenderTarget(width, height);
            dynamicTextures[name] = textureResource;
            return textureResource;
        }
    }

}