package gremlin.animation {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.ResourceManager;

    /**
     * ...
     * @author mosowski
     */
    public class SkeletonManager extends ResourceManager {
        public var skeletonResourcesByName:Dictionary;

        public function SkeletonManager(_ctx:Context) {
            super(this, _ctx, SkeletonResource);
            skeletonResourcesByName = new Dictionary();
        }

        override protected function onResourceLoaded(url:String):void {
            var skeletonResource:SkeletonResource = resources[url];
            skeletonResource.fromJSON(ctx.loaderMgr.getLoaderJSON(url));
            skeletonResourcesByName[skeletonResource.name] = skeletonResource;
            super.onResourceLoaded(url);
        }

        override protected function callLoader(url:String, onLoaderComplete:Function):void {
            ctx.loaderMgr.loadData(url, onLoaderComplete);
        }

        public function getSkeletonResource(url:String):SkeletonResource {
            return resources[url] as SkeletonResource;
        }

        public function loadSkeletonResource(url:String, onReadyCb:Function = null):SkeletonResource {
            return loadResource(url, onReadyCb) as SkeletonResource;
        }
    }

}