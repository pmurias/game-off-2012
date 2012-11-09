package gremlin.shaders {
    import flash.display3D.Context3DProgramType;
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.Key;
    import gremlin.meshes.VertexBuffer;
    import gremlin.meshes.VertexStream;

    /**
     * ...
     * @author mosowski
     */
    public class VertexProgram extends ShaderProgram {
        public var attrs:Dictionary;

        public function VertexProgram(_ctx:Context) {
            super(this, _ctx);
            attrs = new Dictionary(true);
            type = Context3DProgramType.VERTEX;
        }

        override public function fromJSON(json:Object):void {
            super.fromJSON(json);

            for (var i:int = 0; i < json.attrs.length; ++i) {
                addAttr(Key.of(json.attrs[i].name), parseInt(json.attrs[i].register));
            }
        }

        public function addAttr(name:Key, register:int):void {
            attrs[name] = register;
        }

        public function setVertexAttr(name:Key, vertexBuffer:VertexBuffer):void {
            if (attrs[name] != null) {
                var stream:VertexStream = vertexBuffer.streams[name];
                ctx.setVertexBufferAt(attrs[name], vertexBuffer.vertexBuffer3d, stream.offset, stream.format);
            }
        }

        public function setVertexBuffer(vertexBuffer:VertexBuffer):void {
            for (var attrName:Object in attrs) {
                var attrKey:Key = attrName as Key;
                var stream:VertexStream = vertexBuffer.streams[attrKey];
                ctx.setVertexBufferAt(attrs[attrKey], vertexBuffer.vertexBuffer3d, stream.offset, stream.format);
            }
        }
    }

}