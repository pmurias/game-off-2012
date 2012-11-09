package gremlin.shaders.consts {
    import gremlin.core.Key;
    import gremlin.shaders.ShaderProgram;

    /**
     * ...
     * @author mosowski
     */
    public interface IShaderConst {
        function uploadValue(shaderProgram:ShaderProgram, name:Key):void;
    }

}