package gremlin.shaders.consts {
    import gremlin.shaders.ShaderProgram;

    /**
     * ...
     * @author mosowski
     */
    public interface IShaderConst {
        function uploadValue(shaderProgram:ShaderProgram, name:String):void;
    }

}