package gremlin.shaders.consts {
    import flash.geom.Matrix3D;
    import gremlin.shaders.ShaderProgram;

    /**
     * ...
     * @author mosowski
     */
    public class ShaderConstM44Array implements IShaderConst {
        public var value:Vector.<Matrix3D>;

        public function ShaderConstM44Array(size:int) {
            value = new Vector.<Matrix3D>(size, true);
        }

        public function uploadValue(shaderProgram:ShaderProgram, name:String):void {
            shaderProgram.setParamM44Array(name, value);
        }

    }

}