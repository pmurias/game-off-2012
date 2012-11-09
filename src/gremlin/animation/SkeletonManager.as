package gremlin.animation {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.Key;
    import gremlin.core.ResourceManager;

    /**
     * ...
     * @author mosowski
     */
    public class SkeletonManager extends ResourceManager {
        private var skeletonResourcesByName:Dictionary;

        public function SkeletonManager(_ctx:Context) {
            super(this, _ctx, SkeletonResource);
            skeletonResourcesByName = new Dictionary(true);
        }

        override protected function onResourceLoaded(url:String):void {
            var skeletonResource:SkeletonResource = resources[url];
            skeletonResource.fromJSON(ctx.loaderMgr.getLoaderJSON(url));
            skeletonResourcesByName[Key.of(skeletonResource.name)] = skeletonResource;
            super.onResourceLoaded(url);
        }

        override protected function callLoader(url:String, onLoaderComplete:Function):void {
            ctx.loaderMgr.loadData(url, onLoaderComplete);
        }

        public function getSkeletonResourceByUrl(url:String):SkeletonResource {
            return resources[url] as SkeletonResource;
        }

        public function getSkeletonResourceByName(name:Key):SkeletonResource {
            return skeletonResourcesByName[name];
        }

        public function loadSkeletonResource(url:String, onReadyCb:Function = null):SkeletonResource {
            return loadResource(url, onReadyCb) as SkeletonResource;
        }
    }

}