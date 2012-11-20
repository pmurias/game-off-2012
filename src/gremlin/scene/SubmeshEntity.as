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

        public function SubmeshEntity(submesh:Submesh) {
            this.submesh = submesh;
            material = submesh.material;
        }

        public function setMaterial(material:Material):void {
            for (var i:int = 0; i < modelEntity.scenes.length; ++i) {
               modelEntity.scenes[i].notifyRenderableMaterialChange(this, this.material, material);
            }
            this.material = material;
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