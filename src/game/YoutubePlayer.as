package game {
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.system.SecurityDomain;

    /**
     * ...
     * @author mosowski
     */
    public class YoutubePlayer extends Sprite {

        public var player:Object;
        public var loader:Loader = new Loader();
        public var context:LoaderContext = new LoaderContext();
        public var videoId:String;

        public function YoutubePlayer(videoId:String) {
            this.videoId = videoId;
            context.checkPolicyFile = true;
            context.securityDomain = SecurityDomain.currentDomain;
            context.applicationDomain = ApplicationDomain.currentDomain;

            loader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit);
            Security.allowDomain("www.youtube.com")
            loader.load(new URLRequest("http://www.youtube.com/apiplayer?version=3"));
        }

        public function onLoaderInit(event:Event):void {
            addChild(loader);
            loader.visible = false;
            loader.content.addEventListener("onReady", onPlayerReady);
        }

        public function onPlayerReady(event:Event):void {
            player = loader.content;
            player.loadPlaylist([ videoId ] );
            player.setLoop(true);
            player.setSize(1, 1);
        }
    }

}