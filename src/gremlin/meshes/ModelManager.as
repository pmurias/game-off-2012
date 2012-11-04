package gremlin.meshes {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.ResourceManager;

    /**
     * ...
     * @author mosowski
     */
    public class ModelManager extends ResourceManager {
        public var modelResourceByName:Dictionary;

        public function ModelManager(_ctx:Context) {
            super(this, _ctx, ModelResource);

            modelResourceByName = new Dictionary();
        }

        override protected function onResourceLoaded(url:String):void {
            var modelResource:ModelResource = resources[url];
            modelResource.fromJSON(ctx.loaderMgr.getLoaderJSON(url));
            modelResourceByName[modelResource.name] = modelResource;
            super.onResourceLoaded(url);
        }

        override protected function callLoader(url:String, onLoaderComplete:Function):void {
            ctx.loaderMgr.loadData(url, onLoaderComplete);
        }

        public function getModelResource(url:String):ModelResource {
            var modelResource:ModelResource = resources[url];
            if (modelResource == null) {
                modelResource = modelResourceByName[url];
            }
            return modelResource;
        }

        public function loadModelResource(url:String, onReadyCb:Function = null):ModelResource {
            return loadResource(url, onReadyCb) as ModelResource;
        }

    }

}