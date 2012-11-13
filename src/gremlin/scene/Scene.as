package gremlin.scene {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.IRenderable;
    import gremlin.core.IRenderableContainer;
    import gremlin.error.ENoMaterial;
    import gremlin.lights.DirectionaLight;
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
        public var directionaLights:Vector.<DirectionaLight>;

        public function Scene(_ctx:Context) {
            ctx = _ctx;
            renderablesByMaterial = new Dictionary(true);
            directionaLights = new Vector.<DirectionaLight>();
        }

        public function addRenderable(renderable:IRenderable):void {
            var material:Material = renderable.getMaterial();
            if (material == null) {
                throw ENoMaterial(renderable);
            }

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

        public function addDirectionalLight(directionalLight:DirectionaLight):void {
            directionaLights.push(directionalLight);
        }

        public function removeDirectionalLight(directionalLight:DirectionaLight):void {
            directionaLights.splice(directionaLights.indexOf(directionalLight), 1);
        }

        public function render():void {
            var i:int, j:int, k:int;
            var passQueue:Vector.<Pass> = ctx.materialMgr.getPassRenderingQueue();
            for (i = 0; i < passQueue.length; ++i) {
                var pass:Pass = passQueue[i];
                var renderables:Vector.<IRenderable> = renderablesByMaterial[passQueue[i].material];
                if (renderables != null && renderables.length > 0) {
                    ctx.setBlendFactors(pass.sourceBlendFactor, pass.destBlendFactor);
                    ctx.setDepthTest(pass.depthMask, pass.depthCompareMode);
                    pass.shader.activate();

                    for (var samplerName:String in pass.samplers) {
                        var samplerTexture:TextureResource = pass.samplers[samplerName];
                        if (samplerTexture == ctx.activeRenderTargetTexture || samplerTexture.isLoaded == false) {
                            pass.shader.fragmentProgram.setSampler(samplerName, ctx.textureMgr.fallbackTexture);
                        } else {
                            pass.shader.fragmentProgram.setSampler(samplerName, samplerTexture);
                        }
                    }

                    if (pass.iterationMode == Pass.ITERATION_ONE) {
                        for (j = 0; j < renderables.length; ++j) {
                            if (renderables[j].isVisible()) {
                                renderables[j].render(ctx);
                            }
                        }
                    } else if (pass.iterationMode == Pass.ITERATION_ONE_PER_DIRECTIONAL_LIGHT) {
                        for (k = 0; k < directionaLights.length; ++k) {
                            ctx.autoParams.setActiveLight(directionaLights[k]);

                            for (j = 0; j < renderables.length; ++j) {
                                if (renderables[j].isVisible()) {
                                    renderables[j].render(ctx);
                                }
                            }
                        }
                    }
                }
            }
        }


    }

}