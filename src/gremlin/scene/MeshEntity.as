package gremlin.scene {
    import gremlin.meshes.Mesh;

    /**
     * ...
     * @author mosowski
     */
    public class MeshEntity {
        public var node:Node;
        public var mesh:Mesh;
        public var submeshEntities:Vector.<SubmeshEntity>;

        public function MeshEntity(_mesh:Mesh = null, _node:Node = null) {
            submeshEntities = new Vector.<SubmeshEntity>();
            if (_mesh != null) {
                setMesh(_mesh);
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

        public function setMesh(_mesh:Mesh):void {
            var i:int;
            for (i = 0; i < submeshEntities.length; ++i) {
                submeshEntities[i].setSubmesh(null);
            }
            mesh = _mesh;
            submeshEntities.length = 0;

            for (i = 0; i < mesh.submeshes.length; ++i) {
                var submeshEntity:SubmeshEntity = new SubmeshEntity();
                submeshEntity.meshEntity = this;
                submeshEntity.setSubmesh(mesh.submeshes[i]);
                submeshEntities.push(submeshEntity);
            }

        }

    }

}