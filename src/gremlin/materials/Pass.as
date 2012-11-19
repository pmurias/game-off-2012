package gremlin.materials {
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
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

        public var sourceBlendFactor:String;
        public var destBlendFactor:String;

        public var depthMask:Boolean;
        public var depthCompareMode:String;

        public var iterationMode:int;

        public var transparent:Boolean;

        public var shader:Shader;
        public var samplers:Dictionary;
        public var index:int;

        public static const ITERATION_ONE:int = 0;
        public static const ITERATION_ONE_PER_DIRECTIONAL_LIGHT:int = 1;

        public function Pass() {
            samplers = new Dictionary();

            sourceBlendFactor = Context3DBlendFactor.ONE;
            destBlendFactor = Context3DBlendFactor.ZERO;

            depthMask = true;
            depthCompareMode = Context3DCompareMode.LESS_EQUAL;

            iterationMode = ITERATION_ONE;

            transparent = false;
        }
    }

}