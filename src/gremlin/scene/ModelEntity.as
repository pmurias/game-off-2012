package gremlin.scene {
    import gremlin.core.Context;
    import gremlin.meshes.ModelResource;

    /**
     * ...
     * @author mosowski
     */
    public class ModelEntity {
        public var node:Node;
        public var modelResource:ModelResource;
        public var submeshEntities:Vector.<SubmeshEntity>;

        public function ModelEntity(_mesh:ModelResource = null, _node:Node = null) {
            submeshEntities = new Vector.<SubmeshEntity>();
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
            var i:int;
            for (i = 0; i < submeshEntities.length; ++i) {
                submeshEntities[i].setSubmesh(null);
            }
            modelResource = _modelResource;
            submeshEntities.length = 0;

            for (i = 0; i < modelResource.submeshes.length; ++i) {
                var submeshEntity:SubmeshEntity = new SubmeshEntity();
                submeshEntity.modelEntity = this;
                submeshEntity.setSubmesh(modelResource.submeshes[i]);
                submeshEntities.push(submeshEntity);
            }
        }

        public function setLocalAutoParams(ctx:Context):void {
            ctx.autoParams.modelMatrix.value = node.getTransformationMatrix();
        }

    }

}