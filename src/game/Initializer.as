package game {
    import gremlin.core.Context;
    import gremlin.loading.LoaderBatch;
    import gremlin.materials.Material;
    import gremlin.materials.Pass;
    import gremlin.shaders.consts.ShaderConstVec4;
    import gremlin.shaders.ShaderTranslator;
	/**
     * ...
     * @author mosowski
     */
    public class Initializer {
        public var ctx:Context;
        public var gameCtx:GameContext;

        public function Initializer(_ctx:Context) {
            ctx = _ctx;
        }

        public function start():void {
            var required:LoaderBatch = new LoaderBatch(ctx.loaderMgr);
            required.addDataUrl("static/particle_vp.txt");
            required.addDataUrl("static/particle_fp.txt");
            required.addDataUrl("static/tex2d_vp.txt");
            required.addDataUrl("static/tex2d_fp.txt");
            required.addDataUrl("static/animated_vp.txt");
            required.addDataUrl("static/animated_fp.txt");
            required.addDataUrl("static/textured_vp.txt");
            required.addDataUrl("static/textured_fp.txt");
            required.addDataUrl("static/textured_light_vp.txt");
            required.addDataUrl("static/textured_light_fp.txt");

            required.addDataUrl("static/Cox.orcm");
            required.addDataUrl("static/CoxSkeleton.orcs");
            required.addDataUrl("static/Hero.orcm");
            required.addDataUrl("static/TileFloorNice.orcm");
            required.addDataUrl("static/TileFloorDep.orcm");
            required.addDataUrl("static/TileFloorHappy.orcm");
            required.addDataUrl("static/TileSpikes.orcm");
            required.addDataUrl("static/TileBlock.orcm");
            required.addDataUrl("static/TileWall.orcm");

            required.load(onRequiredAssetsLoaded);
        }

        private function onRequiredAssetsLoaded(params:Object):void {
            gameCtx = new GameContext(ctx);

            initShaders();

            initMaterials();

            initModels();

            gameCtx.setupState();
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

            ctx.shaderMgr.createShaderFromJSON("Textured",
                translator.translate(ctx.loaderMgr.getLoaderString("static/textured_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/textured_fp.txt"), ShaderTranslator.FRAGMENT));
            ctx.shaderMgr.getShader("Textured").fragmentProgram.addConst("color", 0, new ShaderConstVec4(1, 1, 1, 1));

            ctx.shaderMgr.createShaderFromJSON("TexturedLight",
                translator.translate(ctx.loaderMgr.getLoaderString("static/textured_light_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/textured_light_fp.txt"), ShaderTranslator.FRAGMENT));
        }

        private function createTexturedMaterial(name:String, texturePath:String):Material {
            var m:Material;
            var p:Pass;
            m = ctx.materialMgr.createMaterial(name);
            p = new Pass();
            p.iterationMode = Pass.ITERATION_ONE_PER_DIRECTIONAL_LIGHT;
            p.shader = ctx.shaderMgr.getShader("TexturedLight");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource(texturePath);
            m.addPass(p);
            return m;
        }

        public function initMaterials():void {
            var m:Material;
            var p:Pass;

            ctx.textureMgr.createRenderTargetTextureResource("rtt", 32, 32);

            m = ctx.materialMgr.createMaterial("Cox");
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("Animated");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource("static/chess.png");
            m.addPass(p);

            createTexturedMaterial("Hero", "static/hero.png");
            createTexturedMaterial("FloorNice", "static/tile_chess_nice.png");
            createTexturedMaterial("FloorDep", "static/tile_chess_dep.png");
            createTexturedMaterial("FloorHappy", "static/tile_chess_happy.png");
            createTexturedMaterial("FloorShade", "static/tile_chess_shade.png");
            createTexturedMaterial("WallShade", "static/tile_wall.png");
            createTexturedMaterial("WallShadeSpikes", "static/tile_wall_shade.png");
            createTexturedMaterial("Spikes", "static/tile_spikes.png");
            createTexturedMaterial("Block", "static/tile_stones.png");


            m = ctx.materialMgr.createMaterial("Particle");
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("Particle");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource("static/chess.png");
            m.addPass(p);

            m = ctx.materialMgr.createMaterial("QuadRTT");
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("Tex2d");
            p.samplers["tex"] = ctx.textureMgr.getTextureResource("rtt");
            m.addPass(p);

            ctx.renderTargetMgr.createRenderTargetFromTexture("target", ctx.textureMgr.getTextureResource("rtt"));
        }

        public function initModels():void {
            ctx.skeletonMgr.loadSkeletonResource("static/CoxSkeleton.orcs");

            ctx.modelMgr.loadModelResource("static/Cox.orcm");
            ctx.modelMgr.loadModelResource("static/Hero.orcm");
            ctx.modelMgr.loadModelResource("static/TileFloorNice.orcm");
            ctx.modelMgr.loadModelResource("static/TileFloorDep.orcm");
            ctx.modelMgr.loadModelResource("static/TileFloorHappy.orcm");
            ctx.modelMgr.loadModelResource("static/TileSpikes.orcm");
            ctx.modelMgr.loadModelResource("static/TileBlock.orcm");
            ctx.modelMgr.loadModelResource("static/TileWall.orcm");
        }

    }

}