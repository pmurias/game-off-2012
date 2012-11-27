package game {
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
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
        private var required:LoaderBatch;
        public var ctx:Context;
        public var gameCtx:GameContext;
        public var modelResources:Vector.<String>;

        public function Initializer(_ctx:Context) {
            ctx = _ctx;
            modelResources = new Vector.<String>();
        }

        public function loadModelResource(filePath:String):void {
            modelResources.push(filePath);
            required.addDataUrl(filePath);
        }

        public function start():void {
            required = new LoaderBatch(ctx.loaderMgr);
            required.addDataUrl("static/particle_vp.txt");
            required.addDataUrl("static/particle_fp.txt");
            required.addDataUrl("static/particle_alpha_fp.txt");
            required.addDataUrl("static/tex2d_vp.txt");
            required.addDataUrl("static/tex2d_fp.txt");
            required.addDataUrl("static/animated_vp.txt");
            required.addDataUrl("static/animated_fp.txt");
            required.addDataUrl("static/textured_vp.txt");
            required.addDataUrl("static/textured_fp.txt");
            required.addDataUrl("static/textured_light_vp.txt");
            required.addDataUrl("static/textured_light_fp.txt");
            required.addDataUrl("static/animated_light_vp.txt");
            required.addDataUrl("static/cloning_mode_fp.txt");
            required.addDataUrl("static/vortal_fp.txt");

            required.addDataUrl("static/map.bmap");
            required.addDataUrl("static/level0.bmap");
            required.addDataUrl("static/level1.bmap");
            required.addDataUrl("static/level2.bmap");
            required.addDataUrl("static/level3.bmap");
            required.addDataUrl("static/level4.bmap");
            required.addDataUrl("static/level5.bmap");
            required.addDataUrl("static/level6.bmap");
            required.addDataUrl("static/level7.bmap");

            required.addDataUrl("static/CoxSkeleton.orcs");
            required.addDataUrl("static/BeholderSkeleton.orcs");
            required.addDataUrl("static/ReaperSkeleton.orcs");

            loadModelResource("static/RoundShadow.orcm");
            loadModelResource("static/BloodSpatter.orcm");
            loadModelResource("static/Cox.orcm");
            loadModelResource("static/Beholder.orcm");
            loadModelResource("static/Reaper.orcm");
            loadModelResource("static/BeholderDead.orcm");
            loadModelResource("static/Hero.orcm");
            loadModelResource("static/Crate.orcm");
            loadModelResource("static/Blade.orcm");
            loadModelResource("static/Fork.orcm");
            loadModelResource("static/Pickable.orcm");
            loadModelResource("static/PickableEye.orcm");
            loadModelResource("static/PickablePoint.orcm");
            loadModelResource("static/TileFloorNice.orcm");
            loadModelResource("static/TileFloorDep.orcm");
            loadModelResource("static/TileFloorHappy.orcm");
            loadModelResource("static/TileSpikes.orcm");
            loadModelResource("static/TileBlock.orcm");
            loadModelResource("static/TileWall.orcm");
            loadModelResource("static/TileFade.orcm");
            loadModelResource("static/TileFadeCorner.orcm");
            loadModelResource("static/TileFadeOuterCorner.orcm");
            loadModelResource("static/TileSpikesCorner.orcm");
            loadModelResource("static/TileSpikesOuterCorner.orcm");
            loadModelResource("static/TileGrass.orcm");
            loadModelResource("static/TileGrassSlot.orcm");
            loadModelResource("static/TileVortal.orcm");
            loadModelResource("static/TileVortalWalled.orcm");

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

            ctx.shaderMgr.createShaderFromJSON("ParticleAlpha",
                translator.translate(ctx.loaderMgr.getLoaderString("static/particle_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/particle_alpha_fp.txt"), ShaderTranslator.FRAGMENT));

            ctx.shaderMgr.createShaderFromJSON("Tex2d",
                translator.translate(ctx.loaderMgr.getLoaderString("static/tex2d_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/tex2d_fp.txt"), ShaderTranslator.FRAGMENT));

            ctx.shaderMgr.createShaderFromJSON("CloningMode",
                translator.translate(ctx.loaderMgr.getLoaderString("static/tex2d_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/cloning_mode_fp.txt"), ShaderTranslator.FRAGMENT));


            ctx.shaderMgr.createShaderFromJSON("Animated",
                translator.translate(ctx.loaderMgr.getLoaderString("static/animated_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/animated_fp.txt"), ShaderTranslator.FRAGMENT));

            ctx.shaderMgr.createShaderFromJSON("Textured",
                translator.translate(ctx.loaderMgr.getLoaderString("static/textured_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/textured_fp.txt"), ShaderTranslator.FRAGMENT));

            ctx.shaderMgr.createShaderFromJSON("Vortal",
                translator.translate(ctx.loaderMgr.getLoaderString("static/textured_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/vortal_fp.txt"), ShaderTranslator.FRAGMENT));

            ctx.shaderMgr.createShaderFromJSON("TexturedLight",
                translator.translate(ctx.loaderMgr.getLoaderString("static/textured_light_vp.txt"), ShaderTranslator.VERTEX),
                translator.translate(ctx.loaderMgr.getLoaderString("static/textured_light_fp.txt"), ShaderTranslator.FRAGMENT));

            ctx.shaderMgr.createShaderFromJSON("AnimatedLight",
                translator.translate(ctx.loaderMgr.getLoaderString("static/animated_light_vp.txt"), ShaderTranslator.VERTEX),
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

        private function createTexturedMultiplyMaterial(name:String, texturePath:String):Material {
            var m:Material;
            var p:Pass;
            m = ctx.materialMgr.createMaterial(name);
            p = new Pass();
            p.sourceBlendFactor = Context3DBlendFactor.DESTINATION_COLOR;
            p.destBlendFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            p.depthMask = false;
            p.transparent = true;
            p.shader = ctx.shaderMgr.getShader("Textured");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource(texturePath);
            m.addPass(p);
            return m;
        }

        private function createTexturedAlphaMaterial(name:String, texturePath:String):Material {
            var m:Material;
            var p:Pass;
            m = ctx.materialMgr.createMaterial(name);
            p = new Pass();
            p.sourceBlendFactor = Context3DBlendFactor.SOURCE_ALPHA;
            p.destBlendFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            p.depthMask = false;
            p.transparent = true;
            p.shader = ctx.shaderMgr.getShader("Textured");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource(texturePath);
            m.addPass(p);
            return m;
        }

        private function createTexturedLightAlphaMaterial(name:String, texturePath:String):Material {
            var m:Material;
            var p:Pass;
            m = ctx.materialMgr.createMaterial(name);
            p = new Pass();
            p.sourceBlendFactor = Context3DBlendFactor.SOURCE_ALPHA;
            p.destBlendFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            p.depthMask = false;
            p.transparent = true;
            p.shader = ctx.shaderMgr.getShader("TexturedLight");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource(texturePath);
            m.addPass(p);
            return m;
        }

        public function createParticleAdditiveMaterial(name:String, texturePath:String):Material {
            var m:Material;
            var p:Pass;
            m = ctx.materialMgr.createMaterial(name);
            p = new Pass();
            p.sourceBlendFactor = Context3DBlendFactor.ONE;
            p.destBlendFactor = Context3DBlendFactor.ONE;
            p.depthMask = false;
            p.transparent = true;
            p.shader = ctx.shaderMgr.getShader("Particle");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource(texturePath);
            m.addPass(p);
            return m;
        }

        public function createParticleMultiplyMaterial(name:String, texturePath:String):Material {
            var m:Material;
            var p:Pass;
            m = ctx.materialMgr.createMaterial(name);
            p = new Pass();
            p.sourceBlendFactor = Context3DBlendFactor.SOURCE_ALPHA;
            p.destBlendFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            p.depthMask = false;
            p.transparent = true;
            p.shader = ctx.shaderMgr.getShader("ParticleAlpha");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource(texturePath);
            m.addPass(p);
            return m;
        }

        private function createTex2dMaterial(name:String, texturePath:String):Material {
            var m:Material;
            var p:Pass;
            m = ctx.materialMgr.createMaterial(name);
            p = new Pass();
            p.sourceBlendFactor = Context3DBlendFactor.SOURCE_ALPHA;
            p.destBlendFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            p.depthMask = false;
            p.transparent = true;
            p.shader = ctx.shaderMgr.getShader("Tex2d");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource(texturePath);
            m.addPass(p);
            return m;
        }

        private function createAnimatedLightMaterial(name:String, texturePath:String):Material {
            var m:Material;
            var p:Pass;
            m = ctx.materialMgr.createMaterial(name);
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("AnimatedLight");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource(texturePath);
            m.addPass(p);
            return m;
        }

        public function initMaterials():void {
            var m:Material;
            var p:Pass;

            ctx.textureMgr.createRenderTargetTextureResource("bigRTT2", 512, 512);


            m = ctx.materialMgr.createMaterial("Cox");
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("Animated");
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource("static/chess.png");
            m.addPass(p);

            createAnimatedLightMaterial("Beholder", "static/beholder.png");
            createAnimatedLightMaterial("Reaper", "static/reaper.png");

            createTexturedMaterial("Hero", "static/hero.png");
            createTexturedMaterial("Blade", "static/blade.png");
            createTexturedMaterial("Fork", "static/fork.png");
            createTexturedMaterial("Crate", "static/crate.png");
            createTexturedMaterial("Pickable", "static/pickable.png");
            createTexturedMaterial("PickableH", "static/pickable_h.png");
            createTexturedMaterial("PickableC", "static/pickable_c.png");
            createTexturedMaterial("PickableF", "static/pickable_f.png");
            createTexturedMaterial("PickableM", "static/pickable_m.png");
            createTexturedMaterial("PickableEye", "static/pickable_eye.png");
            createTexturedMaterial("PickablePoint", "static/pickable_point.png");
            createTexturedMaterial("FloorNice", "static/tile_chess_nice.png");
            createTexturedMaterial("FloorDep", "static/tile_chess_dep.png");
            createTexturedMaterial("FloorHappy", "static/tile_chess_happy.png");
            createTexturedMaterial("FloorShade", "static/tile_chess_shade.png");
            createTexturedMaterial("FloorShadeCorner", "static/tile_chess_corner.png");
            createTexturedMaterial("WallShade", "static/tile_wall.png");
            createTexturedMaterial("WallShadeSpikes", "static/tile_wall_shade.png");
            createTexturedMaterial("Spikes", "static/tile_spikes.png");
            createTexturedMaterial("Block", "static/tile_stones.png");
            createTexturedMaterial("Fade", "static/tile_fade.png");
            createTexturedMaterial("FadeCorner", "static/tile_fade_corner.png");
            createTexturedMaterial("FadeOuterCorner", "static/tile_fade_outer_corner.png");
            createTexturedMaterial("FloorShadeOuterCorner", "static/tile_chess_outer_corner.png");
            createTexturedMaterial("Grass", "static/tile_grass.png");
            createTexturedMaterial("GrassShade", "static/tile_grass_shade.png");

            createTexturedMultiplyMaterial("RoundShadow", "static/round_shadow.png");
            createTexturedMultiplyMaterial("BloodSpatter", "static/blood_spatter.png");

            createTexturedAlphaMaterial("BeholderDead", "static/beholder_dead.png");

            createParticleAdditiveMaterial("Particle1", "static/particle_1.png");
            createParticleMultiplyMaterial("ParticleDeath", "static/particle_death.png");

            createTex2dMaterial("Black2d", "static/black.png");

            m = ctx.materialMgr.createMaterial("CloningMode");
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("CloningMode");
            p.destBlendFactor = Context3DBlendFactor.ONE;
            p.sourceBlendFactor = Context3DBlendFactor.ONE;
            p.samplers["clone"] = ctx.textureMgr.getTextureResource("bigRTT2");
            m.addPass(p);

            m = ctx.materialMgr.createMaterial("Vortal");
            p = new Pass();
            p.shader = ctx.shaderMgr.getShader("Vortal");
            p.destBlendFactor = Context3DBlendFactor.ONE;
            p.sourceBlendFactor = Context3DBlendFactor.ONE;
            p.samplers["tex"] = ctx.textureMgr.loadTextureResource("static/vortal.png");
            p.samplers["frame"] = ctx.textureMgr.loadTextureResource("static/vortal_frame.png");
            m.addPass(p);

            ctx.renderTargetMgr.createRenderTargetFromTexture("bigRT2", ctx.textureMgr.getTextureResource("bigRTT2"));
        }

        public function initModels():void {
            ctx.skeletonMgr.loadSkeletonResource("static/CoxSkeleton.orcs");
            ctx.skeletonMgr.loadSkeletonResource("static/BeholderSkeleton.orcs");
            ctx.skeletonMgr.loadSkeletonResource("static/ReaperSkeleton.orcs");

            for (var i:int = 0; i < modelResources.length; ++i) {
                ctx.modelMgr.loadModelResource(modelResources[i]);
            }
        }

    }

}
