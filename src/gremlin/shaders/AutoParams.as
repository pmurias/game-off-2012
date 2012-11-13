package gremlin.shaders {
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.lights.ILight;
    import gremlin.shaders.consts.ShaderConstFloat;
    import gremlin.shaders.consts.ShaderConstM42;
    import gremlin.shaders.consts.ShaderConstM44;
    import gremlin.shaders.consts.ShaderConstM44Array;
    import gremlin.shaders.consts.ShaderConstVec4;

    /**
     * ...
     * @author mosowski
     */
    public class AutoParams {
        public var ctx:Context;
        //  autoparameters per-pass
        public var globalAutoParams:Dictionary;
        // autoparameters per-renderable
        public var localAutoParams:Dictionary;

        public var cameraMatrix:ShaderConstM44;
        public var viewMatrix:ShaderConstM44;
        public var projectionMatrix:ShaderConstM44;
        public var screenMatrix:ShaderConstM42;
        public var time:ShaderConstFloat;
        public var lightDirection:ShaderConstVec4;
        public var cameraPosition:ShaderConstVec4;

        public var modelMatrix:ShaderConstM44;
        public var imageMatrix:ShaderConstM42;
        public var normalMatrix:ShaderConstM44;
        public var uvRect:ShaderConstVec4;
        public var bonesMatrices:ShaderConstM44Array;

        public static const CAMERA_MATRIX:String = "cameraMatrix";
        public static const VIEW_MATRIX:String = "viewMatrix";
        public static const PROJECTION_MATRIX:String = "projectionMatrix";
        public static const SCREEN_MATRIX:String = "screenMatrix";
        public static const TIME:String = "time";
        public static const LIGHT_DIRECTION:String = "lightDirection";
        public static const CAMERA_POSITION:String = "cameraPosition";

        public static const MODEL_MATRIX:String = "modelMatrix";
        public static const IMAGE_MATRIX:String = "imageMatrix";
        public static const NORMAL_MATRIX:String = "normalMatrix";
        public static const UV_RECT:String = "uvRect";
        public static const BONES_MATRICES:String = "bonesMatrices";

        public function AutoParams(_ctx:Context) {
            ctx = _ctx;
            globalAutoParams = new Dictionary();
            localAutoParams = new Dictionary();

            globalAutoParams[CAMERA_MATRIX] = cameraMatrix = new ShaderConstM44();
            globalAutoParams[VIEW_MATRIX] = viewMatrix = new ShaderConstM44();
            globalAutoParams[PROJECTION_MATRIX] = projectionMatrix = new ShaderConstM44();
            globalAutoParams[SCREEN_MATRIX] = screenMatrix = new ShaderConstM42();
            globalAutoParams[TIME] = time = new ShaderConstFloat();
            globalAutoParams[LIGHT_DIRECTION] = lightDirection = new ShaderConstVec4();
            globalAutoParams[CAMERA_POSITION] = cameraPosition = new ShaderConstVec4();

            localAutoParams[MODEL_MATRIX] = modelMatrix = new ShaderConstM44();
            localAutoParams[BONES_MATRICES] = bonesMatrices = new ShaderConstM44Array(32);
            localAutoParams[IMAGE_MATRIX] = imageMatrix = new ShaderConstM42();
            localAutoParams[NORMAL_MATRIX] = normalMatrix = new ShaderConstM44();
            localAutoParams[UV_RECT] = uvRect = new ShaderConstVec4();
        }

        public function updateGlobalAutoParamsValues():void {
            cameraMatrix.value = ctx.activeCamera.cameraMatrix;
            viewMatrix.value = ctx.activeCamera.viewMatrix;
            projectionMatrix.value = ctx.activeCamera.projectionMatrix;
            screenMatrix.value = ctx.screenMatrix;
            time.value = ctx.time;
            // cameraPosition.value = ?
        }

        public function setActiveLight(light:ILight):void {
            var lightPosition:Vector3D = light.getPosition();
            lightDirection.x = lightPosition.x;
            lightDirection.y = lightPosition.y;
            lightDirection.z = lightPosition.z;
            lightDirection.w = lightPosition.w;
            lightDirection.uploadValue(ctx.activeShader.vertexProgram, LIGHT_DIRECTION);
        }

        public function isAutoParam(name:String):Boolean {
            return name in globalAutoParams || name in localAutoParams;
        }
    }

}