package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import gremlin.animation.SkeletonResource;
    import gremlin.core.Context;
    import gremlin.loading.LoaderBatch;
    import gremlin.loading.LoaderManager;
    import gremlin.materials.Material;
    import gremlin.materials.Pass;
    import gremlin.math.Quaternion;
    import gremlin.meshes.ModelResource;
    import gremlin.particles.BillboardParticlesEntity;
    import gremlin.particles.ParticlesEntity;
    import gremlin.scene.AnimatedEntity;
    import gremlin.scene.Camera;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.ModelEntity;
    import gremlin.scene.Node;
    import gremlin.shaders.AutoParams;
    import gremlin.shaders.consts.ShaderConstFloat;
    import gremlin.shaders.consts.ShaderConstVec2;
    import gremlin.shaders.consts.ShaderConstVec4;
    import gremlin.shaders.Shader;
    import gremlin.shaders.ShaderTranslator;
    import gremlin.textures.TextureManager;
    import gremlin.textures.TextureResource;

    /**
     *     !!WARNING!!  HIGHLY EXPERIMENTAL AREA  !!WARNING!!
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
            lb.addDataUrl("static/Cox.orcm");
            lb.addDataUrl("static/CoxSkeleton.orcs");
            lb.addDataUrl("static/shaders.txt");
            lb.addDataUrl("static/particle_vp.txt");
            lb.addDataUrl("static/particle_fp.txt");
            lb.load();
        }

        private function onAssetsLoaded(params:Object):void {
            var tr:TextureResource = ctx.textureMgr.loadTextureResource("static/chess.png", onImageLoaded);
        }

        public var orange:Shader;
        public var textured:Shader;
        public var animated:Shader;
        public var particled:Shader;
        public var mesh:ModelResource;
        public var rootNode:Node;
        public var camera:Camera;

        public var node0:Node;
        public var node1:Node;

        public var ent0:AnimatedEntity;
        public var part:BillboardParticlesEntity;

        private function onImageLoaded(u:String):void {
            initShaders();

            initMaterials();

            ctx.skeletonMgr.loadSkeletonResource("static/CoxSkeleton.orcs");

            ctx.modelMgr.loadModelResource("static/Cox.orcm");

            camera = new Camera();
            ctx.addListener(Context.RESIZE, onResize);
            ctx.projectionUtils.makePerspectiveMatrix(camera.projectionMatrix, 0.1, 100.0, 55, stage.stageWidth / stage.stageHeight);
            ctx.setCamera(camera);

            rootNode = new Node();
            rootNode.setPosition(0, -2, 10);
            node0 = new Node();
            rootNode.addChild(node0);
            node0.setPosition(5, 0, 0);
            node1 = new Node();
            node0.addChild(node1);
            node1.setPosition(1, 0, 0);
            node1.setScale(0.5, 0.5, 1);

            ent0 = new AnimatedEntity(ctx.modelMgr.getModelResource("Cox"), node0);
            ent0.setAnimationState("Idle");

            part = new BillboardParticlesEntity(ctx);
            part.minLife = 15;
            part.maxLife = 16;
            part.minStartSize = 1;
            part.maxStartSize = 2;
            part.minEndSize = 0.1;
            part.maxEndSize = 0.1;
            part.minVelocity = 0;
            part.maxVelocity = 0.1;
            part.spawnRate = 6;
            part.node = node0;
            part.setQuota(100);
            part.setMaterial(ctx.materialMgr.getMaterial("Particle"));

            ctx.addListener(Context.ENTER_FRAME, onEnterFrame);
        }

        public function onResize(params:Object = null):void {
            ctx.projectionUtils.makePerspectiveMatrix(camera.projectionMatrix, 0.1, 100.0, 55, stage.stageWidth / stage.stageHeight);
        }

        public function initShaders():void {
            var shaders:Object = ctx.loaderMgr.getLoaderJSON("static/shaders.txt");
            for (var shaderName:String in shaders) {
                shaders[shaderName] = shaders[shaderName].join("\n");
            }
            orange = new Shader(ctx);
            orange.setSources(shaders.vpOrange, shaders.fpOrange);
            orange.vertexProgram.addAutoParam(AutoParams.CAMERA_MATRIX, 0);
            orange.vertexProgram.addAutoParam(AutoParams.MODEL_MATRIX, 4);
            orange.fragmentProgram.addConst("color", 0, new ShaderConstVec4(1, 0.5, 0, 1));
            orange.vertexProgram.addAttr("pos", 0);

            textured = new Shader(ctx);
            textured.setSources(shaders.vpTextured, shaders.fpTextured);
            textured.vertexProgram.addAutoParam(AutoParams.CAMERA_MATRIX, 0);
            textured.vertexProgram.addAutoParam(AutoParams.MODEL_MATRIX, 4);
            textured.vertexProgram.addAttr("pos", 0);
            textured.vertexProgram.addAttr("uv0", 1);
            textured.fragmentProgram.addConst("color", 0, new ShaderConstVec4(1, 0.5, 0, 1));
            textured.fragmentProgram.addSampler("tex", 0);


            animated = new Shader(ctx);
            animated.setSources(shaders.vpAnimated, shaders.fpAnimated);
            animated.vertexProgram.addAutoParam(AutoParams.BONES_MATRICES, 0);
            animated.vertexProgram.addAutoParam(AutoParams.CAMERA_MATRIX, 100);
            animated.vertexProgram.addAutoParam(AutoParams.MODEL_MATRIX, 104);
            animated.vertexProgram.addConst("four", 108, new ShaderConstFloat(4));

            animated.vertexProgram.addAttr("pos", 0);
            animated.vertexProgram.addAttr("uv0", 1);
            animated.vertexProgram.addAttr("bones", 2);
            animated.vertexProgram.addAttr("weights", 3);
            animated.fragmentProgram.addConst("color", 0, new ShaderConstVec4(1, 0.5, 0, 1));
            animated.fragmentProgram.addSampler("tex", 0);

            particled = new Shader(ctx);
            //particled.fromJSON(ctx.loaderMgr.getLoaderJSON("static/particle_vp.json"), ctx.loaderMgr.getLoaderJSON("static/particle_fp.json"));

            var translator:ShaderTranslator = new ShaderTranslator();
            translator.translate(ctx.loaderMgr.getLoaderString("static/particle_vp.txt"), ShaderTranslator.VERTEX);

            particled.fromJSON(
                translator.translate(ctx.loaderMgr.getLoaderString("static/particle_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/particle_fp.txt"), ShaderTranslator.FRAGMENT));
            //particled.setSources(translator.code, shaders.fpParticled);
            //particled.vertexProgram.addAutoParam(AutoParams.MODEL_MATRIX, 0);
            //particled.vertexProgram.addAutoParam(AutoParams.VIEW_MATRIX, 4);
            //particled.vertexProgram.addAutoParam(AutoParams.PROJECTION_MATRIX, 8);
            //particled.vertexProgram.addAutoParam(AutoParams.TIME, 12);
            //particled.vertexProgram.addConst("numbers", 13, new ShaderConstFloat(0.5));
            //particled.vertexProgram.addAttr("uvBornLife", 0);
            //particled.vertexProgram.addAttr("startPos", 1);
            //particled.vertexProgram.addAttr("deltaPos", 2);
            //particled.vertexProgram.addAttr("size", 3);
            //particled.fragmentProgram.addSampler("tex", 0);

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
            p.shader = animated;
            p.samplers["tex"] = ctx.textureMgr.getTextureResource("static/chess.png");
            m.addPass(p);

            ctx.textureMgr.createRenderTargetTextureResource("rtt", 256, 256);

            m = ctx.materialMgr.createMaterial("Particle");
            p = new Pass();
            p.shader = particled;
            p.samplers["tex"] = ctx.textureMgr.getTextureResource("rtt");
            m.addPass(p);

            ctx.renderTargetMgr.createRenderTargetFromTexture("target", ctx.textureMgr.getTextureResource("rtt"));
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
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getRotation().multiplyBy(lilRot);
            node1.getPosition().y = Math.sin(ctx.time);
            node1.markAsDirty();
            rootNode.updateTransformation();

            ent0.currentAnimationState.advance(2);

            textured.fragmentProgram.consts["color"].x =
            textured.fragmentProgram.consts["color"].y =
            textured.fragmentProgram.consts["color"].z = (0.5 * Math.sin(ctx.time * 10)) + 0.5;

            ctx.setCamera(camera);
            ctx.renderTargetMgr.getRenderTarget("target").beginFrame();
            ctx.materialMgr.renderMaterials();
            ctx.renderTargetMgr.getRenderTarget("target").endFrame();

            ctx.renderTargetMgr.defaultRenderTarget.beginFrame();
            ctx.materialMgr.renderMaterials();
            ctx.renderTargetMgr.defaultRenderTarget.endFrame();
        }


    }

}