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
        public var scene:Scene;

        public function SubmeshEntity() {
        }


        public function setSubmesh(_submesh:Submesh):void {
            if (scene != null) {
                scene.removeRenderable(this);
            }
            submesh = _submesh;
            if (submesh != null) {
                material = submesh.material;
                if (scene != null) {
                    scene.addRenderable(this);
                }
            } else {
                material = null;
            }
        }


        public function setMaterial(_material:Material):void {
            material = _material;
            if (scene != null) {
                scene.notifyRenderableMaterialChange(this);
            }
        }

        public function setScene(_scene:Scene):void {
            if (scene != _scene) {
                if (scene != null) {
                    scene.removeRenderable(this);
                }
                scene = _scene;
                if (scene != null) {
                    scene.addRenderable(this);
                }
            }
        }

        public function getMaterial():Material {
            return material;
        }

        public function render(ctx:Context):void {
            modelEntity.setLocalAutoParams(ctx);
            ctx.activeShader.uploadLocalAutoParams();

            ctx.activeShader.vertexProgram.setVertexBuffer(modelEntity.modelResource.vertexBuffer);
            ctx.drawTriangles(modelEntity.modelResource.indexBuffer, submesh.indexOffset, submesh.numTriangles);
        }
    }

}