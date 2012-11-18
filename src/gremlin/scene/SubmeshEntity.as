package gremlin.scene {
    import gremlin.core.Context;
    import gremlin.core.IRenderable;
    import gremlin.materials.Material;
    import gremlin.meshes.Submesh;

    /**
     * ...
     * @author mosowski
     */
    public class SubmeshEntity implements IRenderable {
        public var modelEntity:ModelEntity;
        public var submesh:Submesh;
        public var material:Material;

        public function SubmeshEntity(_submesh:Submesh) {
            submesh = _submesh;
            material = submesh.material;
        }

        public function setMaterial(_material:Material):void {
            material = _material;
            for (var i:int = 0; i < modelEntity.scenes.length; ++i) {
               modelEntity.scenes[i].notifyRenderableMaterialChange(this);
            }
        }

        public function getMaterial():Material {
            return material;
        }

        public function isVisible():Boolean {
            return modelEntity.node.derivedVisible;
        }

        public function render(ctx:Context):void {
            modelEntity.setLocalAutoParams(ctx);
            ctx.activeShader.uploadLocalAutoParams();

            ctx.activeShader.vertexProgram.setVertexBuffer(modelEntity.modelResource.vertexBuffer);
            ctx.drawTriangles(modelEntity.modelResource.indexBuffer, submesh.indexOffset, submesh.numTriangles);
        }
    }

}