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
            super(this, _ctx);
            samplers = new Dictionary();
            type = Context3DProgramType.FRAGMENT;
        }

        override public function fromJSON(json:Object):void {
            super.fromJSON(json);

            for (var i:int = 0; i < json.samplers.length; ++i) {
                addSampler(json.samplers[i].name, json.samplers[i].register);
            }
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