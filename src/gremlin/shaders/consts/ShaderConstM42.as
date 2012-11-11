package gremlin.shaders.consts {
    import flash.geom.Matrix;
    import gremlin.shaders.ShaderProgram;
	/**
     * ...
     * @author ...
     */
    public class ShaderConstM42 implements IShaderConst {
        public var value:Matrix;

        public function uploadValue(shaderProgram:ShaderProgram, name:String):void {
            shaderProgram.setParamM42(name, value);
        }

    }

}