package gremlin.particles {
    import flash.geom.Vector3D;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import gremlin.core.Context;
    import gremlin.core.IDisposable;
    import gremlin.core.IRenderable;
    import gremlin.error.EAbstractClass;
    import gremlin.materials.Material;
    import gremlin.meshes.IndexBuffer;
    import gremlin.meshes.VertexBuffer;
    import gremlin.scene.Node;

    /**
     * ...
     * @author mosowski
     */
    public class ParticlesEntity implements IDisposable {
        protected var ctx:Context;
        public var node:Node;
        protected var vertexBuffer:VertexBuffer;
        protected var indexBuffer:IndexBuffer;
        protected var vertexData:ByteArray;

        protected var particleExpiracy:Vector.<Number>;
        private var lastUsedIndex:int;
        private var lastUpdateTime:Number;

        private var dirtyDataStartOffset:int;
        private var dirtyDataEndOffset:int;

        private var particlesToSpawn:Number;
        private var quota:int;
        public var spawnRate:Number;
        public var direction:Vector3D;

        public var enabled:Boolean;
        public var visible:Boolean;

        public function ParticlesEntity(self:ParticlesEntity, _ctx:Context)  {
            if (self != this) {
                throw new EAbstractClass(ParticlesEntity);
            } else {
                ctx = _ctx;
                lastUsedIndex = 0;
                lastUpdateTime = ctx.time;
                particlesToSpawn = 0;

                dirtyDataStartOffset = -1;
                dirtyDataEndOffset = 0;

                particlesToSpawn = 0;
                spawnRate = 0;
                direction = new Vector3D();

                enabled = true;
                visible = true;
            }
        }

        public function setQuota(_quota:int):void {
            quota = _quota;

            var i:int;
            var data32PerVertex:int = getData32PerVertex();
            var numVertices:int = quota * 4;

            particleExpiracy = new Vector.<Number>(quota, true);
            for (i = 0; i < quota; ++i) {
                particleExpiracy[i] = 0;
            }

            vertexData = new ByteArray();
            vertexData.endian = Endian.LITTLE_ENDIAN;
            for (i = 0; i < numVertices * data32PerVertex; ++i) {
                vertexData.writeFloat(0);
            }
            vertexBuffer = new VertexBuffer(ctx, vertexData, data32PerVertex);
            addVertexBufferStreams();

            var indexData:ByteArray = new ByteArray();
            indexData.endian = Endian.LITTLE_ENDIAN;
            for (i = 0; i < quota * 4; i += 4) {
                indexData.writeUnsignedInt(i | i + 1 << 16);
                indexData.writeUnsignedInt(i + 2 | i + 2 << 16);
                indexData.writeUnsignedInt(i + 3 | i << 16);
            }
            indexBuffer = new IndexBuffer(ctx, indexData);
        }

        public function update():void {
            var time:Number = ctx.time;
            var deltaTime:Number = time - lastUpdateTime;
            lastUpdateTime = time;

            if (enabled == true) {
                particlesToSpawn += spawnRate * deltaTime;
                direction.setTo(0, 0, -1);
                node.derivedRotation.transformVector(direction);
            }

            while (particlesToSpawn >= 1) {
                for (var i:int = 0; i < quota; ++i) {
                    var p:int = (lastUsedIndex + i) % quota;
                    if (time > particleExpiracy[p]) {
                        writeParticleData(p, time);
                        particlesToSpawn--;
                        lastUsedIndex = p;
                        if (dirtyDataStartOffset == -1) {
                            dirtyDataStartOffset = dirtyDataEndOffset = p;
                        } else {
                            if (p > dirtyDataEndOffset) {
                                dirtyDataEndOffset = p;
                            }
                            if (p < dirtyDataStartOffset) {
                                dirtyDataStartOffset = p;
                            }
                        }
                        break;
                    }
                }
                if (i == quota) { // not enough room for next particle, nothing to do here
                    particlesToSpawn = 0;
                }
            }

            if (dirtyDataStartOffset != -1) {
                vertexBuffer.upload(dirtyDataStartOffset * 4, (dirtyDataEndOffset - dirtyDataStartOffset + 1) * 4);
                dirtyDataStartOffset = dirtyDataEndOffset = -1;
            }
        }

        public function isVisible():Boolean {
            return visible;
        }

        public function dispose():void {
            vertexBuffer.dispose();
            indexBuffer.dispose();
        }

        protected function addVertexBufferStreams():void {
            throw "addVertexBufferStreams not implemented.";
        }

        protected function writeParticleData(index:int, time:Number):void {
            throw "writeParticleData not implemented."
        }

        protected function getData32PerVertex():int {
            throw "getData32PerVertex not implemented.";
            return 0;
        }

    }

}