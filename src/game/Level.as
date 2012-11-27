package game {
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import game.pickable.Pickable;
    import game.pickable.PickableCloningMode;
    import game.pickable.PickableEye;
    import game.pickable.PickableMerge;
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
        public var sourceObject:Object;

        public static var pickableTypeByName:Dictionary;
        public static var enemiesTypeByName:Dictionary;

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

            if (pickableTypeByName == null) {
                pickableTypeByName = new Dictionary();
                pickableTypeByName["point"] = PickablePoint;
                pickableTypeByName["eye"] = PickableEye;
                pickableTypeByName["m"] = PickableMerge;
                pickableTypeByName["c"] = PickableCloningMode;
            }

            if (enemiesTypeByName == null) {
                enemiesTypeByName = new Dictionary();
                enemiesTypeByName["reaper"] = HeroReaper;
            }
        }

        public function fromObject(object:Object, tileSet:TileSet):void {
            sourceObject = object;
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
                gameCtx.spawners.push(spawner);
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

            for (i = 0; i < object.level.enemies.length; ++i) {
                var enemySetup:Object = object.level.enemies[i];
                var enemy:Hero = new enemiesTypeByName[enemySetup.type](gameCtx);
                enemy.node.setPosition(enemySetup.position[0], enemySetup.position[1], enemySetup.position[2]);
            }

            for (i = 0; i < object.level.tips.length; ++i) {
                var tipSetup:Object = object.level.tips[i];
                var tipSpawner:TipSpawner = new TipSpawner(gameCtx);
                tipSpawner.duration = tipSetup.duration;
                tipSpawner.node = new Node();
                tipSpawner.spawnPosition.setTo(tipSetup.position[0], tipSetup.position[1], tipSetup.position[2]);
                tipSpawner.node.copyPositionFrom(tipSpawner.spawnPosition);
                gameCtx.ctx.rootNode.addChild(tipSpawner.node);
                tipSpawner.text = tipSetup.text;
                tipSpawner.mode = tipSetup.mode;
                tipSpawner.range = tipSetup.range;
                if (tipSpawner.mode == TipSpawner.GAMEOBJECT) {
                    for (j = 0; j < gameCtx.gameObjects.length; ++j) {
                        if (Vector3D.distance(gameCtx.gameObjects[j].node.position, tipSpawner.node.position) < 0.1) {
                            tipSpawner.gameObject = gameCtx.gameObjects[j];
                            break;
                        }
                    }
                }
                gameCtx.tipManager.tips.push(tipSpawner);
            }


            startPosition.setTo(object.level['start'][0], object.level['start'][1], object.level['start'][2])
        }

        public function destroyTiles():void {
            var i:int, j:int, l:int;
            for (l = 0; l < layers.length; ++l) {
                for (i = 0; i < width; ++i) {
                    for (j = 0; j < height; ++j) {
                        var tile:Tile = layers[l].tiles[i][j];
                        if (tile != null) {
                            tile.destroy();
                        }
                    }
                }
                rootNode.removeChild(layers[l].layerNode);
            }
        }

        public function isPositionOnMap(x:int, y:int):Boolean {
            return x >= 0 && x < width && y >= 0 && y < height;
        }

        public function getTileAtPosition(position:Vector3D, l:int):Tile {
            var x:int = int(position.x / 2);
            var y:int = int(position.z / 2);
            if (x < layers[l].tiles.length && x >=0) {
                if (y < layers[l].tiles[x].length && y >= 0) {
                    return layers[l].tiles[x][y];
                }
            }
            return null;
        }

        public function updateTileBounds():void {
            for (var i:int = 0; i < layers.length; ++i) {
                layers[i].updateTileBounds();
            }
        }

        public function checkNearTileCollision(gameObject:GameObject):Tile {
            var sourceTile:Tile = getTileAtPosition(gameObject.node.position, 0);
            var collision:CollisionComponent = gameObject.collisionComponent;
            for (var i:int =  sourceTile.mapx - 1; i <= sourceTile.mapx + 1; ++i) {
                for (var j:int  = sourceTile.mapy -1; j <= sourceTile.mapy +1; ++j) {
                    if (isPositionOnMap(i, j)) {
                        var tile:Tile = layers[0].tiles[i][j];
                        if (tile.getCollisionComponent() != null) {
                            if (tile.getCollisionComponent().intersects(collision)) {
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