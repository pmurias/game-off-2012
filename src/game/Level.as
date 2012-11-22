package game {
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import game.pickable.Pickable;
    import game.pickable.PickableCloningMode;
    import game.pickable.PickableEye;
    import game.pickable.PickableFairMode;
    import game.pickable.PickablePoint;
    import game.spawners.Spawner;
    import gremlin.scene.Camera;
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

        public static var pickableTypeByName:Dictionary;

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

            if (pickableTypeByName == null) {
                pickableTypeByName = new Dictionary();
                pickableTypeByName["point"] = PickablePoint;
                pickableTypeByName["eye"] = PickableEye;
                pickableTypeByName["f"] = PickableFairMode;
                pickableTypeByName["c"] = PickableCloningMode;
            }
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

            for (i = 0; i < object.level.pickables.length; ++i) {
                var pickableSetup:Object = object.level.pickables[i];
                var pickable:Pickable = new pickableTypeByName[pickableSetup.type](gameCtx);
                pickable.node.setPosition(pickableSetup.position[0], pickableSetup.position[1], pickableSetup.position[2]);
            }

            for (i = 0; i < object.level.crates.length; ++i) {
                var crateSetup:Object = object.level.crates[i];
                var crate:Crate = new Crate(gameCtx);
                crate.node.setPosition(crateSetup.position[0], crateSetup.position[1], crateSetup.position[2]);
            }

            startPosition.setTo(object.level['start'][0], object.level['start'][1], object.level['start'][2])
        }

        public function isPositionOnMap(x:int, y:int):Boolean {
            return x >= 0 && x < width && y >= 0 && y < height;
        }

        public function getTileAtPosition(position:Vector3D, l:int):Tile {
            return layers[l].tiles[int(position.x / 2)][int(position.z / 2)];
        }

        public function updateTileBounds():void {
            for (var i:int = 0; i < layers.length; ++i) {
                layers[i].updateTileBounds();
            }
        }

        public function checkNearTileCollision(gameObject:GameObject):Tile {
            var sourceTile:Tile = getTileAtPosition(gameObject.node.position, 0);
            var bounds:Rectangle = gameObject.collisionComponent.bounds;
            for (var i:int =  sourceTile.mapx - 1; i <= sourceTile.mapx + 1; ++i) {
                for (var j:int  = sourceTile.mapy -1; j <= sourceTile.mapy +1; ++j) {
                    if (isPositionOnMap(i, j)) {
                        var tile:Tile = layers[0].tiles[i][j];
                        if (tile.getCollisionComponent() != null) {
                            if (tile.getCollisionComponent().bounds.intersects(bounds)) {
                                return tile;
                            }
                        }
                    }
                }
            }
            return null;
        }

        public function drawTileBounds(camera:Camera):void {
            gameCtx.graphics.lineStyle(1, 0xFF0000);
            for (var i:int = 0; i < width; ++i) {
                for (var j:int  = 0 ; j < height; ++j) {
                    var tile:Tile = layers[0].tiles[i][j];
                    if (tile.collisionComponent != null) {
                        tile.collisionComponent.debugDraw(gameCtx.graphics, camera);
                    }
                }
            }
        }

    }

}