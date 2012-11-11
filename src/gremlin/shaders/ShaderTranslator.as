package gremlin.shaders {
    import flash.utils.Dictionary;

    /**
     * ...
     * @author mosowski
     */
    public class ShaderTranslator {
        private var src:String;
        private var tp:int;
        private var tokens:Vector.<Token>;
        private var pp:int;

        private var freeConstRegister:int;
        private var freeAttrRegister:int;
        private var freeTempRegister:int;
        private var freeSamplerRegister:int;

        private var context:Dictionary;
        private var numericals:Vector.<VariableNumerical>;
        private var instructions:Vector.<Instruction>;

        public static const VERTEX:String = "vertex";
        public static const FRAGMENT:String = "fragment";
		
		private static var instructionTypeByFunction:Dictionary;
        private static var typeClassByName:Dictionary;

        public function ShaderTranslator() {
            tp = 0;
			if (instructionTypeByFunction == null) {
				instructionTypeByFunction = new Dictionary();
				instructionTypeByFunction["sqrt"] = InstructionSqrt;
				instructionTypeByFunction["tex2D"] = InstructionTex;
				instructionTypeByFunction["kill"] = InstructionKill;
				instructionTypeByFunction["sin"] = InstructionSin;
				instructionTypeByFunction["cos"] = InstructionCos;
                instructionTypeByFunction["dot4"] = InstructionDot4;
			}
            if (typeClassByName == null) {
                typeClassByName = new Dictionary();
                typeClassByName["float"] = TypeFloat;
                typeClassByName["vec2"] = TypeVec2;
                typeClassByName["vec3"] = TypeVec3;
                typeClassByName["vec4"] = TypeVec4;
                typeClassByName["m44"] = TypeM44;
                typeClassByName["m42"] = TypeM42;
            }
        }

        public function translate(_src:String, mode:String):Object {
            src = _src;
            context = new Dictionary();
            numericals = new Vector.<VariableNumerical>();
            instructions = new Vector.<Instruction>();
            freeConstRegister = 0;
            freeAttrRegister = 0;
            freeTempRegister = 0;
            freeSamplerRegister = 0;
            for (var i:int = 0; i < 8; ++i) {
                context["varying" + i] = new VariableVarying();
                context["varying" + i].registerIndex = i;
            }
            context["out"] = new VariableOut();

            tokens = new Vector.<Token>();
            tokenize();
            pp = 0;
            while (pp != tokens.length) {
                if (tokens[pp].valueStr == "param") {
                    pp++;
                    var paramType:Type = parseType();
                    var param:VariableParam = new VariableParam();
                    param.name = tokens[pp++].valueStr;
                    param.registerIndex = freeConstRegister;
                    param.type = paramType;
                    freeConstRegister += paramType.size;
                    context[param.name] = param;
                } else if (tokens[pp].valueStr == "attr") {
                    pp++;
                    var attrType:Type = parseType();
                    var attr:VariableAttr = new VariableAttr();
                    attr.name = tokens[pp++].valueStr;
                    attr.registerIndex = freeAttrRegister;
                    attr.type = attrType;
                    freeAttrRegister += attrType.size;
                    context[attr.name] = attr;
                } else if (tokens[pp].valueStr == "sampler") {
                    pp++;
                    var sampler:VariableSampler = new VariableSampler();
                    sampler.name = tokens[pp++].valueStr;
                    sampler.registerIndex = freeSamplerRegister++;
                    context[sampler.name] = sampler;
                } else {
                    var instruction:Instruction = null;
                    var outOp:Operand = parseOperand(true);
                    if (tokens[pp].valueStr == "=") {
                        pp++;
                        if (tokens[pp].valueStr in instructionTypeByFunction) {
							instruction = new instructionTypeByFunction[tokens[pp++].valueStr]();
							instruction.dest = outOp;
							parseArguments(instruction);
                        } else {
                            var src1Op:Operand = parseOperand();
                            if (pp < tokens.length && tokens[pp] is TokenSymbol) {
                                var operator:String = tokens[pp].valueStr;
                                pp++;
                                if (operator == ">") {
                                    if (tokens[pp++].valueStr != "=") {
                                        throw "Only operator <= is permited.";
                                    }
                                }
                                var src2Op:Operand = parseOperand();
                                if (operator == "+") {
                                    instruction = new InstructionAdd();
                                } else if (operator == "-") {
                                    instruction = new InstructionSub();
                                } else if (operator == "*") {
                                    instruction = new InstructionMul();
                                } else if (operator == "/") {
                                    instruction = new InstructionDiv();
                                } else if (operator == "<") {
                                    instruction = new InstructionSlt();
                                }

                                instruction.dest = outOp;
                                instruction.src1 = src1Op;
                                instruction.src2 = src2Op;
                            } else {
                                instruction = new InstructionMov();
                                instruction.dest = outOp;
                                instruction.src1 = src1Op;
                            }
                        }
                        instructions.push(instruction);
                    }
                }
            }

            var code:String = "";
            for (i = 0; i < instructions.length; ++i) {
                code += instructions[i].getCode(mode) + "\n";
            }
            trace(code);
            return getJSON(code, mode);
        }

        private function getJSON(code:String, mode:String):Object {
            var json:Object = { };
            json.params = [];
            json.consts = [];
            if (mode == VERTEX) {
                json.attrs = [];
            } else {
                json.samplers = [];
            }
            json.code = code;
            json.type = mode;

            for (var name:String in context) {
                var variable:Variable = context[name];
                if (variable is VariableAttr) {
                    json.attrs.push( { name:variable.name, register:variable.registerIndex } );
                } else if (variable is VariableParam) {
                    json.params.push( { name:variable.name, register:variable.registerIndex } );
                } else if (variable is VariableSampler) {
                    json.samplers.push( { name: variable.name, register:variable.registerIndex } );
                }
            }
            for (var i:int = 0; i < numericals.length; ++i) {
                var numerical:VariableNumerical = numericals[i];
                json.consts.push( { name:"_constRegister" + numerical.registerIndex, register:numerical.registerIndex, values: [numerical.values[0], numerical.values[1], numerical.values[2], numerical.values[3]] } );
            }
            return json;
        }
		
		private function parseArguments(instruction:Instruction):void {
			pp++; // (
			instruction.src1 = parseOperand();
			if (tokens[pp++].valueStr == ",") {
				instruction.src2 = parseOperand();
				pp++; // )
			}
		}

        private function parseOperand(output:Boolean = false, isOffset:Boolean = false):Operand {
            var varName:String = tokens[pp].valueStr;
            if (varName == "(" || tokens[pp] is TokenNumber) {
                if (output == false) {
                    return parseNumericalConstant(isOffset);
                } else {
                    throw "LValue required.";
                }
            } else {
                pp++;
                var variable:Variable = context[varName];
                if (variable == null) {
                    variable = new VariableTemp();
                    variable.name = varName;
                    variable.registerIndex = freeTempRegister;
                    freeTempRegister++;
                    context[varName] = variable;
                }
                var operand:Operand = new Operand();
                operand.variable = variable;
                if (pp < tokens.length && tokens[pp].valueStr == "[") {
                    operand.offset = parseOffsetOperand();
                } else {
                    operand.offset = new RegisterOffset();
                }

                if (variable is VariableSampler) {
                    operand.mask = "";
                } else {
                    if (pp < tokens.length && tokens[pp].valueStr == ".") {
                        pp++;
                        operand.mask = tokens[pp].valueStr;
                        pp++;
                    } else {
                        operand.mask = "";
                    }
                }
            }
            return operand;
        }

        private function parseOffsetOperand():RegisterOffset {
            pp++; // [
            var operand:Operand = parseOperand(false, true);
            pp++; // ]
            if (operand.variable is VariableNumerical) {
                var offsetConst:RegisterOffsetConst = new RegisterOffsetConst();
                offsetConst.offset = (operand.variable as VariableNumerical).values[0];
                return offsetConst;
            } else {
                var offsetVar:RegisterOffsetVar = new RegisterOffsetVar();
                offsetVar.operand = operand;
                return offsetVar;
            }
        }

        private function parseNumericalConstant(isOffset:Boolean = false):Operand {
            var values:Vector.<Number> = new Vector.<Number>();
            if (tokens[pp] is TokenNumber) {
                values.push(tokens[pp].valueNum);
                pp++;
            } else {
                pp++; // skip (
                while (tokens[pp].valueStr != ")") {
                    values.push(tokens[pp].valueNum);
                    pp++;
                    if (tokens[pp].valueStr == ",") {
                        pp++;
                    }
                }
                pp++; // skip )
            }
            var variable:VariableNumerical = new VariableNumerical();
            for (var i:int = 0 ; i < values.length; ++i) {
                variable.values[i] = values[i];
            }
            if (isOffset == false) {
                variable.registerIndex = freeConstRegister;
                freeConstRegister++;
                numericals.push(variable);
            }
            var operand:Operand = new Operand();
            operand.variable = variable;
            operand.mask = "xyzw".substr(0, values.length);
            return operand;
        }

        private function parseType():Type {
            var typeName:String = tokens[pp].valueStr;
            pp++;
            var baseType:Type = new typeClassByName[typeName]();
            if (tokens[pp].valueStr == "[") {
                pp++;
                var arrayLength:int =  tokens[pp++].valueNum;
                var arrayType:TypeArray = new TypeArray(baseType, arrayLength);
                pp++; // ]
                return arrayType;
            } else {
                return baseType;
            }
        }


        private function tokenize():void {
            tp = 0;
            skipWhitespace();
            while (tp < src.length) {
                tokens.push(getNextToken());
                skipWhitespace();
            }
        }

        private function getNextToken():Token {
            skipWhitespace();
            var t:Token;
            if (tp < src.length) {
                if ( (isDigit(src.charAt(tp)))
                    || (tp+1 < src.length && src.charAt(tp) == "." && isDigit(src.charAt(tp+1))) ) {
                    t = new TokenNumber();
                    t.valueNum = parseNumber();
                } else if (isAlpha(src.charAt(tp))) {
                    t = new TokenWord();
                    t.valueStr = parseWord();
                } else if (src.charAt(tp) == '"') {
                    t =  new TokenString();
                    t.valueStr = parseString();
                } else {
                    t = new TokenSymbol();
                    t.valueStr = parseSymbol();
                }
            }
            return t;
        }

        private function skipWhitespace():void {
            var char:String;
            while (tp < src.length && isWhitespace(src.charAt(tp))) {
                tp++;
            }
            if (tp + 1 < src.length) {
                if (src.substr(tp, 2) == "//") {
                    skipLineComment();
                } else if (src.substr(tp, 2) == "/*") {
                    skipBlockComment();
                }
            }
        }

        private function isWhitespace(s:String):Boolean {
            return s == " " || s == "\n" || s == "\t" || s == "\r";
        }

        private function isDigit(s:String):Boolean {
            return s.charCodeAt(0) >= "0".charCodeAt(0) && s.charCodeAt(0) <= "9".charCodeAt(0);
        }

        private function isAlpha(s:String):Boolean {
            return s.charCodeAt(0) >= "a".charCodeAt(0) && s.charCodeAt(0) <= "z".charCodeAt(0)
                || s.charCodeAt(0) >= "A".charCodeAt(0) && s.charCodeAt(0) <= "Z".charCodeAt(0)
                || s.charAt(0) == "_";
        }

        private function parseNumber():Number {
            var n:String = "";
            var dc:int = 0;
            while (tp < src.length && (isDigit(src.charAt(tp)) || (src.charAt(tp) == "." && dc == 0 && ++dc == 1))) {
                n += src.charAt(tp++);
            }
            if (isAlpha(src.charAt(tp))) {
                throw "Bad syntax";
            }
            return parseFloat(n);
        }

        private function parseWord():String {
            var w:String = "";
            while (isAlpha(src.charAt(tp)) || isDigit(src.charAt(tp))) {
                w += src.charAt(tp++);
            }
            return w;
        }

        private function parseString():String {
            var s:String = "";
            var escaped:Boolean = false;
            tp++;
            while (src.charAt(tp) != '"' && !escaped) {
                escaped = false;
                if (src.charAt(tp) == '\\') {
                    escaped=true;
                }
                s += src.charAt(tp++);
            }
            tp++;
            return s;
        }

        private function parseSymbol():String {
            //if (tp + 1 < src.length) {
                //var op:String = src.substr(tp, 2);
                //if (opDblChar.indexOf(op) != -1) {
                    //tp += 2;
                    //return op;
                //}
            //}
            return src.charAt(tp++);
        }

        private function skipLineComment():void {
            while (tp < src.length && src.charAt(tp) != '\n') {
                tp++;
            }
            tp++;
            skipWhitespace();
        }

        private function skipBlockComment():void {
            while (tp + 1 < src.length && (src.charAt(tp) != '*' || src.charAt(tp + 1) != '/')) {
                tp++;
            }
            tp += 2;
            skipWhitespace();
        }
    }
}

import gremlin.shaders.ShaderTranslator;

class Token {
    public var valueStr:String;
    public var valueNum:Number;

    public function toString():String {
        return valueStr != null ? valueStr : valueNum.toString();
    }
}

class TokenNumber extends Token {
}

class TokenWord extends Token {
}

class TokenString extends Token {
}

class TokenSymbol extends Token {
}

class Operand {
    public var variable:Variable;
    public var mask:String;
    public var offset:RegisterOffset;

    public function getCode(mode:String):String {
        return variable.getCode(mode, offset) + (mask != "" ? "." + mask : "");
    }
}

class Variable {
    public var name:String;
    public var registerIndex:int;
    public var type:Type;

    public function getCode(mode:String, offset:RegisterOffset):String {
        return "";
    }
}

class VariableAttr extends Variable {
    override public function getCode(mode:String, offset:RegisterOffset):String {
        return offset.getOffsetedRegisterCode(mode, "va", registerIndex);
    }
}

class VariableParam extends Variable {
    override public function getCode(mode:String, offset:RegisterOffset):String {
        return offset.getOffsetedRegisterCode(mode, mode == ShaderTranslator.VERTEX ? "vc" : "fc", registerIndex);
    }
}

class VariableTemp extends Variable {
    override public function getCode(mode:String, offset:RegisterOffset):String {
        return offset.getOffsetedRegisterCode(mode, mode == ShaderTranslator.VERTEX ? "vt" : "ft", registerIndex);
    }
}

class VariableVarying extends Variable {
    override public function getCode(mode:String, offset:RegisterOffset):String {
        return offset.getOffsetedRegisterCode(mode, "v", registerIndex);
    }
}

class VariableSampler extends Variable {
    override public function getCode(mode:String, offset:RegisterOffset):String {
       return offset.getOffsetedRegisterCode(mode, "fs", registerIndex);
    }
}

class VariableNumerical extends Variable {
    public var values:Vector.<Number>;
    public function VariableNumerical() {
        values = new Vector.<Number>(4, true);
        values[0] = values[1] = values[2] = values[3] = 0;
    }
    override public function getCode(mode:String, offset:RegisterOffset):String {
        return (mode == ShaderTranslator.VERTEX ? "vc" : "fc") + registerIndex;
    }
}
class VariableOut extends Variable {
    override public function getCode(mode:String, offset:RegisterOffset):String {
        return mode == ShaderTranslator.VERTEX ? "op" : "oc";
    }
}

class RegisterOffset {
    public function getOffsetedRegisterCode(mode:String, registerCode:String,index:int):String {
        return registerCode + index.toString();
    }
}

class RegisterOffsetConst extends RegisterOffset {
    public var offset:int;
    override public function getOffsetedRegisterCode(mode:String, registerCode:String, index:int):String {
        return registerCode + (index + offset).toString();
    }
}

class RegisterOffsetVar extends RegisterOffset {
    public var operand:Operand;
    override public function getOffsetedRegisterCode(mode:String, registerCode:String, index:int):String {
        return registerCode + "[" + operand.getCode(mode) +"]";
    }
}

class Type {
    public var size:int;
}

class TypeFloat extends Type {
    public function TypeFloat() {
        size = 1;
    }
}
class TypeVec2 extends Type {
    public function TypeVec2() {
        size = 1;
    }
}
class TypeVec3 extends Type {
    public function TypeVec3() {
        size = 1;
    }
}
class TypeVec4 extends Type {
    public function TypeVec4() {
        size = 1;
    }
}
class TypeM44 extends Type {
    public function TypeM44() {
        size = 4;
    }
}
class TypeM42 extends Type {
    public function TypeM42() {
        size = 2;
    }
}

class TypeArray extends Type {
    public var type:Type;
    public var length:int;
    public function TypeArray(_type:Type, _length:int) {
        type = _type;
        length = _length;
        size = _type.size * length;
    }
}

class Instruction {
    public var dest:Operand;
    public var src1:Operand;
    public var src2:Operand;

    public function getInstructionName():String {
        return "";
    }
    public function getCode(mode:String):String {
        return getInstructionName() +
			(dest != null ? " " + dest.getCode(mode) : "") +
			(src1 != null ? ", " +src1.getCode(mode) : "") +
			(src2 != null ? ", " +src2.getCode(mode) : "");
    }
}

class InstructionAdd extends Instruction {
    override public function getInstructionName():String {
        return "add";
    }
}
class InstructionSub extends Instruction {
    override public function getInstructionName():String {
        return "sub";
    }
}
class InstructionMul extends Instruction {
    override public function getCode(mode:String):String {
        if (src1.variable.type is TypeM44 || src2.variable.type is TypeM44
        || (src1.variable.type is TypeArray && (src1.variable.type as TypeArray).type is TypeM44)) {
            src1.mask = "";
            return "m44 " + dest.getCode(mode) + ", " + src2.getCode(mode) +", " + src1.getCode(mode);
        } else {
            return super.getCode(mode)
        }
    }

    override public function getInstructionName():String {
        return "mul";
    }
}
class InstructionDiv extends Instruction {
    override public function getInstructionName():String {
        return "div";
    }
}
class InstructionMov extends Instruction {
    override public function getInstructionName():String {
        return "mov";
    }
}
class InstructionSlt extends Instruction {
    override public function getInstructionName():String {
        return "slt";
    }
}
class InstructionSge extends Instruction {
    override public function getInstructionName():String {
        return "sge";
    }
}

class InstructionKill extends Instruction {
    override public function getInstructionName():String {
        return "kil";
    }
}

class InstructionSin extends Instruction {
    override public function getInstructionName():String {
        return "sin";
    }
}

class InstructionCos extends Instruction {
    override public function getInstructionName():String {
        return "cos";
    }
}

class InstructionSqrt extends Instruction {
    override public function getInstructionName():String {
        return "sqt";
    }
}

class InstructionDot4 extends Instruction {
    override public function getInstructionName():String {
        return "dp4";
    }
}

class InstructionTex extends Instruction {
    override public function getCode(mode:String):String {
        return "tex " + dest.getCode(mode) + ", " + src1.getCode(mode) + ", " + src2.getCode(mode) + " <2d, repeat, linear>";
    }

}