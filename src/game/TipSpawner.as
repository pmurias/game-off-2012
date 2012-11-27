package game {
    import flash.geom.Vector3D;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class TipSpawner {
        public var gameCtx:GameContext;
        public var node:Node;
        public var spawnPosition:Vector3D;
        public var text:String;
        public var duration:Number;
        public var tipArea:TipArea;
        public var mode:String;
        public var gameObject:GameObject;
        public var range:Number;

        public static const PLACE:String = "place";
        public static const HERO:String = "hero";
        public static const GAMEOBJECT:String = "gameobject";

        public function TipSpawner(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            spawnPosition = new Vector3D();
        }

        public function show():void {
            if (tipArea == null) {
                tipArea = new TipArea(gameCtx);
                tipArea.node = node;
                var h:int = Math.ceil(text.length / 22) * 20 + 20;
                tipArea.setSize(250, h);
                tipArea.setText(text);
            }
            tipArea.show();
        }

        public function hide():void {
            if (tipArea != null) {
                tipArea.hide();
            }
        }

        public function destroy():void {
            hide();
        }

    }

}