package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;
    import gremlin.core.Context;
    import gremlin.loading.LoaderBatch;
    import gremlin.loading.LoaderManager;
    import gremlin.textures.TextureManager;
    import gremlin.textures.TextureResource;

    /**
     * ...
     * @author mosowski
     */
    public class Main extends Sprite {
        public var ctx:Context;
        public var loaderMgr:LoaderManager;
        public var textureMgr:TextureManager;

        public function Main():void {
            if (stage)
                init();
            else
                addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            ctx = new Context(stage);
            ctx.addListener(Context.CONTEXT_READY, onCtxReady);
            ctx.requestContext();

            loaderMgr = new LoaderManager();

            textureMgr = new TextureManager(ctx, loaderMgr);

            var lb:LoaderBatch = new LoaderBatch(loaderMgr);
            lb.addListener(LoaderBatch.COMPLETE, onAssetsLoaded);
            lb.addImageUrl("static/chess.png");
            lb.addDataUrl("static/cube.txt");
            lb.load();
        }

        private function onAssetsLoaded(params:Object):void {
            var tr:TextureResource = textureMgr.getTextureResource("static/chess.png", onImageLoaded);
        }

        private function onImageLoaded(u:String):void {
            stage.addChild(new Bitmap(
                textureMgr.getTextureResource("static/chess.png").bitmapSource)
                );
            var txt:TextField = new TextField();
            txt.x = 100;
            txt.y = 200;
            txt.text = loaderMgr.getLoaderString("static/cube.txt");
            stage.addChild(txt);
        }

        private function onCtxReady(params:Object):void {

        }

    }

}