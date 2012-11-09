package gremlin.shaders.consts {
    import flash.geom.Matrix3D;
    import gremlin.core.Key;
    import gremlin.shaders.ShaderProgram;

    /**
     * ...
     * @author mosowski
     */
    public class ShaderConstM44 implements IShaderConst {
        public var value:Matrix3D;

        public function uploadValue(shaderProgram:ShaderProgram, name:Key):void {
            shaderProgram.setParamM44(name, value);
        }
    }

}