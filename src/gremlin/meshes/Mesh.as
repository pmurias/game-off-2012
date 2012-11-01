package gremlin.meshes {
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import gremlin.core.Context;

    /**
     * ...
     * @author mosowski
     */
    public class Mesh {
        public var ctx:Context;
        public var submeshes:Vector.<Submesh>;
        public var vertexBuffer:VertexBuffer;
        public var indexBuffer:IndexBuffer;

        public function Mesh(_ctx:Context) {
            ctx = _ctx;
            submeshes = new Vector.<Submesh>();
        }

        public function fromJSON(json:Object):void {
            var i:int;
            vertexBuffer = new VertexBuffer(ctx);

            var vertexSize:int = 0;
            for (i = 0; i < json[0].length; ++i) {
                var streamSize:int = parseInt(json[0][i][1]);
                var streamType:String;
                switch (streamSize) {
                    case 1:
                        streamType = Context3DVertexBufferFormat.FLOAT_1;
                        break;
                    case 2:
                        streamType = Context3DVertexBufferFormat.FLOAT_2;
                        break;
                    case 3:
                        streamType = Context3DVertexBufferFormat.FLOAT_3;
                        break;
                    case 4:
                        streamType = Context3DVertexBufferFormat.FLOAT_4;
                        break;
                }
                vertexBuffer.addStream(json[0][i][0], streamType, streamSize);
                vertexSize += streamSize;
            }

            var vertexData:ByteArray = new ByteArray();
            vertexData.endian = Endian.LITTLE_ENDIAN;

            for (i = 0; i < json[1].length; ++i) {
                vertexData.writeFloat(json[1][i]);
            }
            vertexBuffer.setData(vertexData, vertexSize);

            var indexData:ByteArray = new ByteArray();
            indexData.endian = Endian.LITTLE_ENDIAN;
            var indexOffset:int = 0;

            indexBuffer = new IndexBuffer(ctx);

            for (var materialName:String in json[2]) {
				var submesh:Submesh = new Submesh();
                submesh.mesh = this;
                submesh.indexOffset = indexOffset;
                submesh.numTriangles = json[2][materialName].length / 3;
                submesh.material = ctx.materialMgr.getMaterial(materialName);
				for (i = 0; i < json[2][materialName].length; ++i) {
                    indexData.writeShort(json[2][materialName][i]);
				}
                indexOffset += json[2][materialName].length;
				submeshes.push(submesh);
			}
            indexBuffer.setData(indexData);
        }
    }

}