package gremlin.gremlin2d {
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import gremlin.core.Context;
    import gremlin.meshes.IndexBuffer;
    import gremlin.meshes.VertexBuffer;

    /**
     * ...
     * @author mosowski
     */
    public class Overlay {
        public var ctx:Context;
        public var unitQuadVertexBuffer:VertexBuffer;
        public var unitQuadIndexBuffer:IndexBuffer;

        public function Overlay(_ctx:Context) {
            ctx = _ctx;
            var vertexData:ByteArray = new ByteArray();
            vertexData.endian = Endian.LITTLE_ENDIAN;
            vertexData.writeFloat(0);
            vertexData.writeFloat(0);
            vertexData.writeFloat(0);
            vertexData.writeFloat(1);
            vertexData.writeFloat(1);
            vertexData.writeFloat(1);
            vertexData.writeFloat(1);
            vertexData.writeFloat(0);
            unitQuadVertexBuffer = new VertexBuffer(ctx, vertexData, 2);
            unitQuadVertexBuffer.addStream("position", Context3DVertexBufferFormat.FLOAT_2);
            var indexData:ByteArray = new ByteArray();
            indexData.endian = Endian.LITTLE_ENDIAN;
            indexData.writeShort(0);
            indexData.writeShort(1);
            indexData.writeShort(2);
            indexData.writeShort(2);
            indexData.writeShort(3);
            indexData.writeShort(0);
            unitQuadIndexBuffer = new IndexBuffer(ctx, indexData);
        }

    }

}