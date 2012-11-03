package gremlin.shaders {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
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
        public var time:ShaderConstFloat;
        public var modelMatrix:ShaderConstM44;
        public var bonesMatrices:ShaderConstM44Array;

        public static const CAMERA_MATRIX:String = "cameraMatrix";
        public static const TIME:String = "time";
        public static const MODEL_MATRIX:String = "modelMatrix";
        public static const BONES_MATRICES:String = "bonesMatrices";

        public function AutoParams(_ctx:Context) {
            ctx = _ctx;
            globalAutoParams = new Dictionary();
            localAutoParams = new Dictionary();

            globalAutoParams[CAMERA_MATRIX] = cameraMatrix = new ShaderConstM44();
            globalAutoParams[TIME] = time = new ShaderConstFloat();

            localAutoParams[MODEL_MATRIX] = modelMatrix = new ShaderConstM44();
            localAutoParams[BONES_MATRICES] = bonesMatrices = new ShaderConstM44Array(32);
        }

        public function updateGlobalAutoParamsValues():void {
            cameraMatrix.value = ctx.activeCameraMatrix;
            time.value = ctx.time;
        }
    }

}