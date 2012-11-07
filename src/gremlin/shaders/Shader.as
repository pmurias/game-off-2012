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
            vertexProgram = new VertexProgram(ctx);
            fragmentProgram = new FragmentProgram(ctx);
        }

        public function setSources(vertexProgramSource:String, fragmentProgramSource:String):void {
            vertexProgram.setSource(vertexProgramSource);
            fragmentProgram.setSource(fragmentProgramSource);

            build();
        }

        public function fromJSON(vertexProgramJSON:Object, fragmentProgramJSON:Object):void {
            vertexProgram.fromJSON(vertexProgramJSON);
            fragmentProgram.fromJSON(fragmentProgramJSON);

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
            if (program3d != null) {
                program3d.dispose();
            }

            program3d = ctx.createProgram(vertexProgram.getAssembly(), fragmentProgram.getAssembly());
        }

        public function restore():void {
            build();
        }
    }
}