package gremlin.materials {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.IRenderable;
    import gremlin.textures.TextureResource;

    /**
     * ...
     * @author mosowski
     */
    public class MaterialManager {
        public var ctx:Context;

        // vector keeps all passes sorted by index first, then by shader
        private var passRenderingQueue:Vector.<Pass>;
        private var materials:Dictionary;
        private var passDictByIndex:Array;
        private var renderingQueueDirty:Boolean;

        public function MaterialManager(_ctx:Context) {
            ctx = _ctx;
            materials = new Dictionary();
            passRenderingQueue = new Vector.<Pass>();

            passDictByIndex = new Array();
            renderingQueueDirty = true;
        }

        public function createMaterial(name:String):Material {
            var material:Material = new Material();
            materials[name] = material;
            return material;
        }

        public function getMaterial(name:String):Material {
            return materials[name];
        }

        public function sortMaterials():void {
            var i:int, j:int;
            passDictByIndex.length = 0;
            for each (var material:Material in materials) {
                for (i = 0; i < material.passes.length; ++i) {
                    material.passes[i].index = i;

                    var passDict:Dictionary = passDictByIndex[i];
                    if (passDict == null) {
                        passDict = passDictByIndex[i] = new Dictionary(true);
                    }
                    var passVec:Vector.<Pass> = passDict[material.passes[i].shader];
                    if (!passVec) {
                        passVec = passDict[material.passes[i].shader] = new Vector.<Pass>();
                    }
                    passVec.push(material.passes[i]);
                }
            }
            passRenderingQueue.length = 0;
            for (i = 0; i < passDictByIndex.length; ++i) {
                for (var shader:Object in passDictByIndex[i]) {
                    var passesUsingShader:Vector.<Pass> = passDictByIndex[i][shader];
                    for (j = 0; j < passesUsingShader.length; ++j) {
                        passRenderingQueue.push(passesUsingShader[j]);
                    }
                }
            }
            renderingQueueDirty = false;
        }

        public function renderMaterials():void {
            if (renderingQueueDirty) {
                sortMaterials();
            }
            var i:int, j:int;
            for (i = 0; i < passRenderingQueue.length; ++i) {
                var pass:Pass = passRenderingQueue[i];
                var renderables:Vector.<IRenderable> = passRenderingQueue[i].material.renderables;
                if (renderables.length > 0) {
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