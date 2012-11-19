package game {
    import flash.geom.Vector3D;
    import game.spawners.Spawner;
    import gremlin.scene.Node;
	/**
     * ...
     * @author mosowski
     */
    public class Level {
        public var gameCtx:GameContext;
        public var width:int;
        public var height:int;
        public var layers:Vector.<LevelLayer>;
        public var rootNode:Node;
        public var startPosition:Vector3D;
        public var spawners:Vector.<Spawner>;

        public function Level(_gameCtx:GameContext, _width:int, _height:int, _layers:int, _rootNode:Node) {
            gameCtx = _gameCtx;
            width = _width;
            height = _height;
            rootNode = _rootNode;
            layers = new Vector.<LevelLayer>(_layers, true);
            for (var i:int = 0; i < _layers; ++i) {
                layers[i]= new LevelLayer(width, height, rootNode);
            }
            startPosition = new Vector3D();
            spawners = new Vector.<Spawner>();
        }

        public function fromObject(object:Object, tileSet:TileSet):void {
            width = object.level.width;
            height = object.level.height;
            layers = new Vector.<LevelLayer>(object.level.layers, true);
            var i:int, j:int, l:int;
            for (i = 0; i < object.level.layers; ++i) {
                layers[i]= new LevelLayer(width, height, rootNode);
            }
            var tileNameByCode:Array = [];
            for (var tileName:String in object.tileSet) {
                tileNameByCode[object.tileSet[tileName].code] = tileName;
            }
            for (l = 0; l < object.level.layers; ++l) {
                var layer:Object = object.level["layer" + l];
                for (i = 0; i < width; ++i) {
                    for (j = 0; j < height; ++j) {
                        if (layer[i][j] != 0) {
                            layers[l].tiles[i][j].setType(tileSet.types[tileNameByCode[layer[i][j][0]]]);
                            layers[l].tiles[i][j].setRotation(layer[i][j][1]);
                        }
                    }
                }
            }

            for (i = 0; i < object.level.spawners.length; ++i) {
                var spawner:Spawner = new Spawner(gameCtx);
                spawner.fromObject(object.level.spawners[i]);
                spawners.push(spawner);
            }

            startPosition.setTo(object.level['start'][0], object.level['start'][1], object.level['start'][2])
        }

        public function isPositionOnMap(x:int, y:int):Boolean {
            return x >= 0 && x < width && y >= 0 && y < height;
        }

        public function getTileAtPosition(position:Vector3D, l:int):Tile {
            return layers[l].tiles[int(position.x / 2)][int(position.z / 2)];
        }

    }

}