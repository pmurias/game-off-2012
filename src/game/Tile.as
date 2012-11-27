package game {
    import flash.geom.Point;
    import flash.geom.Rectangle;
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
    public class Tile implements ICollisionComponent {
        public var mapx:int;
        public var mapy:int;
        public var layer:int;
        public var node:Node;
        public var entity:ModelEntity;
        public var type:TileInfo;

        public var collisionComponent:CollisionComponent;

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
            if (modelResource.collisionData.collision2d != null) {
                collisionComponent = new CollisionComponent(node);
                collisionComponent.useFullTransformation = true;
                collisionComponent.setBounds(modelResource.collisionData.collision2d);
            }
            type = tileInfo;
        }

        public function destroy():void {
            if (entity != null) {
                entity.removeFromAllScenes();
                node.removeFromParent();
            }
        }

        public function setScene(scene:Scene):void {
            if (entity != null) {
                entity.addToScene(scene);
            }
        }

        public function updateBounds():void {
            if (collisionComponent != null) {
                collisionComponent.updateBounds();
            }
        }

        public function setRotation(rot:int):void {
            node.getRotation().setFromAxisAngle(Vector3D.Y_AXIS, rot * Math.PI / 2);
        }

        public function getCollisionComponent():CollisionComponent {
            return collisionComponent;
        }

    }

}