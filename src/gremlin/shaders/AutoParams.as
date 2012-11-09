package gremlin.shaders {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.core.Key;
    import gremlin.shaders.consts.ShaderConstFloat;
    import gremlin.shaders.consts.ShaderConstM44;
    import gremlin.shaders.consts.ShaderConstM44Array;

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
        public var time:ShaderConstFloat;
        public var modelMatrix:ShaderConstM44;
        public var bonesMatrices:ShaderConstM44Array;

        public static const CAMERA_MATRIX:Key = Key.of("cameraMatrix");
        public static const VIEW_MATRIX:Key = Key.of("viewMatrix");
        public static const PROJECTION_MATRIX:Key = Key.of("projectionMatrix");
        public static const TIME:Key = Key.of("time");
        public static const MODEL_MATRIX:Key = Key.of("modelMatrix");
        public static const BONES_MATRICES:Key = Key.of("bonesMatrices");

        public function AutoParams(_ctx:Context) {
            ctx = _ctx;
            globalAutoParams = new Dictionary(true);
            localAutoParams = new Dictionary(true);

            globalAutoParams[CAMERA_MATRIX] = cameraMatrix = new ShaderConstM44();
            globalAutoParams[VIEW_MATRIX] = viewMatrix = new ShaderConstM44();
            globalAutoParams[PROJECTION_MATRIX] = projectionMatrix = new ShaderConstM44();
            globalAutoParams[TIME] = time = new ShaderConstFloat();

            localAutoParams[MODEL_MATRIX] = modelMatrix = new ShaderConstM44();
            localAutoParams[BONES_MATRICES] = bonesMatrices = new ShaderConstM44Array(32);
        }

        public function updateGlobalAutoParamsValues():void {
            cameraMatrix.value = ctx.activeCamera.cameraMatrix;
            viewMatrix.value = ctx.activeCamera.viewMatrix;
            projectionMatrix.value = ctx.activeCamera.projectionMatrix;
            time.value = ctx.time;
        }

        public function isAutoParam(name:Key):Boolean {
            return name in globalAutoParams || name in localAutoParams;
        }
    }

}