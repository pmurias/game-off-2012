package gremlin.shaders {
    import flash.utils.Dictionary;
    import gremlin.core.Context;
    import gremlin.shaders.consts.ShaderConstFloat;
    import gremlin.shaders.consts.ShaderConstM44;

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

        public static const CAMERA_MATRIX:String = "cameraMatrix";
        public static const TIME:String = "time";
        public static const MODEL_MATRIX:String = "modelMatrix";

        public function AutoParams(_ctx:Context) {
            ctx = _ctx;
            globalAutoParams = new Dictionary();
            localAutoParams = new Dictionary();

            globalAutoParams[CAMERA_MATRIX] = cameraMatrix = new ShaderConstM44();
            globalAutoParams[TIME] = time = new ShaderConstFloat();

            localAutoParams[MODEL_MATRIX] = modelMatrix = new ShaderConstM44();
        }

        public function updateGlobalAutoParamsValues():void {
            cameraMatrix.value = ctx.activeCameraMatrix;
            time.value = ctx.time;
        }
    }

}