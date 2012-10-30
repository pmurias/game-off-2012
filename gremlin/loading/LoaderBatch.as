package gremlin.loading {
    import gremlin.events.EventDispatcher;

    /**
     * ...
     * @author mosowski
     */
    public class LoaderBatch extends EventDispatcher {
        public var queuedLoadersCount:int;
        public var loaderMgr:LoaderManager;
        public var queuedImageUrls:Vector.<String>;
        public var queueDataUrls:Vector.<String>;
        public var status:String;

        public static const BATCHING:String = "batching";
        public static const LOADING:String = "loading";
        public static const COMPLETE:String = "complete";
        public static const CHILD_LOADED:String = "child_loaded";

        public function LoaderBatch(lm:LoaderManager) {
            loaderMgr = lm;
            queuedImageUrls = new Vector.<String>();
            queueDataUrls = new Vector.<String>();
            status = BATCHING;
        }

        public function addImageUrl(url:String):void {
            queuedImageUrls.push(url);
        }

        public function addDataUrl(url:String):void {
            queueDataUrls.push(url);
        }

        public function load(onCompleteCb:Function = null):void {
            var i:int;
            if (onCompleteCb != null) {
                addListener(COMPLETE, onCompleteCb);
            }

            if (status == BATCHING) {
                queuedLoadersCount = queuedImageUrls.length + queueDataUrls.length;
                status = LOADING;

                for (i = 0; i < queuedImageUrls.length; ++i) {
                    loaderMgr.loadImage(queuedImageUrls[i], onChildLoaderComplete);
                }
                queuedImageUrls.length = 0;
                for (i = 0; i < queueDataUrls.length; ++i) {
                    loaderMgr.loadData(queueDataUrls[i], onChildLoaderComplete);
                }
                queueDataUrls.length = 0;
            } else if (status == COMPLETE) {
                dispatch(COMPLETE);
            }
        }

        public function onChildLoaderComplete(url:String):void {
            queuedLoadersCount--;
            dispatch(CHILD_LOADED, url);
            if (queuedLoadersCount == 0) {
                status = COMPLETE;
                dispatch(COMPLETE);
            }
        }

    }

}