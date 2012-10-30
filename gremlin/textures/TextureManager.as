package gremlin.textures {
    import flash.events.Event;
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.loading.LoaderManager;

    /**
     * ...
     * @author mosowski
     */
    public class TextureManager {
        public var textures:Dictionary;
        public var onReadyCallbacks:Dictionary;
        public var ctx:Context;;
        public var loaderMgr:LoaderManager;

        public function TextureManager(c:Context, lm:LoaderManager) {
            ctx = c;
            ctx.addListener(Context.CONTEXT_LOST, onContextLost);

            loaderMgr = lm;

            textures = new Dictionary();
            onReadyCallbacks = new Dictionary();
        }

        public function getTextureResource(url:String, onReadyCb:Function = null):TextureResource {
            var tr:TextureResource = textures[url];
            var cbks:Vector.<Function> = onReadyCallbacks[url];
            if (tr == null) {
                tr = textures[url] = new TextureResource(ctx);
                cbks = onReadyCallbacks[url] = new Vector.<Function>();
                if (onReadyCb != null) {
                    cbks.push(onReadyCb);
                }
                loaderMgr.loadImage(url, onTextureImageLoaded);

            } else if (tr.isReady == false) {
                if (onReadyCb != null) {
                    cbks.push(onReadyCb);
                }
            }
            return tr;
        }

        private function onTextureImageLoaded(url:String):void {
            var tr:TextureResource = textures[url];
            var cbks:Vector.<Function> = onReadyCallbacks[url];
            tr.setBitmapSource(loaderMgr.getLoaderBitmap(url).bitmapData);
            for (var i:int = 0; i < cbks.length; i += 1) {
                cbks[i](url);
            }
            cbks.length = 0;
        }

        private function onContextLost(params:Object = null):void {
            for (var url:String in textures) {
                var tr:TextureResource = textures[url];
                tr.restore();
            }
        }
    }

}