package game {
    import gremlin.scene.Node;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class LevelLayer {
        public var width:int;
        public var height:int;
        public var tiles:Vector.<Vector.<Tile>>;
        public var rootNode:Node;
        public var layerNode:Node;

        public function LevelLayer(_width:int, _height:int, _rootNode:Node) {
            width = _width;
            height = _height;
            rootNode = _rootNode;
            layerNode = new Node();
            rootNode.addChild(layerNode);
            tiles = new Vector.<Vector.<Tile>>(width, true);
            for (var i:int = 0; i < width; ++i) {
                tiles[i] = new Vector.<Tile>(height,true);
                for (var j:int = 0; j < height; ++j) {
                    tiles[i][j] = new Tile(i, j, layerNode);
                }
            }
        }

        public function setScene(scene:Scene):void {
            for (var i:int = 0; i < width; ++i) {
                for (var j:int = 0; j < height; ++j) {
                    tiles[i][j].setScene(scene);
                }
            }
        }

        public function updateTileBounds():void {
            for (var i:int = 0; i < width; ++i) {
                for (var j:int = 0; j < height; ++j) {
                    if (tiles[i][j].node.transformationUpdated == true) {
                        tiles[i][j].updateBounds();
                    }
                }
            }
        }


    }

}