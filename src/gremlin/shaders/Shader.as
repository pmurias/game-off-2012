package gremlin.shaders {
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Program3D;
    import gremlin.core.Context;
    import gremlin.core.IRestorable;

    /**
     * ...
     * @author mosowski
     */
    public class Shader implements IRestorable {
        public var ctx:Context;
        public var program3d:Program3D;
        public var vertexProgram:VertexProgram;
        public var fragmentProgram:FragmentProgram;

        public function Shader(_ctx:Context) {
            ctx = _ctx;
            ctx.addRestorableResource(this);
        }

        public function setSources(vertexProgramSource:String, fragmentProgramSource:String):void {
            vertexProgram = new VertexProgram(ctx);
            vertexProgram.setSource(vertexProgramSource);
            fragmentProgram = new FragmentProgram(ctx);
            fragmentProgram.setSource(fragmentProgramSource);

            if (program3d != null) {
                program3d.dispose();
            }

            build();
        }

        public function activate():void {
            ctx.setProgram(program3d);
            ctx.activeShader = this;
            vertexProgram.uploadGlobalAutoParams();
            fragmentProgram.uploadGlobalAutoParams();
        }

        public function uploadLocalAutoParams():void {
            vertexProgram.uploadLocalAutoParams();
            fragmentProgram.uploadLocalAutoParams();
        }

        public function build():void {
            program3d = ctx.createProgram(vertexProgram.getAssembly(), fragmentProgram.getAssembly());
        }

        public function restore():void {
            build();
        }
    }
}