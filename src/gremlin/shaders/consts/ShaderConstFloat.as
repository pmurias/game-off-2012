package gremlin.shaders.consts {
    import gremlin.shaders.ShaderProgram;

    /**
     * ...
     * @author mosowski
     */
    public class ShaderConstFloat implements IShaderConst {
        public var value:Number;

        public function ShaderConstFloat(_value:Number=0) {
            value = _value;
        }

        public function uploadValue(shaderProgram:ShaderProgram, name:String):void {
            shaderProgram.setParamFloat(name, value);
        }

    }

}