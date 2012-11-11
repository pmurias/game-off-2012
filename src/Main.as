package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import gremlin.animation.SkeletonResource;
    import gremlin.core.Context;
    import gremlin.gremlin2d.Quad2d;
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
    import gremlin.scene.Scene;
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
            lb.addDataUrl("static/particle_vp.txt");
            lb.addDataUrl("static/particle_fp.txt");
            lb.addDataUrl("static/tex2d_vp.txt");
            lb.addDataUrl("static/tex2d_fp.txt");
            lb.addDataUrl("static/animated_vp.txt");
            lb.addDataUrl("static/animated_fp.txt");
            lb.load();
        }

        private function onAssetsLoaded(params:Object):void {
            var tr:TextureResource = ctx.textureMgr.loadTextureResource("static/chess.png", onImageLoaded);
        }

        public var orange:Shader;
        public var textured:Shader;
        public var particled:Shader;
        public var mesh:ModelResource;
        public var rootNode:Node;
        public var camera:Camera;

        public var node0:Node;
        public var node1:Node;

        public var ent0:AnimatedEntity;
        public var part:BillboardParticlesEntity;

        public var scene0:Scene;
        public var scene1:Scene;
        public var scene2:Scene;

        private function onImageLoaded(u:String):void {
            initShaders();

            initMaterials();

            ctx.skeletonMgr.loadSkeletonResource("static/CoxSkeleton.orcs");

            ctx.modelMgr.loadModelResource("static/Cox.orcm");

            camera = new Camera();
            ctx.addListener(Context.RESIZE, onResize);
            ctx.projectionUtils.makePerspectiveMatrix(camera.projectionMatrix, 0.1, 100.0, 55, stage.stageWidth / stage.stageHeight);
            ctx.setCamera(camera);

            scene0 = new Scene(ctx);
            scene1 = new Scene(ctx);
            scene2 = new Scene(ctx);

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
            ent0.setScene(scene2);

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
            part.setScene(scene0);

            var quad:Quad2d = new Quad2d();
            quad.transformation.identity();
            quad.transformation.scale(stage.stageWidth, stage.stageHeight);
            quad.transformation.translate(stage.stageWidth / 2, stage.stageHeight / 2);
            quad.setMaterial(ctx.materialMgr.getMaterial("QuadRTT"));
            quad.setScene(scene1);
            ctx.addListener(Context.RESIZE, function(params:Object):void {
                quad.transformation.identity();
                quad.transformation.scale(stage.stageWidth, stage.stageHeight);
                quad.transformation.translate(stage.stageWidth / 2, stage.stageHeight / 2);
                });

            ctx.addListener(Context.ENTER_FRAME, onEnterFrame);
        }

        public function onResize(params:Object = null):void {
            ctx.projectionUtils.makePerspectiveMatrix(camera.projectionMatrix, 0.1, 100.0, 55, stage.stageWidth / stage.stageHeight);
        }

        public function initShaders():void {
            var translator:ShaderTranslator = new ShaderTranslator();

            ctx.shaderMgr.createShaderFromJSON("Particle",
                translator.translate(ctx.loaderMgr.getLoaderString("static/particle_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/particle_fp.txt"), ShaderTranslator.FRAGMENT));

            ctx.shaderMgr.createShaderFromJSON("Tex2d",
                translator.translate(ctx.loaderMgr.getLoaderString("static/tex2d_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/tex2d_fp.txt"), ShaderTranslator.FRAGMENT));

            ctx.shaderMgr.createShaderFromJSON("Animated",
                translator.translate(ctx.loaderMgr.getLoaderString("static/animated_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/animated_fp.txt"), ShaderTranslator.FRAGMENT));
            ctx.shaderMgr.getShader("Animated").fragmentProgram.addConst("color", 0, new ShaderConstVec4(1, 0.5, 0, 1));

        }

        public function initMaterials():void {
            var m:Material;
            var p:Pass;


            ctx.textureMgr.createRenderTargetTextureResource("rtt", 128, 128);


            m = ctx.materialMgr.createMaterial("Cox");
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("Animated");
            p.samplers["tex"] = ctx.textureMgr.getTextureResource("static/chess.png");
            m.addPass(p);


            m = ctx.materialMgr.createMaterial("Particle");
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("Particle");
            p.samplers["tex"] = ctx.textureMgr.getTextureResource("static/chess.png");
            m.addPass(p);

            m = ctx.materialMgr.createMaterial("QuadRTT");
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("Tex2d");
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
            ctx.ctx3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);


            ctx.setCamera(camera);
            ctx.renderTargetMgr.defaultRenderTarget.beginFrame();
            scene0.render();

            ctx.renderTargetMgr.getRenderTarget("target").beginFrame();
            scene0.render();
            ctx.renderTargetMgr.getRenderTarget("target").endFrame();

            ctx.renderTargetMgr.defaultRenderTarget.beginFrame();
            ctx.ctx3d.setDepthTest(false, Context3DCompareMode.LESS_EQUAL);
            scene1.render();
            ctx.ctx3d.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
            scene2.render();
            ctx.renderTargetMgr.defaultRenderTarget.endFrame();
        }


    }

}