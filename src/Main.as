package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import gremlin.core.Context;
    import gremlin.loading.LoaderBatch;
    import gremlin.loading.LoaderManager;
    import gremlin.materials.Material;
    import gremlin.materials.Pass;
    import gremlin.math.Quaternion;
    import gremlin.meshes.Mesh;
    import gremlin.scene.MeshEntity;
    import gremlin.scene.Node;
    import gremlin.shaders.AutoParams;
    import gremlin.shaders.consts.ShaderConstVec4;
    import gremlin.shaders.Shader;
    import gremlin.textures.TextureManager;
    import gremlin.textures.TextureResource;

    /**
     * ...
     * @author mosowski
     */
    public class Main extends Sprite {
        public var ctx:Context;

        public function Main():void {
            if (stage)
                init();
            else
                addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

            ctx = new Context(stage);
            ctx.addListener(Context.CONTEXT_READY, onCtxReady);
            ctx.requestContext();
        }

        private function onCtxReady(params:Object):void {
            var lb:LoaderBatch = new LoaderBatch(ctx.loaderMgr);
            lb.addListener(LoaderBatch.COMPLETE, onAssetsLoaded);
            lb.addImageUrl("static/chess.png");
            lb.addDataUrl("static/cox.orcm");
            lb.addDataUrl("static/shaders.txt");
            lb.load();
        }

        private function onAssetsLoaded(params:Object):void {
            var tr:TextureResource = ctx.textureMgr.loadTextureResource("static/chess.png", onImageLoaded);
        }

        public var orange:Shader;
        public var textured:Shader;
        public var mesh:Mesh;
        public var rootNode:Node;
        public var cameraMatrix:Matrix3D;

        public var node0:Node;
        public var node1:Node;

        public var ent0:MeshEntity;

        private function onImageLoaded(u:String):void {
            stage.addChild(new Bitmap(
                ctx.textureMgr.getTextureResource("static/chess.png").bitmapSource)
                );

            initShaders();

            initMaterials();

            mesh = new Mesh(ctx);
            mesh.fromJSON(ctx.loaderMgr.getLoaderJSON("static/cox.orcm"));

            cameraMatrix = new Matrix3D();

            rootNode = new Node();
            rootNode.setPosition(0, 0, 10);
            node0 = new Node();
            rootNode.addChild(node0);
            node0.setPosition(5, 0, 0);
            node1 = new Node();
            node0.addChild(node1);
            node1.setPosition(1, 0, 0);
            node1.setScale(0.5, 0.5, 1);

            ent0 = new MeshEntity(mesh, node0);
            ent0 = new MeshEntity(mesh, node1);

            ctx.addListener(Context.ENTER_FRAME, onEnterFrame);
        }

        public function initShaders():void {
            var shaders:Object = ctx.loaderMgr.getLoaderJSON("static/shaders.txt");
            for (var shaderName:String in shaders) {
                shaders[shaderName] = shaders[shaderName].join("\n");
            }
            orange = new Shader(ctx);
            orange.setSources(shaders.vpOrange, shaders.fpOrange);
            orange.vertexProgram.addParam(AutoParams.CAMERA_MATRIX, 0);
            orange.vertexProgram.addParam(AutoParams.MODEL_MATRIX, 4);
            orange.vertexProgram.autoParams.push(AutoParams.CAMERA_MATRIX, AutoParams.MODEL_MATRIX);
            orange.fragmentProgram.addConst("color", 0, new ShaderConstVec4(1, 0.5, 0, 1));
            orange.vertexProgram.addAttr("pos", 0);

            textured = new Shader(ctx);
            textured.setSources(shaders.vpTextured, shaders.fpTextured);
            textured.vertexProgram.addParam(AutoParams.CAMERA_MATRIX, 0);
            textured.vertexProgram.addParam(AutoParams.MODEL_MATRIX, 4);
            textured.vertexProgram.autoParams.push(AutoParams.CAMERA_MATRIX, AutoParams.MODEL_MATRIX);
            textured.vertexProgram.addAttr("pos", 0);
            textured.vertexProgram.addAttr("uv0", 1);
            textured.fragmentProgram.addConst("color", 0, new ShaderConstVec4(1, 0.5, 0, 1));
            textured.fragmentProgram.addSampler("tex", 0);
        }

        public function initMaterials():void {
            var m:Material;
            var p:Pass;
            m = ctx.materialMgr.createMaterial("Coxx");
            p = new Pass();
            p.shader = orange;
            m.addPass(p);

            m = ctx.materialMgr.createMaterial("Cox");
            p = new Pass();
            p.shader = textured;
            p.samplers["tex"] = ctx.textureMgr.getTextureResource("static/chess.png");
            m.addPass(p);
        }

        private function onEnterFrame(params:Object = null):void {
            var lilRot:Quaternion = new Quaternion();
            var lilRight:Vector3D = new Vector3D(0.02, 0, 1);
            lilRight.normalize();
            Quaternion.rotationBetween(lilRot, new Vector3D(0, 0, 1), lilRight);
            rootNode.getRotation().multiplyBy(lilRot);
            rootNode.markAsDirty();
            node0.getRotation().multiplyBy(lilRot);
            node0.getRotation().multiplyBy(lilRot);
            node0.markAsDirty();
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getPosition().y = Math.sin(ctx.time);
            node1.markAsDirty()
            rootNode.updateTransformation();

            textured.fragmentProgram.consts["color"].x =
            textured.fragmentProgram.consts["color"].y =
            textured.fragmentProgram.consts["color"].z = (0.5*Math.sin(ctx.time*10))+0.5

            ctx.projectionUtils.makePerspectiveMatrix(cameraMatrix, 0.1, 100.0, 55, 4 / 3);
            ctx.activeCameraMatrix = cameraMatrix;

            ctx.beginFrame();

            ctx.materialMgr.renderMaterials();

            ctx.endFrame();
        }


    }

}