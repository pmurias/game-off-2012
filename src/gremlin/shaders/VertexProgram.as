package gremlin.shaders {
    import flash.display3D.Context3DProgramType;
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.meshes.VertexBuffer;
    import gremlin.meshes.VertexStream;

    /**
     * ...
     * @author mosowski
     */
    public class VertexProgram extends ShaderProgram {
        public var attrs:Dictionary;

        public function VertexProgram(_ctx:Context) {
            super(_ctx);
            attrs = new Dictionary();
            type = Context3DProgramType.VERTEX;
        }

        public function addAttr(name:String, register:int):void {
            attrs[name] = register;
        }

        public function setVertexAttr(name:String, vertexBuffer:VertexBuffer):void {
            if (attrs[name] != null) {
                var stream:VertexStream = vertexBuffer.streams[name];
                ctx.setVertexBufferAt(attrs[name], vertexBuffer.vertexBuffer3d, stream.offset, stream.format);
            }
        }
    }

}