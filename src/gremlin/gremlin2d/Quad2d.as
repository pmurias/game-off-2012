package gremlin.gremlin2d {
    import flash.geom.Matrix;
    import flash.utils.Endian;
    import gremlin.core.Context;
    import gremlin.core.IRenderable;
    import gremlin.materials.Material;
    import gremlin.meshes.IndexBuffer;
    import gremlin.meshes.VertexBuffer;
    import gremlin.scene.Scene;

    /**
     * ...
     * @author mosowski
     */
    public class Quad2d implements IRenderable {
        public var transformation:Matrix;
        public var material:Material;
        public var scene:Scene;
        public var visible:Boolean;

        public function Quad2d() {
            transformation = new Matrix();
            visible = true;
        }

        public function setMaterial(material:Material):void {
            if (scene != null) {
                scene.notifyRenderableMaterialChange(this, this.material, material);
            }
            this.material = material;
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

        public function isVisible():Boolean {
            return visible;
        }

        public function render(ctx:Context):void {
            ctx.autoParams.imageMatrix.value = transformation;
            ctx.autoParams.uvRect.x = 0;
            ctx.autoParams.uvRect.y = 0;
            ctx.autoParams.uvRect.z = 1;
            ctx.autoParams.uvRect.w = 1;
            ctx.activeShader.uploadLocalAutoParams();
            ctx.activeShader.vertexProgram.setVertexBuffer(ctx.ctx2d.unitQuadVertexBuffer);
            ctx.drawTriangles(ctx.ctx2d.unitQuadIndexBuffer);
        }

    }

}