package gremlin.shaders {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
	/**
     * ...
     * @author ...
     */
    public class ShaderManager {
        private var ctx:Context;
        private var shaderByName:Dictionary;

        public function ShaderManager(_ctx:Context) {
            ctx = _ctx;
            shaderByName = new Dictionary();
        }

        public function createShaderFromJSON(name:String, vertexJSON:Object, fragmentJSON:Object):Shader {
            var shader:Shader = new Shader(ctx);
            shader.fromJSON(vertexJSON, fragmentJSON);
            shaderByName[name] = shader;
            return shader;
        }

        public function getShader(name:String):Shader {
            return shaderByName[name];
        }

    }

}