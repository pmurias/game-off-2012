package gremlin.loading {
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.ObjectEncoding;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import gremlin.events.EventDispatcher;

    /**
     * ...
     * @author mosowski
     */
    public class LoaderManager extends EventDispatcher{
        private var loaders:Dictionary;
        private var urlLoaders:Dictionary;
        private var batches:Dictionary;
        private var onCompleteCallbacks:Dictionary;

        public static const LOADER_ERROR:String = "loader_error";

        public function LoaderManager() {
            loaders = new Dictionary();
            urlLoaders = new Dictionary();
            onCompleteCallbacks = new Dictionary();
        }

        public function loadImage(url:String, onComplete:Function):void {
            var ldr:Loader = loaders[url];
            var cbks:Vector.<Function> = onCompleteCallbacks[url];
            if (ldr == null) {
                ldr = loaders[url] = new Loader();
                ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                        onLoaderComplete(e, url);
                    });
                ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void {
                        onLoaderError(e, url);
                    });
                cbks = onCompleteCallbacks[url] = new Vector.<Function>();
                cbks.push(onComplete);

                ldr.load(new URLRequest(url));
            } else if (ldr.contentLoaderInfo.bytesLoaded < ldr.contentLoaderInfo.bytesTotal) {
                cbks.push(onComplete);
            } else {
                onComplete(url);
            }
        }

        public function loadData(url:String, onComplete:Function):void {
            var ldr:URLLoader = urlLoaders[url];
            var cbks:Vector.<Function> = onCompleteCallbacks[url];
            if (ldr == null) {
                ldr = urlLoaders[url] = new URLLoader();
                ldr.addEventListener(Event.COMPLETE, function(e:Event):void {
                        onLoaderComplete(e, url);
                    });
                ldr.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void {
                        onLoaderError(e, url);
                    });
                cbks = onCompleteCallbacks[url] = new Vector.<Function>();
                cbks.push(onComplete);

                ldr.load(new URLRequest(url));
            } else if (ldr.bytesLoaded < ldr.bytesTotal) {
                cbks.push(onComplete);
            } else {
                onComplete(url);
            }
        }

        public function getLoaderData(url:String):ByteArray {
            var ldr:URLLoader = urlLoaders[url];
            return ldr.data as ByteArray;
        }

        public function getLoaderString(url:String):String {
            var ldr:URLLoader = urlLoaders[url];
            return ldr.data as String;
        }

        public function getLoaderJSON(url:String):Object {
            var ldr:URLLoader = urlLoaders[url];
            return JSON.parse(ldr.data as String);
        }

        public function getLoaderAMF3(url:String):Object {
            var ldr:URLLoader = urlLoaders[url];
            var ba:ByteArray = ldr.data as ByteArray;
            ba.objectEncoding = ObjectEncoding.AMF3;
            return ba.readObject();
        }

        public function getLoaderBitmap(url:String):Bitmap {
            var ldr:Loader = loaders[url];
            return ldr.content as Bitmap;
        }

        private function onLoaderComplete(e:Event, url:String):void {
            trace("Loader complete: ", url);
            var cbks:Vector.<Function> = onCompleteCallbacks[url];
            for (var i:int = 0; i < cbks.length; i += 1) {
                cbks[i](url);
            }
            cbks.length = 0;
        }

        private function onLoaderError(e:Event, url:String):void {
            trace("Loader error: ", url);
            dispatch(LOADER_ERROR, url);
        }
    }
}