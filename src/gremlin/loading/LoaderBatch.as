package gremlin.loading {
    import gremlin.events.EventDispatcher;

    /**
     * ...
     * @author mosowski
     */
    public class LoaderBatch extends EventDispatcher {
        public var name:String;
        public var queuedLoadersCount:int;
        public var loaderMgr:LoaderManager;
        public var queuedImageUrls:Vector.<String>;
        public var queuedDataUrls:Vector.<String>;
        public var queuedBatches:Vector.<LoaderBatch>;
        public var status:String;

        public static const BATCHING:String = "batching";
        public static const LOADING:String = "loading";
        public static const COMPLETE:String = "complete";
        public static const CHILD_LOADED:String = "child_loaded";

        public function LoaderBatch(lm:LoaderManager, _name:String="") {
            loaderMgr = lm;
            name = _name;
            queuedImageUrls = new Vector.<String>();
            queuedDataUrls = new Vector.<String>();
            queuedBatches = new Vector.<LoaderBatch>();
            status = BATCHING;
        }

        public function addImageUrl(url:String):void {
            queuedImageUrls.push(url);
        }

        public function addDataUrl(url:String):void {
            queuedDataUrls.push(url);
        }

        public function addBatch(batch:LoaderBatch):void {
            queuedBatches.push(batch);
        }

        public function load(onCompleteCb:Function = null):void {
            var i:int;
            if (onCompleteCb != null) {
                addListener(COMPLETE, onCompleteCb);
            }

            if (status == BATCHING) {
                queuedLoadersCount = queuedImageUrls.length + queuedDataUrls.length + queuedBatches.length;
                status = LOADING;

                for (i = 0; i < queuedImageUrls.length; ++i) {
                    loaderMgr.loadImage(queuedImageUrls[i], onChildLoaderComplete);
                }
                queuedImageUrls.length = 0;
                for (i = 0; i < queuedDataUrls.length; ++i) {
                    loaderMgr.loadData(queuedDataUrls[i], onChildLoaderComplete);
                }
                queuedDataUrls.length = 0;
                for (i = 0; i < queuedBatches.length; ++i) {
                    queuedBatches[i].load(onChildLoaderComplete);
                }
                queuedBatches.length = 0;
            } else if (status == COMPLETE) {
                dispatch(COMPLETE);
            }
        }

        public function onChildLoaderComplete(url:String):void {
            queuedLoadersCount--;
            dispatch(CHILD_LOADED, url);
            if (queuedLoadersCount == 0) {
                status = COMPLETE;
                dispatch(COMPLETE, name);
            }
        }

    }

}