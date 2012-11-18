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
    import game.GameContext;
    import game.Initializer;
    import game.Level;
    import game.TileSet;
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
     * @author mosowski
     */
    public class Main extends Sprite {
        public var initializer:Initializer;
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
            initializer = new Initializer(ctx);
            initializer.start();
        }

    }

}