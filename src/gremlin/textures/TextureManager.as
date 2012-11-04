package gremlin.textures {
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
        public function TextureManager(_ctx:Context) {
            super(this, _ctx, TextureResource);
        }

        override protected function onResourceLoaded(url:String):void {
            resources[url].setBitmapSource(ctx.loaderMgr.getLoaderBitmap(url).bitmapData);
            super.onResourceLoaded(url);
        }

        override protected function callLoader(url:String, onLoaderComplete:Function):void {
            ctx.loaderMgr.loadImage(url, onLoaderComplete);
        }

        public function getTextureResource(url:String):TextureResource {
            return resources[url] as TextureResource;
        }

        public function loadTextureResource(url:String, onReadyCb:Function = null):TextureResource {
            return loadResource(url, onReadyCb) as TextureResource;
        }
    }

}