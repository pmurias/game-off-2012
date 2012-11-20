package game {
    import flash.geom.Vector3D;
    import gremlin.math.Quaternion;
    import gremlin.meshes.ModelResource;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
    import gremlin.scene.Scene;
	/**
     * ...
     * @author mosowski
     */
    public class Tile {
        public var mapx:int;
        public var mapy:int;
        public var layer:int;
        public var node:Node;
        public var entity:ModelEntity;
        public var type:TileInfo;

        public function Tile(_mapx:int, _mapy:int, layerNode:Node) {
            mapx = _mapx;
            mapy = _mapy;
            node = new Node();
            node.setPosition(mapx * 2 + 1, 0, mapy * 2 + 1);
            layerNode.addChild(node);
        }

        public function setType(tileInfo:TileInfo):void {
            var modelResource:ModelResource = tileInfo.modelResources[int(Math.random() * tileInfo.modelResources.length)];
            if (entity == null) {
                entity = new ModelEntity(modelResource, node);
            } else {
                entity.setModelResource(modelResource);
            }
            type = tileInfo;
        }

        public function setScene(scene:Scene):void {
            if (entity != null) {
                entity.addToScene(scene);
            }
        }

        public function setRotation(rot:int):void {
            node.getRotation().setFromAxisAngle(Vector3D.Y_AXIS, rot * Math.PI / 2);
        }

    }

}