package gremlin.particles {
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.geom.Point;
    import flash.utils.ByteArray;
    import gremlin.core.Context;
    import gremlin.core.IRenderable;
    import gremlin.materials.Material;
    import gremlin.shaders.Shader;

    /**
     * ...
     * @author mosowski
     */
    public class BillboardParticlesEntity extends ParticlesEntity implements IRenderable {
        public var material:Material;

        public var minLife:Number;
        public var maxLife:Number;

        public var minStartSize:Number;
        public var maxStartSize:Number;

        public var minEndSize:Number;
        public var maxEndSize:Number;

        public var minVelocity:Number;
        public var maxVelocity:Number;

        private static var uvs:Vector.<Point>;
        private static var data32PerVertex:int;
        {
            uvs = new Vector.<Point>(4, true);
            uvs[0] = new Point(0, 0);
            uvs[1] = new Point(0, 1);
            uvs[2] = new Point(1, 1);
            uvs[3] = new Point(1, 0);

            data32PerVertex = 12;
        }

        public function BillboardParticlesEntity(_ctx:Context) {
            super(this, _ctx);
        }

        public function setMaterial(_material:Material):void {
            if (material) {
                material.removeRenderable(this);
            }
            material = _material;
            material.addRenderable(this);
        }

        override protected function addVertexBufferStreams():void {
            vertexBuffer.addStream("uvBornLife", Context3DVertexBufferFormat.FLOAT_4);
            vertexBuffer.addStream("startPos", Context3DVertexBufferFormat.FLOAT_3);
            vertexBuffer.addStream("deltaPos", Context3DVertexBufferFormat.FLOAT_3);
            vertexBuffer.addStream("size", Context3DVertexBufferFormat.FLOAT_2);
        }

        override protected function writeParticleData(index:int, time:Number):void {
            var life:Number = minLife + (maxLife - minLife) * Math.random();

            var startPosX:Number = node.derivedPosition.x;
            var startPosY:Number = node.derivedPosition.y;
            var startPosZ:Number = node.derivedPosition.z;

            var velocity:Number = minVelocity + (maxVelocity - minVelocity) * Math.random();
            var deltaPosX:Number = direction.x * velocity * life;
            var deltaPosY:Number = direction.y * velocity * life;
            var deltaPosZ:Number = direction.z * velocity * life;

            var startSize:Number = minStartSize + (maxStartSize - minStartSize) * Math.random();
            var deltaSize:Number = minEndSize + (maxEndSize - minEndSize) * Math.random() - startSize;

            particleExpiracy[index] = time + life;

            var vertexData:ByteArray = vertexBuffer.getDataByteArrayAtVertex(index * 4);

            for (var i:int = 0; i < 4; ++i) {
                vertexData.writeFloat(uvs[i].x);
                vertexData.writeFloat(uvs[i].y);
                vertexData.writeFloat(time);
                vertexData.writeFloat(life);

                vertexData.writeFloat(startPosX);
                vertexData.writeFloat(startPosY);
                vertexData.writeFloat(startPosZ);

                vertexData.writeFloat(deltaPosX);
                vertexData.writeFloat(deltaPosY);
                vertexData.writeFloat(deltaPosZ);

                vertexData.writeFloat(startSize);
                vertexData.writeFloat(deltaSize);
            }
        }

        override protected function getData32PerVertex():int {
            return data32PerVertex;
        }

        public function render(ctx:Context):void {
            update();
            ctx.autoParams.modelMatrix.value = ctx.mathConstants.identityMatrix;
            ctx.activeShader.uploadLocalAutoParams();

            for (var attrName:String in ctx.activeShader.vertexProgram.attrs) {
                ctx.activeShader.vertexProgram.setVertexAttr(attrName, vertexBuffer);
            }
            ctx.drawTriangles(indexBuffer);
        }

    }

}