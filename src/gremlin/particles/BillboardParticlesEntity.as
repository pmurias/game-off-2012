package gremlin.particles {
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.geom.Point;
    import flash.utils.ByteArray;
    import gremlin.core.Context;
    import gremlin.core.IRenderable;
    import gremlin.core.IRenderableContainer;
    import gremlin.materials.Material;
    import gremlin.scene.Scene;
    import gremlin.shaders.Shader;

    /**
     * ...
     * @author mosowski
     */
    public class BillboardParticlesEntity extends ParticlesEntity implements IRenderable, IRenderableContainer {
        public var material:Material;
        public var scenes:Vector.<Scene>;

        public var minLife:Number;
        public var maxLife:Number;

        public var minStartSize:Number;
        public var maxStartSize:Number;

        public var minEndSize:Number;
        public var maxEndSize:Number;

        public var minVelocity:Number;
        public var maxVelocity:Number;

        // ABGR
        public var minStartColor:uint;
        public var maxStartColor:uint;

        public var minEndColor:uint;
        public var maxEndColor:uint;

        private static var uvs:Vector.<Point>;
        private static var data32PerVertex:int;
        {
            uvs = new Vector.<Point>(4, true);
            uvs[0] = new Point(0, 0);
            uvs[1] = new Point(0, 1);
            uvs[2] = new Point(1, 1);
            uvs[3] = new Point(1, 0);

            data32PerVertex = 14;
        }

        public function BillboardParticlesEntity(_ctx:Context) {
            super(this, _ctx);
            scenes = new Vector.<Scene>()
        }

        public function setMaterial(material:Material):void {
            for (var i:int = 0; i < scenes.length; ++i) {
                scenes[i].notifyRenderableMaterialChange(this, this.material, material);
            }
            this.material = material;

        }

        public function addToScene(scene:Scene):void {
            scene.addRenderable(this);
            scenes.push(scene);
        }

        public function removeFromScene(scene:Scene):void {
            scene.removeRenderable(this);
            scenes.splice(scenes.indexOf(scene), 1);
        }

        public function getMaterial():Material {
            return material;
        }

        override protected function addVertexBufferStreams():void {
            vertexBuffer.addStream("uvBornLife", Context3DVertexBufferFormat.FLOAT_4);
            vertexBuffer.addStream("startPos", Context3DVertexBufferFormat.FLOAT_3);
            vertexBuffer.addStream("deltaPos", Context3DVertexBufferFormat.FLOAT_3);
            vertexBuffer.addStream("size", Context3DVertexBufferFormat.FLOAT_2);
            vertexBuffer.addStream("startColor", Context3DVertexBufferFormat.BYTES_4);
            vertexBuffer.addStream("endColor", Context3DVertexBufferFormat.BYTES_4);
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

            var f:Number = Math.random();
            var startColor:uint =
            (minStartColor & 0xFF000000 + int((maxStartColor & 0xFF000000 - minStartColor & 0xFF000000) * f) & 0xFF000000)
            | (minStartColor & 0x00FF0000 + int((maxStartColor & 0x00FF0000 - minStartColor & 0x00FF0000) * f) & 0x00FF0000)
            | (minStartColor & 0x0000FF00 + int((maxStartColor & 0x0000FF00 - minStartColor & 0x0000FF00) * f) & 0x0000FF00)
            | (minStartColor & 0x000000FF + int((maxStartColor & 0x000000FF - minStartColor & 0x000000FF) * f) & 0x000000FF);

            var endColor:uint =
            (minEndColor & 0xFF000000 + int((maxEndColor & 0xFF000000 - minEndColor & 0xFF000000) * f) & 0xFF000000)
            | (minEndColor & 0x00FF0000 + int((maxEndColor & 0x00FF0000 - minEndColor & 0x00FF0000) * f) & 0x00FF0000)
            | (minEndColor & 0x0000FF00 + int((maxEndColor & 0x0000FF00 - minEndColor & 0x0000FF00) * f) & 0x0000FF00)
            | (minEndColor & 0x000000FF + int((maxEndColor & 0x000000FF - minEndColor & 0x000000FF) * f) & 0x000000FF);

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

                vertexData.writeUnsignedInt(startColor);
                vertexData.writeUnsignedInt(endColor);
            }
        }

        override protected function getData32PerVertex():int {
            return data32PerVertex;
        }

        public function render(ctx:Context):void {
            update();
            ctx.autoParams.modelMatrix.value = ctx.mathUtils.identityMatrix;
            ctx.activeShader.uploadLocalAutoParams();

            ctx.activeShader.vertexProgram.setVertexBuffer(vertexBuffer);
            ctx.drawTriangles(indexBuffer);
        }

    }

}