package gremlin.core {
    import flash.utils.Dictionary;

    /**
     * ...
     * @author mosowski
     */
    public class ResourceManager {
        public var ctx:Context;
        public var resources:Dictionary;
        public var resourceClass:Class;
        public var onReadyCallbacks:Dictionary;

        public function ResourceManager(_ctx:Context, _resourceClass:Class) {
            ctx = _ctx;
            resourceClass = _resourceClass;
            resources = new Dictionary();
            onReadyCallbacks = new Dictionary();
        }

        protected function loadResource(url:String, onReadyCb:Function = null):IResource {
            var rsrc:IResource = resources[url];
            var cbks:Vector.<Function> = onReadyCallbacks[url];
            if (rsrc == null) {
                rsrc = resources[url] = new resourceClass(ctx);
                cbks = onReadyCallbacks[url] = new Vector.<Function>();
                if (onReadyCb != null) {
                    cbks.push(onReadyCb);
                }
                callLoader(url, onResourceLoaded);

            } else if (rsrc.isResourceLoaded() == false) {
                if (onReadyCb != null) {
                    cbks.push(onReadyCb);
                }
            }
            return rsrc;
        }

        protected function callLoader(url:String, onLoaderComplete:Function):void {
            throw "callLoader not imlemented.";
        }

        protected function onResourceLoaded(url:String):void {
            var cbks:Vector.<Function> = onReadyCallbacks[url];
            for (var i:int = 0; i < cbks.length; ++i) {
                cbks[i](url);
            }
            cbks.length = 0;
        }

    }

}