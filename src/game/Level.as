package game {
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class Level {
        public var width:int;
        public var height:int;
        public var layers:Vector.<LevelLayer>;
        public var rootNode:Node;

        public function Level(_width:int, _height:int, _layers:int, _rootNode:Node) {
            width = _width;
            height = _height;
            rootNode = _rootNode;
            layers = new Vector.<LevelLayer>(_layers, true);
            for (var i:int = 0; i < _layers; ++i) {
                layers[i]= new LevelLayer(width, height, rootNode);
            }
        }

        public function isPositionOnMap(x:int, y:int):Boolean {
            return x >= 0 && x < width && y >= 0 && y < height;
        }

    }

}