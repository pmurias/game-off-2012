package gremlin.materials {
    import gremlin.core.IRenderable;
    import gremlin.shaders.Shader;

    /**
     * ...
     * @author mosowski
     */
    public class Material {
        public var passes:Vector.<Pass>;
        public var renderables:Vector.<IRenderable>;

        public function Material() {
            passes = new Vector.<Pass>();
            renderables = new Vector.<IRenderable>();
        }

        public function addPass(pass:Pass):void {
            pass.material = this;
            passes.push(pass);
        }

        public function addRenderable(renderable:IRenderable):void {
            renderables.push(renderable);
        }

        public function removeRenderable(renderable:IRenderable):void {
            renderables.splice(renderables.indexOf(renderable), 1);
        }

    }

}