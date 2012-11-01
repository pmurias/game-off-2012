package gremlin.materials {
    import flash.utils.Dictionary;
    import gremlin.core.IRenderable;
    import gremlin.shaders.Shader;
    import gremlin.textures.TextureResource;

    /**
     * ...
     * @author mosowski
     */
    public class Pass {
        public var material:Material;
        public var shader:Shader;
        public var samplers:Dictionary;
        public var index:int;

        public function Pass() {
            samplers = new Dictionary();
        }
    }

}