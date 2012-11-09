package gremlin.gremlin2d {
    import flash.geom.Matrix;
    import gremlin.core.Context;
    import gremlin.core.IRenderable;
    import gremlin.materials.Material;

    /**
     * ...
     * @author mosowski
     */
    public class Quad2d implements IRenderable {
        public var transformation:Matrix;
        public var material:Material;

        public function Quad2d() {
            transformation = new Matrix();
        }

        public function setMaterial(_material:Material):void {
            if (material) {
                material.removeRenderable(this);
            }
            material = _material;
            if (material) {
                material.addRenderable(this);
            }
        }

        public function render(ctx:Context):void {

        }

    }

}