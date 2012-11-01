package gremlin.meshes {
    import flash.display3D.IndexBuffer3D;
    import flash.utils.ByteArray;
    import gremlin.core.Context;
    import gremlin.core.IRestorable;

    /**
     * ...
     * @author mosowski
     */
    public class IndexBuffer implements IRestorable {
        public var ctx:Context;
        public var indexBuffer3d:IndexBuffer3D;
        public var data:ByteArray;
        public var numIndices:int;

        public function IndexBuffer(_ctx:Context) {
            ctx = _ctx;
            ctx.restorableResources.push(this);
        }

        public function setData(_data:ByteArray):void {
            if (indexBuffer3d != null && _data.length != data.length) {
                indexBuffer3d.dispose();
                indexBuffer3d = null;
            }

            data = _data;
            numIndices = data.length / 2;
            upload();
        }

        public function upload():void {
            if (indexBuffer3d == null) {
                indexBuffer3d = ctx.createIndexBuffer(numIndices);
            }
            indexBuffer3d.uploadFromByteArray(data, 0, 0, numIndices);
        }

        public function restore():void {
            indexBuffer3d = null;
            if (data != null) {
                upload();
            }
        }

    }

}