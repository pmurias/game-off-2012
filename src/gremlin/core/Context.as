package gremlin.core {
    import flash.display.Stage;
    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.textures.Texture;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    import gremlin.animation.SkeletonManager;
    import gremlin.debug.MemoryStats;
    import gremlin.events.EventDispatcher;
    import gremlin.gremlin2d.Context2d;
    import gremlin.loading.LoaderManager;
    import gremlin.materials.MaterialManager;
    import gremlin.math.MathConstants;
    import gremlin.math.ProjectionUtils;
    import gremlin.meshes.IndexBuffer;
    import gremlin.meshes.ModelManager;
    import gremlin.rendertargets.RenderTargetManager;
    import gremlin.scene.Camera;
    import gremlin.scene.Node;
    import gremlin.shaders.AutoParams;
    import gremlin.shaders.Shader;
    import gremlin.shaders.ShaderManager;
    import gremlin.textures.TextureManager;
    import gremlin.textures.TextureResource;

    /**
     * ...
     * @author mosowski
     */
    public class Context extends EventDispatcher {
        public var stage:Stage;
        public var ctx3d:Context3D;
        public var stats:MemoryStats;
        public var time:Number;
        public var restorableResources:Vector.<IRestorable>;

        public var loaderMgr:LoaderManager;
        public var textureMgr:TextureManager;
        public var skeletonMgr:SkeletonManager;
        public var modelMgr:ModelManager;
        public var shaderMgr:ShaderManager;
        public var materialMgr:MaterialManager;
        public var renderTargetMgr:RenderTargetManager;
        public var autoParams:AutoParams;
        public var ctx2d:Context2d;

        // render state variables
        public var activeShader:Shader;
        public var activeCamera:Camera;
        public var activeRenderTargetTexture:TextureResource;
        public var screenMatrix:Matrix;

        // context3d state variables
        public var sourceBlendFactor:String;
        public var destBlendFactor:String;
        public var depthMask:Boolean;
        public var depthCompareMode:String;

        public var rootNode:Node;

        // utilities
        public var projectionUtils:ProjectionUtils;
        public var mathConstants:MathConstants;

        // used for switching-off vertex streams that are active, but not needed in current call
        // activeVertexStreams remebers also vertex buffer bound to stream
        private var activeVertexStreams:Vector.<VertexBuffer3D>;
        private var neededVertexStreams:Vector.<Boolean>;

        // same as above, except for textur samplers. activeSamplers remembers texture bound to sampler
        private var activeSamplers:Vector.<Texture>;
        private var neededSamplers:Vector.<Boolean>;

        private var activeProgram:Program3D;

        // events constants
        public static const CONTEXT_READY:String = "context_ready";
        public static const CONTEXT_LOST:String = "context_lost";
        public static const ENTER_FRAME:String = "enter_frame";
        public static const RESIZE:String = "resize";

        public static const KEY_DOWN:String = "key_down";
        public static const KEY_UP:String = "key_up";
        public static const MOUSE_DOWN:String = "mouse_down";
        public static const MOUSE_UP:String = "mouse_up";

        public function Context(_stage:Stage) {
            stage = _stage;
            stats = new MemoryStats();
            restorableResources = new Vector.<IRestorable>();

            time = getTimer() / 1000;

            loaderMgr = new LoaderManager();
            textureMgr = new TextureManager(this);
            skeletonMgr = new SkeletonManager(this);
            modelMgr = new ModelManager(this);
            shaderMgr = new ShaderManager(this);
            materialMgr = new MaterialManager(this);
            renderTargetMgr = new RenderTargetManager(this);
            autoParams = new AutoParams(this);
            ctx2d = new Context2d(this);

            screenMatrix = new Matrix();

            rootNode = new Node();

            projectionUtils = new ProjectionUtils();
            mathConstants = new MathConstants();

            activeVertexStreams = new Vector.<VertexBuffer3D>(8, true);
            neededVertexStreams = new Vector.<Boolean>(8, true);

            activeSamplers = new Vector.<Texture>(8, true);
            neededSamplers = new Vector.<Boolean>(8, true);

            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }

        public function requestContext():void {
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextReady);
            stage.stage3Ds[0].requestContext3D();
        }

        private function onContextReady(e:Event = null):void {
            stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE, onContextReady);
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextRecreated);
            stage.addEventListener(Event.RESIZE, onStageResize);

            ctx3d = stage.stage3Ds[0].context3D;
            ctx3d.enableErrorChecking = true;
            configureBackBuffer();
            addListener(CONTEXT_LOST, onContextLost);

            dispatch(CONTEXT_READY);
        }

        private function onContextRecreated(e:Event):void {
            ctx3d = stage.stage3Ds[0].context3D;
            dispatch(CONTEXT_LOST);
        }

        public function onStageResize(e:Event):void {
            configureBackBuffer();
            dispatch(RESIZE);
        }

        public function configureBackBuffer():void {
            ctx3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, true);
            // w*h * (color+depth+stencil)
            stats.frameBufferMemory = stage.stageWidth * stage.stageHeight * (4 + 2 + 1);

            screenMatrix.identity();
            screenMatrix.scale(2 / stage.stageWidth, -2 / stage.stageHeight);
            screenMatrix.translate( -1, 1);
        }

        public function addRestorableResource(resource:IRestorable):void {
            restorableResources.push(resource);
        }

        public function onContextLost(params:Object = null):void {
            stats.reset();
            configureBackBuffer();
            for (var i:int = 0; i < restorableResources.length; ++i) {
                restorableResources[i].restore();
            }
        }

        public function onEnterFrame(e:Event):void {
            time = getTimer() / 1000;
            dispatch(ENTER_FRAME);
        }

        public function onKeyDown(ke:KeyboardEvent):void {
            dispatch(KEY_DOWN, ke);
        }

        public function onKeyUp(ke:KeyboardEvent):void {
            dispatch(KEY_UP, ke);
        }

        public function onMouseDown(me:MouseEvent):void {
            dispatch(MOUSE_DOWN, me);
        }

        public function onMouseUp(me:MouseEvent):void {
            dispatch(MOUSE_UP, me);
        }


        public function createTexture(w:Number, h:Number, fmt:String, rt:Boolean = false):Texture {
            stats.textureMemory += w * h * 4;
            return ctx3d.createTexture(w, h, fmt, rt);
        }

        public function createVertexBuffer(numVertices:int, data32perVertex:int):VertexBuffer3D {
            stats.vertexMemory += numVertices * data32perVertex;
            return ctx3d.createVertexBuffer(numVertices, data32perVertex);
        }

        public function createIndexBuffer(numIndices:int):IndexBuffer3D {
            stats.indexMemory += numIndices * 2;
            return ctx3d.createIndexBuffer(numIndices);
        }

        public function createProgram(vAsm:ByteArray, fAsm:ByteArray):Program3D {
            var program3d:Program3D = ctx3d.createProgram();
            program3d.upload(vAsm, fAsm);
            stats.numPrograms++;
            return program3d;
        }

        public function setProgramConstantFromByteArray(type:String, firstRegister:int, numRegisters:int, data:ByteArray, byteArrayOffset:int):void {
            ctx3d.setProgramConstantsFromByteArray(type, firstRegister, numRegisters, data, byteArrayOffset);
        }

        public function setProgramConstantFromMatrix(type:String, firstRegister:int, data:Matrix3D, transposed:Boolean = true):void {
            ctx3d.setProgramConstantsFromMatrix(type, firstRegister, data, transposed);
        }

        public function setProgramConstantFromVector(type:String, firstRegister:int, data:Vector.<Number>, numRegisters:int = -1):void {
            ctx3d.setProgramConstantsFromVector(type, firstRegister, data, numRegisters);
        }

        public function setVertexBufferAt(streamId:int, vertexBuffer3d:VertexBuffer3D, offset:int, format:String):void {
            if (activeVertexStreams[streamId] != vertexBuffer3d) {
                ctx3d.setVertexBufferAt(streamId, vertexBuffer3d, offset, format);
                activeVertexStreams[streamId] = vertexBuffer3d;
            }
            neededVertexStreams[streamId] = true;
        }

        public function setTextureAt(samplerId:int, texture:Texture):void {
            if (activeSamplers[samplerId] != texture) {
                ctx3d.setTextureAt(samplerId, texture);
                activeSamplers[samplerId] = texture;
            }
            neededSamplers[samplerId] = true;
        }

        public function setProgram(program3d:Program3D):void {
            if (activeProgram != program3d) {
                ctx3d.setProgram(program3d);
                activeProgram = program3d;
            }
            for (var i:int = 0; i < 8; ++i) {
                neededVertexStreams[i] = false;
                neededSamplers[i] = false;
            }
        }

        public function drawTriangles(indexBuffer:IndexBuffer, offset:int=0, numTriangles:int = -1):void {
            for (var i:int = 0; i < 8; ++i) {
                if (activeVertexStreams[i] != null && !neededVertexStreams[i]) {
                    ctx3d.setVertexBufferAt(i, null);
                    activeVertexStreams[i] = null;
                }
                if (activeSamplers[i] != null && !neededSamplers[i]) {
                    ctx3d.setTextureAt(i, null);
                    activeSamplers[i] = null;
                }
            }
            ctx3d.drawTriangles(indexBuffer.indexBuffer3d, offset, numTriangles);
        }

        public function setRenderToTexture(textureResource:TextureResource, depthAndStencilEnabled:Boolean = false, antiAlias:int = 0):void {
            ctx3d.setRenderToTexture(textureResource.texture3d, depthAndStencilEnabled, antiAlias);
            activeRenderTargetTexture = textureResource;
        }

        public function setRenderToBackBuffer():void {
            ctx3d.setRenderToBackBuffer();
            activeRenderTargetTexture = null;
        }

        public function setBlendFactors(sourceFactor:String, destFactor:String):void {
            if (sourceBlendFactor != sourceFactor || destBlendFactor != destFactor) {
                ctx3d.setBlendFactors(sourceFactor, destFactor);
                sourceBlendFactor = sourceFactor;
                destBlendFactor = destFactor;
            }
        }

        public function setDepthTest(_depthMask:Boolean, _depthCompareMode:String):void {
            if (_depthMask != depthMask || _depthCompareMode != depthCompareMode) {
                ctx3d.setDepthTest(_depthMask, _depthCompareMode);
                depthMask = _depthMask;
                depthCompareMode = _depthCompareMode;
            }
        }

        public function clear(red:Number = 0, green:Number = 0, blue:Number = 0, alpha:Number = 1, depth:Number = 1, stencil:uint = 0):void {
            ctx3d.clear(red, green, blue, alpha, depth, stencil);
        }

        public function present():void {
            ctx3d.present();
        }

        public function setCamera(camera:Camera):void {
            activeCamera = camera;
            camera.update();
            autoParams.updateGlobalAutoParamsValues();
        }

    }

}