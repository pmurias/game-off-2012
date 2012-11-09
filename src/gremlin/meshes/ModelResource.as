package gremlin.meshes {
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import gremlin.animation.SkeletonResource;
    import gremlin.core.Context;
    import gremlin.core.IResource;
    import gremlin.core.Key;

    /**
     * ...
     * @author mosowski
     */
    public class ModelResource implements IResource {
        public var ctx:Context;
        public var name:String;
        public var submeshes:Vector.<Submesh>;
        public var vertexBuffer:VertexBuffer;
        public var indexBuffer:IndexBuffer;
        public var skeletonResource:SkeletonResource;
        public var isLoaded:Boolean;

        public function ModelResource(_ctx:Context) {
            ctx = _ctx;
            submeshes = new Vector.<Submesh>();
        }

        public function fromJSON(json:Object):void {
            var i:int;
            vertexBuffer = new VertexBuffer(ctx);

            name = json[0];

            var vertexSize:int = 0;
            for (i = 0; i < json[1].length; ++i) {
                var streamSize:int = parseInt(json[1][i][1]);
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
                vertexBuffer.addStream(Key.of(json[1][i][0]), streamType);
                vertexSize += streamSize;
            }

            var vertexData:ByteArray = new ByteArray();
            vertexData.endian = Endian.LITTLE_ENDIAN;

            for (i = 0; i < json[2].length; ++i) {
                vertexData.writeFloat(json[2][i]);
            }
            vertexBuffer.setData(vertexData, vertexSize);

            var indexData:ByteArray = new ByteArray();
            indexData.endian = Endian.LITTLE_ENDIAN;
            var indexOffset:int = 0;

            indexBuffer = new IndexBuffer(ctx);

            for (var materialName:String in json[3]) {
				var submesh:Submesh = new Submesh();
                submesh.modelResource = this;
                submesh.indexOffset = indexOffset;
                submesh.numTriangles = json[3][materialName].length / 3;
                submesh.material = ctx.materialMgr.getMaterial(materialName);
				for (i = 0; i < json[3][materialName].length; ++i) {
                    indexData.writeShort(json[3][materialName][i]);
				}
                indexOffset += json[3][materialName].length;
				submeshes.push(submesh);
			}
            indexBuffer.setData(indexData);

            if (json[4].length > 0) {
                skeletonResource = ctx.skeletonMgr.getSkeletonResourceByName(Key.of(json[4]));
            }

            isLoaded = true;
        }

        public function isResourceLoaded():Boolean {
            return isLoaded;
        }
    }

}