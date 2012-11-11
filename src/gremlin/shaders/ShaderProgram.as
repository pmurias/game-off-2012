package gremlin.shaders {
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    import gremlin.core.Context;
    import gremlin.core.IRestorable;
    import gremlin.error.EAbstractClass;
    import gremlin.shaders.consts.IShaderConst;
    import gremlin.shaders.consts.ShaderConstVec4;

    /**
     * ...
     * @author mosowski
     */
    public class ShaderProgram {
        public var ctx:Context;
        public var params:Dictionary;
        public var type:String;
        public var autoParams:Vector.<String>;
        public var consts:Dictionary;

        public var source:String;
        public var assembly:ByteArray;
        public var jsonSource:Object;

        private static const _uploadAux256:ByteArray = new ByteArray();

        {
            _uploadAux256.endian = Endian.LITTLE_ENDIAN;
            _uploadAux256.writeFloat(0);
            _uploadAux256.writeFloat(0);
            _uploadAux256.writeFloat(0);
            _uploadAux256.writeFloat(0);
            _uploadAux256.writeFloat(0);
            _uploadAux256.writeFloat(0);
            _uploadAux256.writeFloat(0);
            _uploadAux256.writeFloat(0);


        }

        public function ShaderProgram(self:ShaderProgram, _ctx:Context) {
            if (self != this) {
                throw new EAbstractClass(ShaderProgram);
            } else {
                ctx = _ctx;
                params = new Dictionary();
                autoParams = new Vector.<String>();
                consts = new Dictionary();
            }
        }

        public function setSource(_source:String):void {
            source = _source;
        }

        public function fromJSON(json:Object):void {

            setSource(json.code);

            var i:int, param:Object;
            for (i = 0; i < json.params.length; ++i) {
                param = json.params[i];
                if (ctx.autoParams.isAutoParam(param.name)) {
                    addAutoParam(param.name, parseInt(param.register));
                } else {
                    addParam(param.name, parseInt(param.register));
                }
            }

            for (i = 0; i < json.consts.length; ++i) {
                param = json.consts[i];
                addConst(param.name, param.register, new ShaderConstVec4(param.values[0], param.values[1], param.values[2], param.values[3]));
            }
        }

        public function addParam(name:String, register:int):void {
            params[name] = register;
        }

        public function addAutoParam(name:String, register:int):void {
            addParam(name, register);
            autoParams.push(name);
        }

        public function addConst(name:String, register:int, value:IShaderConst):void {
            addParam(name, register);
            consts[name] = value;
        }

        public function setParamFloat(name:String, x:Number):void {
            _uploadAux256.position = 0;
            _uploadAux256.writeFloat(x);
            ctx.setProgramConstantFromByteArray(type, params[name], 1, _uploadAux256, 0);
        }

        public function setParamVec2(name:String, x:Number, y:Number):void {
            _uploadAux256.position = 0;
            _uploadAux256.writeFloat(x);
            _uploadAux256.writeFloat(y);
            ctx.setProgramConstantFromByteArray(type, params[name], 1, _uploadAux256, 0);
        }

        public function setParamVec3(name:String, x:Number, y:Number, z:Number):void {
            _uploadAux256.position = 0;
            _uploadAux256.writeFloat(x);
            _uploadAux256.writeFloat(y);
            _uploadAux256.writeFloat(z);
            ctx.setProgramConstantFromByteArray(type, params[name], 1, _uploadAux256, 0);
        }

        public function setParamVec4(name:String, x:Number, y:Number, z:Number, w:Number):void {
            _uploadAux256.position = 0;
            _uploadAux256.writeFloat(x);
            _uploadAux256.writeFloat(y);
            _uploadAux256.writeFloat(z);
            _uploadAux256.writeFloat(w);
            ctx.setProgramConstantFromByteArray(type, params[name], 1, _uploadAux256, 0);
        }

        public function setParamByteArray(name:String, data:ByteArray, offset:int = 0):void {
            ctx.setProgramConstantFromByteArray(type, params[name], data.length / 16, data, offset);
        }

        public function setParamVector(name:String, data:Vector.<Number>, numRegisters:int = -1):void {
            ctx.setProgramConstantFromVector(type, params[name], data, numRegisters);
        }

        public function setParamM44(name:String, m44:Matrix3D):void {
            ctx.setProgramConstantFromMatrix(type, params[name], m44);
        }

        public function setParamM44Array(name:String, array:Vector.<Matrix3D>):void {
            var register:int = params[name];
            for (var i:int = 0; i < array.length; ++i) {
                if (array[i] != null) {
                    ctx.setProgramConstantFromMatrix(type, register + i * 4, array[i]);
                }
            }
        }

        public function setParamM42(name:String, m42:Matrix):void {
            _uploadAux256.position = 0;
            _uploadAux256.writeFloat(m42.a);
            _uploadAux256.writeFloat(m42.c);
            _uploadAux256.writeFloat(0);
            _uploadAux256.writeFloat(m42.tx);
            _uploadAux256.writeFloat(m42.b);
            _uploadAux256.writeFloat(m42.d);
            _uploadAux256.writeFloat(0);
            _uploadAux256.writeFloat(m42.ty);
            ctx.setProgramConstantFromByteArray(type, params[name], 2, _uploadAux256, 0);
        }

        public function uploadGlobalAutoParams():void {
            for (var i:int = 0; i < autoParams.length; ++i) {
                var autoParam:IShaderConst = ctx.autoParams.globalAutoParams[autoParams[i]];
                if (autoParam) {
                    autoParam.uploadValue(this, autoParams[i]);
                }
            }
            for (var constName:String in consts) {
                var constVal:IShaderConst = consts[constName];
                constVal.uploadValue(this, constName);
            }
        }

        public function uploadLocalAutoParams():void {
            for (var i:int = 0; i < autoParams.length; ++i) {
                var autoParam:IShaderConst = ctx.autoParams.localAutoParams[autoParams[i]];
                if (autoParam) {
                    autoParam.uploadValue(this, autoParams[i]);
                }
            }
        }

        public function setAssembly(_assembly:ByteArray):void {
            assembly = new ByteArray();
            assembly.endian = Endian.LITTLE_ENDIAN;
            assembly.writeBytes(_assembly);
        }

        public function getAssembly():ByteArray {
            var assembler:AGALMiniAssembler = new AGALMiniAssembler();
            assembler.assemble(type, source);
            assembly = assembler.agalcode;
            return assembly;
        }
    }

}