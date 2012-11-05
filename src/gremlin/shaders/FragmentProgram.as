package gremlin.shaders {
    import flash.display3D.Context3DProgramType;
    import flash.display3D.textures.Texture;
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.textures.TextureResource;

    /**
     * ...
     * @author mosowski
     */
    public class FragmentProgram extends ShaderProgram {
        public var samplers:Dictionary;

        public function FragmentProgram(_ctx:Context) {
            super(_ctx);
            samplers = new Dictionary();
            type = Context3DProgramType.FRAGMENT;
        }

        public function addSampler(name:String, register:int):void {
            samplers[name] = register;
        }

        public function setSampler(name:String, texture:TextureResource):void {
            if (samplers[name] != null) {
                ctx.setTextureAt(samplers[name], texture.texture3d);
            }
        }

    }

}