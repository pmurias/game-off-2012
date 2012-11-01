package gremlin.meshes {
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

        public function VertexBuffer(_ctx:Context) {
            ctx = _ctx;
            ctx.restorableResources.push(this);

            streams = new Dictionary();
        }

        public function addStream(name:String, format:String, size:int):void {
            var stream:VertexStream = new VertexStream();
            stream.format = format;
            stream.size = size;
            stream.offset = 0;
            for each (var recentStream:VertexStream in streams) {
                if (recentStream.offset + recentStream.size > stream.offset) {
                    stream.offset = recentStream.offset + recentStream.size;
                }
            }
            streams[name] = stream;
        }

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

        public function upload(startVertex:int, numNewVertices:int):void {
            if (vertexBuffer3d == null) {
                vertexBuffer3d = ctx.createVertexBuffer(numVertices, data32perVertex);
            }
            vertexBuffer3d.uploadFromByteArray(data, startVertex * data32perVertex, startVertex, numNewVertices);
        }

        public function getDataByteArrayAtVertex(vertexId:int):ByteArray {
            data.position = vertexId * data32perVertex;
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