package gremlin.scene {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.IRenderable;
    import gremlin.core.IRenderableContainer;
    import gremlin.materials.Material;
    import gremlin.materials.Pass;
    import gremlin.textures.TextureResource;

    /**
     * ...
     * @author mosowski
     */
    public class Scene {
        private var ctx:Context;
        public var renderablesByMaterial:Dictionary;

        public function Scene(_ctx:Context) {
            ctx = _ctx;
            renderablesByMaterial = new Dictionary(true);
        }

        public function addRenderable(renderable:IRenderable):void {
            var material:Material = renderable.getMaterial();
            var renderables:Vector.<IRenderable> = renderablesByMaterial[material];
            if (renderables == null) {
                renderablesByMaterial[material] = renderables = new Vector.<IRenderable>();
            }
            renderables.push(renderable);
        }

        public function removeRenderable(renderable:IRenderable):void {
            var material:Material = renderable.getMaterial();
            var renderables:Vector.<IRenderable> = new Vector.<IRenderable>();
            if (renderables != null) {
                renderables.splice(renderables.indexOf(renderable), 1);
            }
        }

        public function notifyRenderableMaterialChange(renderable:IRenderable):void {
            removeRenderable(renderable);
            addRenderable(renderable);
        }

        public function render():void {
            var i:int, j:int;
            var passQueue:Vector.<Pass> = ctx.materialMgr.getPassRenderingQueue();
            for (i = 0; i < passQueue.length; ++i) {
                var pass:Pass = passQueue[i];
                var renderables:Vector.<IRenderable> = renderablesByMaterial[passQueue[i].material];
                if (renderables != null && renderables.length > 0) {
                    pass.shader.activate();

                    for (var samplerName:String in pass.samplers) {
                        var samplerTexture:TextureResource = pass.samplers[samplerName];
                        if (samplerTexture == ctx.activeRenderTargetTexture) {
                            pass.shader.fragmentProgram.setSampler(samplerName, ctx.textureMgr.fallbackTexture);
                        } else {
                            pass.shader.fragmentProgram.setSampler(samplerName, samplerTexture);
                        }

                    }
                    for (j = 0; j < renderables.length; ++j) {
                        renderables[j].render(ctx);
                    }
                }
            }
        }


    }

}