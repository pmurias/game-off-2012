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

        public function TextureManager(_ctx:Context) {
            ctx = _ctx;
            ctx.addListener(Context.CONTEXT_LOST, onContextLost);

            textures = new Dictionary();
            onReadyCallbacks = new Dictionary();
        }

        public function loadTextureResource(url:String, onReadyCb:Function = null):TextureResource {
            var tr:TextureResource = textures[url];
            var cbks:Vector.<Function> = onReadyCallbacks[url];
            if (tr == null) {
                tr = textures[url] = new TextureResource(ctx);
                cbks = onReadyCallbacks[url] = new Vector.<Function>();
                if (onReadyCb != null) {
                    cbks.push(onReadyCb);
                }
                ctx.loaderMgr.loadImage(url, onTextureImageLoaded);

            } else if (tr.isLoaded == false) {
                if (onReadyCb != null) {
                    cbks.push(onReadyCb);
                }
            }
            return tr;
        }

        public function getTextureResource(url:String):TextureResource {
            return textures[url];
        }

        public function createTextureResource(url:String):TextureResource {
            var tr:TextureResource = new TextureResource(ctx);
            textures[url] = tr;
            return tr;
        }

        private function onTextureImageLoaded(url:String):void {
            var tr:TextureResource = textures[url];
            var cbks:Vector.<Function> = onReadyCallbacks[url];
            tr.setBitmapSource(ctx.loaderMgr.getLoaderBitmap(url).bitmapData);
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