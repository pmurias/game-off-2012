package gremlin.shaders {
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    import gremlin.core.Context;
    import gremlin.core.IRestorable;
    import gremlin.core.Key;
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
        public var autoParams:Vector.<Key>;
        public var consts:Dictionary;

        public var source:String;
        public var assembly:ByteArray;
        public var jsonSource:Object;

        private static const _uploadAux128:ByteArray = new ByteArray();

        {
            _uploadAux128.endian = Endian.LITTLE_ENDIAN;
            _uploadAux128.writeFloat(0);
            _uploadAux128.writeFloat(0);
            _uploadAux128.writeFloat(0);
            _uploadAux128.writeFloat(0);
        }

        public function ShaderProgram(self:ShaderProgram, _ctx:Context) {
            if (self != this) {
                throw new EAbstractClass(ShaderProgram);
            } else {
                ctx = _ctx;
                params = new Dictionary(true);
                autoParams = new Vector.<Key>();
                consts = new Dictionary(true);
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
                if (ctx.autoParams.isAutoParam(Key.of(param.name))) {
                    addAutoParam(Key.of(param.name), parseInt(param.register));
                } else {
                    addParam(Key.of(param.name), parseInt(param.register));
                }
            }

            for (i = 0; i < json.consts.length; ++i) {
                param = json.consts[i];
                addConst(Key.of(param.name), param.register, new ShaderConstVec4(param.values[0], param.values[1], param.values[2], param.values[3]));
            }
        }

        public function addParam(name:Key, register:int):void {
            params[name] = register;
        }

        public function addAutoParam(name:Key, register:int):void {
            addParam(name, register);
            autoParams.push(name);
        }

        public function addConst(name:Key, register:int, value:IShaderConst):void {
            addParam(name, register);
            consts[name] = value;
        }

        public function setParamFloat(name:Key, x:Number):void {
            if (params[name] != null) {
                _uploadAux128.position = 0;
                _uploadAux128.writeFloat(x);
                ctx.setProgramConstantFromByteArray(type, params[name], 1, _uploadAux128, 0);
            }
        }

        public function setParamVec2(name:Key, x:Number, y:Number):void {
            if (params[name] != null) {
                _uploadAux128.position = 0;
                _uploadAux128.writeFloat(x);
                _uploadAux128.writeFloat(y);
                ctx.setProgramConstantFromByteArray(type, params[name], 1, _uploadAux128, 0);
            }
        }

        public function setParamVec3(name:Key, x:Number, y:Number, z:Number):void {
            if (params[name] != null) {
                _uploadAux128.position = 0;
                _uploadAux128.writeFloat(x);
                _uploadAux128.writeFloat(y);
                _uploadAux128.writeFloat(z);
                ctx.setProgramConstantFromByteArray(type, params[name], 1, _uploadAux128, 0);
            }
        }

        public function setParamVec4(name:Key, x:Number, y:Number, z:Number, w:Number):void {
            if (params[name] != null) {
                _uploadAux128.position = 0;
                _uploadAux128.writeFloat(x);
                _uploadAux128.writeFloat(y);
                _uploadAux128.writeFloat(z);
                _uploadAux128.writeFloat(w);
                ctx.setProgramConstantFromByteArray(type, params[name], 1, _uploadAux128, 0);
            }
        }

        public function setParamByteArray(name:Key, data:ByteArray, offset:int = 0):void {
            if (params[name] != null) {
                ctx.setProgramConstantFromByteArray(type, params[name], data.length / 16, data, offset);
            }
        }

        public function setParamVector(name:Key, data:Vector.<Number>, numRegisters:int = -1):void {
            if (params[name] != null) {
                ctx.setProgramConstantFromVector(type, params[name], data, numRegisters);
            }
        }

        public function setParamM44(name:Key, m44:Matrix3D):void {
            if (params[name] != null) {
                ctx.setProgramConstantFromMatrix(type, params[name], m44);
            }
        }

        public function setParamM44Array(name:Key, array:Vector.<Matrix3D>):void {
            if (params[name] != null) {
                var register:int = params[name];
                for (var i:int = 0; i < array.length; ++i) {
                    if (array[i] != null) {
                        ctx.setProgramConstantFromMatrix(type, register + i * 4, array[i]);
                    }
                }
            }
        }

        public function setParamM42(name:Key, m42:Matrix):void {
            throw "Not implemented yet."
        }

        public function uploadGlobalAutoParams():void {
            for (var i:int = 0; i < autoParams.length; ++i) {
                var autoParam:IShaderConst = ctx.autoParams.globalAutoParams[autoParams[i]];
                if (autoParam) {
                    autoParam.uploadValue(this, autoParams[i]);
                }
            }
            for (var constName:Object in consts) {
                var constVal:IShaderConst = consts[constName];
                constVal.uploadValue(this, constName as Key);
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