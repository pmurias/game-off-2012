package gremlin.scene {
    import gremlin.core.Context;
    import gremlin.core.IRenderableContainer;
    import gremlin.meshes.ModelResource;

    /**
     * ...
     * @author mosowski
     */
    public class ModelEntity implements IRenderableContainer {
        public var node:Node;
        public var modelResource:ModelResource;
        public var submeshEntities:Vector.<SubmeshEntity>;
        public var scenes:Vector.<Scene>;

        public function ModelEntity(_mesh:ModelResource = null, _node:Node = null) {
            submeshEntities = new Vector.<SubmeshEntity>();
            scenes = new Vector.<Scene>();
            if (_mesh != null) {
                setModelResource(_mesh);
            }
            if (_node != null) {
                attachToNode(_node);
            }
        }

        public function attachToNode(_node:Node):void {
            node = _node;
        }

        public function detachFromNode():void {
            node = null;
        }

        public function setModelResource(_modelResource:ModelResource):void {
            var i:int, j:int;
            for (i = 0; i < submeshEntities.length; ++i) {
                for (j = 0; j < scenes.length; ++j) {
                    scenes[j].removeRenderable(submeshEntities[i]);
                }
            }

            modelResource = _modelResource;
            submeshEntities.length = 0;

            for (i = 0; i < modelResource.submeshes.length; ++i) {
                var submeshEntity:SubmeshEntity = new SubmeshEntity(modelResource.submeshes[i]);
                submeshEntity.modelEntity = this;
                for (j = 0; j < scenes.length; ++j) {
                    scenes[j].addRenderable(submeshEntity);
                }
                submeshEntities.push(submeshEntity);
            }
        }

        public function addToScene(scene:Scene):void {
            for (var i:int = 0; i < submeshEntities.length; ++i) {
                scene.addRenderable(submeshEntities[i]);
            }
            scenes.push(scene);
        }

        public function removeFromScene(scene:Scene):void {
            for (var i:int = 0; i < submeshEntities.length; ++i) {
                scene.removeRenderable(submeshEntities[i]);
            }
            scenes.splice(scenes.indexOf(scene), 1);
        }

        public function setLocalAutoParams(ctx:Context):void {
            ctx.autoParams.modelMatrix.value = node.transformationMatrix;
            ctx.autoParams.normalMatrix.value = node.normalMatrix;
        }

    }

}