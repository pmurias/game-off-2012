package gremlin.shaders.consts {
    import gremlin.shaders.ShaderProgram;

    /**
     * ...
     * @author mosowski
     */
    public class ShaderConstVec2 implements IShaderConst {
        public var x:Number;
        public var y:Number;

        public function ShaderConstVec2(_x:Number = 0, _y:Number = 0) {
            x = _x;
            y = _y;
        }

        public function uploadValue(shaderProgram:ShaderProgram, name:String):void {
            shaderProgram.setParamVec2(name, x, y);
        }
    }

}