package gremlin.meshes {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.Key;
    import gremlin.core.ResourceManager;

    /**
     * ...
     * @author mosowski
     */
    public class ModelManager extends ResourceManager {
        private var modelResourceByName:Dictionary;

        public function ModelManager(_ctx:Context) {
            super(this, _ctx, ModelResource);

            modelResourceByName = new Dictionary(true);
        }

        override protected function onResourceLoaded(url:String):void {
            var modelResource:ModelResource = resources[url];
            modelResource.fromJSON(ctx.loaderMgr.getLoaderJSON(url));
            modelResourceByName[Key.of(modelResource.name)] = modelResource;
            super.onResourceLoaded(url);
        }

        override protected function callLoader(url:String, onLoaderComplete:Function):void {
            ctx.loaderMgr.loadData(url, onLoaderComplete);
        }

        public function getModelResourceByUrl(url:String):ModelResource {
            return resources[url] as ModelResource;
        }

        public function getModelResourceByName(name:Key):ModelResource {
            return modelResourceByName[name];
        }

        public function loadModelResource(url:String, onReadyCb:Function = null):ModelResource {
            return loadResource(url, onReadyCb) as ModelResource;
        }

    }

}