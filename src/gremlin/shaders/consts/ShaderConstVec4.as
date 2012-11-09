package gremlin.shaders.consts {
    import gremlin.core.Key;
    import gremlin.shaders.ShaderProgram;

    /**
     * ...
     * @author mosowski
     */
    public class ShaderConstVec4 implements IShaderConst {
        public var x:Number;
        public var y:Number;
        public var z:Number;
        public var w:Number;

        public function ShaderConstVec4(_x:Number = 0, _y:Number = 0, _z:Number = 0, _w:Number = 0) {
            x = _x;
            y = _y;
            z = _z;
            w = _w;
        }

        public function uploadValue(shaderProgram:ShaderProgram, name:Key):void {
            shaderProgram.setParamVec4(name, x, y, z, w);
        }

    }

}