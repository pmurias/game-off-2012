package gremlin.meshes {
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.VertexBuffer3D;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.IRestorable;

    /**
     * ...
     * @author mosowski
     */
    public class VertexBuffer implements IRestorable {
        public var ctx:Context;
        public var vertexBuffer3d:VertexBuffer3D;
        public var data:ByteArray;
        public var data32perVertex:int;
        public var numVertices:int;

        public var streams:Dictionary;

        public function VertexBuffer(_ctx:Context, _data:ByteArray = null, _data32perVertex:int = 0) {
            ctx = _ctx;
            ctx.restorableResources.push(this);

            streams = new Dictionary();

            if (_data != null) {
                setData(_data, _data32perVertex);
            }
        }

        public function addStream(name:String, format:String):void {
            var stream:VertexStream = new VertexStream();
            stream.format = format;
            switch (format) {
                case Context3DVertexBufferFormat.FLOAT_1:
                    stream.size = 1;
                    break;
                case Context3DVertexBufferFormat.FLOAT_2:
                    stream.size = 2;
                    break;
                case Context3DVertexBufferFormat.FLOAT_3:
                    stream.size = 3;
                    break;
                case Context3DVertexBufferFormat.FLOAT_4:
                    stream.size = 4;
                    break;
                case Context3DVertexBufferFormat.BYTES_4:
                    stream.size = 1;
                    break;
            }
            stream.offset = getStreamsSize();
            streams[name] = stream;
        }

        /// Returns maximal stream offset / data32PerVertex based on streams.
        public function getStreamsSize():int {
            var size:int = 0;
            for each (var recentStream:VertexStream in streams) {
                if (recentStream.offset + recentStream.size > size) {
                    size = recentStream.offset + recentStream.size;
                }
            }
            return size;
        }

        /// Sets vertex buffer data ByteArray. it does NOT make copy of array.
        public function setData(_data:ByteArray, _data32perVertex:int):void {
            if (vertexBuffer3d != null && (_data.length != data.length || _data32perVertex != data32perVertex)) {
                vertexBuffer3d.dispose();
                vertexBuffer3d = null;
            }

            data = _data;
            data32perVertex = _data32perVertex;
            numVertices = data.length / 4 / data32perVertex;

            upload(0, numVertices);
        }

        /// (Re)uploads pointed part of source ByteArray to GPU
        public function upload(startVertex:int, numNewVertices:int):void {
            if (vertexBuffer3d == null) {
                vertexBuffer3d = ctx.createVertexBuffer(numVertices, data32perVertex);
            }
            vertexBuffer3d.uploadFromByteArray(data, startVertex * data32perVertex * 4, startVertex, numNewVertices);
        }

        /// Sets source ByteArray position to given vertex index and returns array
        public function getDataByteArrayAtVertex(vertexId:int):ByteArray {
            data.position = vertexId * data32perVertex * 4;
            return data;
        }

        public function restore():void {
            vertexBuffer3d = null;
            if (data != null) {
                upload(0, numVertices);
            }
        }

    }

}