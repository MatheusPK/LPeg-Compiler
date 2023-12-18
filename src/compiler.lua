local grammar = require "src/grammar"
local pt = require "src/pt"

local Compiler = {
  tempCount = 0,
  vars = {},
  funcs = {},
  currentFunc = {name = ""}
}

-- MARK: Constants
local types = {
  ["double"] = "double",
  ["int"] = "int",
  ["void"] = "void",
  ["array"] = "array"
}

local typeToLLVM = {
  [types.int] = "i32",
  [types.double] = "double",
  [types.void] = "void",
  [types.array] = "ptr"
}

local typeSize = {
  [types.int] = 4,
  [types.double] = 8,
  [types.array] = 8
}

local castOp = {
  [types.int] = {
    [types.double] = "sitofp"
  },
  [types.double] = {
    [types.int] = "fptosi"
  }
}

local binAOps = {
  ["+"] = {
    [types.int] = "add",
    [types.double] = "fadd"
  },
  ["-"] = {
    [types.int] = "sub",
    [types.double] = "fsub"
  },
  ["*"] = {
    [types.int] = "mul",
    [types.double] = "fmul"
  },
  ["/"] = {
    [types.int] = "sdiv",
    [types.double] = "fdiv"
  }
}

local binCOps = {
  [">="] = {
    [types.int] = "sge",
    [types.double] = "oge"
  },
  ["<="] = {
    [types.int] = "sle",
    [types.double] = "ole"
  },
  [">"] = {
    [types.int] = "sgt",
    [types.double] = "ogt"
  },
  ["<"] = {
    [types.int] = "slt",
    [types.double] = "olt"
  },
  ["=="] = {
    [types.int] = "eq",
    [types.double] = "oeq"
  },
  ["~="] = {
    [types.int] = "ne",
    [types.double] = "une"
  }
}

-- MARK: Helpers Functions
function Compiler:newTemp()
  local temp = string.format("%%T%d", self.tempCount)
  self.tempCount = self.tempCount + 1
  return temp
end

function Compiler:newLabel()
  local temp = string.format("L%d", self.tempCount)
  self.tempCount = self.tempCount + 1
  return temp
end

function Compiler.emit(content, ...)
  local finalContent = ... and string.format(content, ...) or content
  io.write(finalContent .. "\n")
end

function Compiler.error(error, ...)
  local finalContent = ... and string.format(error, ...) or error
  io.stderr:write(finalContent .. "\n")
  os.exit(1)
end

function Compiler:codeLabel(label)
  self.emit("%s:", label)
end

function Compiler:codeJmp(label)
  self.emit("br label %%%s", label)
end

function Compiler:codeCond(exp, Ltrue, Lfalse)
  local exp = self:codeExp(exp)
  local aux = self:newTemp()
  self.emit("%s = icmp ne i32 %s, 0", aux, exp.value)
  self.emit("br i1 %s, label %%%s, label %%%s", aux, Ltrue, Lfalse)
end

function Compiler:implicitCastBinarithExp(exp1, exp2, targetType)
  local exp1RawType = self:getRawType(exp1.type) 
  local exp2RawType = self:getRawType(exp2.type)
  local castedExp1 = exp1
  local castedExp2 = exp2

  if exp1RawType == targetType then
    castedExp2.value = self:codeCast(exp2.value, exp2.type, exp1.type)
    castedExp2.type = exp1.type
  elseif exp2RawType == targetType then
    castedExp1.value = self:codeCast(exp1.value, exp1.type, exp2.type)
    castedExp1.type = exp2.type
  else
    self.error("Implicit Cast failed")
  end
  
  return castedExp1, castedExp2
end

function Compiler:implicitCastExpToInt(exp)
  local castedExp = exp
  local targetType = {tag = "primitive type", type = types.int}
  castedExp.value = self:codeCast(exp.value, exp.type, targetType)
  castedExp.type = targetType
  return castedExp
end

function Compiler:implicitCastExpToDouble(exp)
  local castedExp = exp
  local targetType = {tag = "primitive type", type = types.double}
  castedExp.value = self:codeCast(exp.value, exp.type, targetType)
  castedExp.type = targetType
  return castedExp
end

function Compiler:codeCast(value, baseType, targetType)
  local res = self:newTemp()
  local baseRawType = self:getRawType(baseType)
  local targetRawType = self:getRawType(targetType)
  self.emit("%s = %s %s %s to %s", res, castOp[baseRawType][targetRawType], typeToLLVM[baseRawType], value, typeToLLVM[targetRawType])
  return res
end

function Compiler:typeExists(type)
  if type.tag == "primitive type" then
    return types[type.type] ~= nil
  elseif type.tag == "array type" then
    return self:typeExists(type.nestedType)
  else
    return false
  end
end

function Compiler:typeIsEqual(typeA, typeB)
  if typeA.tag ~= typeB.tag then return false end

  if typeA.tag == "primitive type" then
    return typeA.type == typeB.type
  elseif typeA.tag == "array type" then
    return self:typeIsEqual(typeA.nestedType, typeB.nestedType)
  end

  return false
end

function Compiler:getRawType(type)
  if type.tag == "primitive type" then
    return type.type
  elseif type.tag == "array type" then
    return types.array
  else
    self.error("'%s' type not yet implemented", type.tag)
  end
end

function Compiler:strType(type)
  if type.tag == "primitive type" then
    return type.type
  elseif type.tag == "array type" then
    return string.format("[%s]", self:strType(type.nestedType))
  else
    return "UNKNOW"
  end
end

function Compiler:createVar(id, type, reg)
  self.vars[#self.vars + 1] = {id = id, type = type, reg = reg}
end

function Compiler:codeEmptyVar(id, reg, varType)
  if not self:typeExists(varType) then
    self.error("declaring a var with type '%s' that does not exists", self:strType(expType))
  end

  local varRawType = self:getRawType(varType)
  self.emit("%s = alloca %s", reg, typeToLLVM[varRawType])
  self:createVar(id, varType, reg)
end

function Compiler:codeInc(res, type, varExpReg, varAddressReg)
  local rawType = self:getRawType(type)

  if rawType ~= types.int and rawType ~= types.double then
    self.error("Attempt to increment a '%s' value", self:strType(type))
  end

  local addOp = binAOps["+"][rawType]

  self.emit("%s = %s %s %s, 1", res, addOp, typeToLLVM[rawType], varExpReg)
  self.emit("store %s %s, ptr %s\n", typeToLLVM[rawType], res, varAddressReg)
end

function Compiler:codeDec(res, type, varExpReg, varAddressReg)
  local rawType = self:getRawType(type)

  if rawType ~= types.int and rawType ~= types.double then
    self.error("Attempt to decrement a '%s' value", self:strType(type))
  end

  local subOp = binAOps["-"][rawType]

  self.emit("%s = %s %s %s, 1", res, subOp, typeToLLVM[rawType], varExpReg)
  self.emit("store %s %s, ptr %s\n", typeToLLVM[rawType], res, varAddressReg)
end

function Compiler:codeVar(id, reg, exp, varType)
  if not self:typeExists(varType) then
    self.error("declaring a var with type '%s' that does not exists", self:strType(exp.type))
  end

  local expRawType = self:getRawType(exp.type)
  local varRawType = self:getRawType(varType)

  if not self:typeIsEqual(exp.type, varType) then
    if varRawType == types.double and expRawType == types.int then
      exp = self:implicitCastExpToDouble(exp)
    elseif varRawType == types.int and expRawType == types.double then
      exp = self:implicitCastExpToInt(exp)
    else
      self.error("code var: var type and expression type mismatch expression type '%s', var type '%s'", self:strType(exp.type), self:strType(varType))
    end
  end

  self.emit("%s = alloca %s", reg, typeToLLVM[expRawType])
  self.emit("store %s %s, ptr %s", typeToLLVM[varRawType], exp.value, reg)
  self:createVar(id, varType, reg)
end

function Compiler:codeMalloc(reg, type, arraySize)
  local typeSizeInBytes = 0

  if type.tag == "array type" then
    typeSizeInBytes = typeSize[types.array]
  elseif type.tag == "primitive type" then
    typeSizeInBytes = typeSize[type.type]
  else
    self.error("Type '%s' not yet implemented", self:strType(type))
  end

  local mallocSize = self:newTemp()
  self.emit("%s = mul i32 %s, %s", mallocSize, typeSizeInBytes, arraySize)
  local i64MallocSize = self:newTemp()
  self.emit("%s = sext i32 %s to i64", i64MallocSize, mallocSize)

  self.emit("%s = call ptr @malloc(i64 %s)", reg, i64MallocSize)
end

function Compiler:codeGetElementPtr(res, type, var, index)
  local i64Index = self:newTemp()
  self.emit("%s = sext i32 %s to i64", i64Index, index)
  self.emit("%s = getelementptr inbounds %s, ptr %s, i64 %s", res, type, var, i64Index)
end

function Compiler:findVar(id)
  for i = #self.vars, 1, -1 do
    if self.vars[i].id == id then
      return {reg = self.vars[i].reg, type = self.vars[i].type}
    end
  end
  self.error("Variable '%s' not found", id)  
end

function Compiler:isValidReturnType(retType)
  local expectedReturnType = self.funcs[self.currentFunc.name].retType
  return self:typeIsEqual(expectedReturnType, retType), expectedReturnType
end

function Compiler:exp(value, type)
  return {value = value, type = type}
end

-- MARK: Expression Functions
function Compiler:codeExp(exp)
  local tag = exp.tag
  if tag == "number int" then
    return self:codeExpNumberInt(exp)
  elseif tag == "number double" then
    return self:codeExpNumberDouble(exp)
  elseif tag == "varExp" then
    return self:codeExpVar(exp)
  elseif tag == "indexed" then 
    return self:codeExpIndexed(exp)
  elseif tag == "simpleVar" then
    return self:codeExpSimpleVar(exp)
  elseif tag == "unarith" then
    return self:codeExpUnarith(exp)
  elseif tag == "binarith" then
    return self:codeExpBinarith(exp)
  elseif tag == "binarith comp" then
    return self:codeExpBinarithComp(exp)
  elseif tag == "call" then
    return self:codeExpCall(exp)
  elseif tag == "cast" then
    return self:codeExpCast(exp)
  elseif tag == "new" then
    return self:codeExpNew(exp)
  elseif tag == "preInc" then
    return self:codeExpPreInc(exp)
  elseif tag == "postInc" then
    return self:codeExpPostInc(exp)
  elseif tag == "preDec" then
    return self:codeExpPreDec(exp)
  elseif tag == "postDec" then
    return self:codeExpPostDec(exp)
  else
    self.error("'%s': expression not yet implemented", tag)
  end
end

function Compiler:codeExpNumberInt(exp)
  return self:exp(exp.num, { tag = "primitive type", type = types.int})
end

function Compiler:codeExpNumberDouble(exp)
  return self:exp(exp.num, {tag = "primitive type", type = types.double})
end

function Compiler:codeExpSimpleVar(exp)
  local var = self:findVar(exp.id)
  return self:exp(var.reg, var.type)
end

function Compiler:codeExpVar(exp)
  local varAddress = self:codeExp(exp.var)
  local varAddressRawType = self:getRawType(varAddress.type)
  
  local varValue = self:newTemp()
  self.emit("%s = load %s, ptr %s", varValue, typeToLLVM[varAddressRawType], varAddress.value)

  return self:exp(varValue, varAddress.type)
end

function Compiler:codeExpIndexed(exp)
  local array = self:codeExp(exp.e)
  local arrayRawType = self:getRawType(array.type)
  local index = self:codeExp(exp.index)
  local indexRawType = self:getRawType(index.type)

  if arrayRawType ~= types.array then
    self.error("attempt to index a '%s' value", self:strType(array.type))
  end

  if indexRawType ~= types.int then
    self.error("index must be int, but is '%s'", self:strType(index.type))
  end

  local res = self:newTemp()
  local resType = self:getRawType(array.type.nestedType)
  self:codeGetElementPtr(res, typeToLLVM[resType], array.value, index.value)
 
  return self:exp(res, array.type.nestedType)
end

function Compiler:codeExpUnarith(exp)
  local e = self:codeExp(exp.e)
  local res = self:newTemp()
  local eRawType = self:getRawType(e.type)
  self.emit("%s = %s %s %s, %s", res, binAOps["-"][eRawType], typeToLLVM[eRawType],
      eRawType == types.double and '0.0' or '0', e.value)
  return self:exp(res, e.type)
end

function Compiler:codeExpBinarith(exp)
  local r1 = self:codeExp(exp.e1)
  local r2 = self:codeExp(exp.e2)
  local r1RawType = self:getRawType(r1.type)
  local r2RawType = self:getRawType(r2.type)

  if not self:typeIsEqual(r1.type, r2.type) then
    if r1RawType == types.array or r2RawType == types.array then
      self.error("Attempt to perform arithmetic on array value")
    end
    
    r1, r2 = self:implicitCastBinarithExp(r1, r2, types.double)
  end

  local r1RawType = self:getRawType(r1.type)

  local opType = typeToLLVM[r1RawType]
  local opBinarith = binAOps[exp.op][r1RawType]

  local res = self:newTemp()
  self.emit("%s = %s %s %s, %s", res, opBinarith, opType, r1.value, r2.value)
  return self:exp(res, r1.type)
end

function Compiler:codeExpBinarithComp(exp)
  local r1 = self:codeExp(exp.e1)
  local r2 = self:codeExp(exp.e2)
  local r1RawType = self:getRawType(r1.type)
  local r2RawType = self:getRawType(r2.type)

  if not self:typeIsEqual(r1.type, r2.type) then
    if r1RawType == types.array or r2RawType == types.array then
      self.error("Attempt to compare array value")
    end

    r1, r2 = self:implicitCastBinarithExp(r1, r2, types.double)
  end

  local opType = typeToLLVM[r1RawType]
  local opBinarithComp = binCOps[exp.op][r1RawType]

  local res1 = self:newTemp()
  local res2 = self:newTemp()
  local compCommand = r1RawType == types.double and 'fcmp' or 'icmp'

  self.emit("%s = %s %s %s %s, %s", res1, compCommand, opBinarithComp, opType, r1.value, r2.value)
  self.emit("%s = zext i1 %s to i32", res2, res1)
  return self:exp(res2, {tag = "primitive type", type = types.int})
end

function Compiler:codeExpCall(exp)
  local st = {name = exp.name, params = exp.params}
  local callReturnValue, callReturnType = self:codeStatCall(st)
  return self:exp(callReturnValue, callReturnType)
end

function Compiler:codeExpCast(exp)
  if not self:typeExists(exp.type) then
    self.error("cast: type '%s' does not exists", self:strType(exp.type))
  end
  
  if exp.type == types.array then
    self.error("attempt to cast to array")
  end

  local res = self:codeExp(exp.e)

  if res.type == types.array then
    self.error("attempt to cast array value")
  end

  if self:typeIsEqual(res.type, exp.type) then
    -- self.error("cast: '%s' already a '%s' value", exp.e, exp.type) vira warning
  end
  local castedValue = self:codeCast(res.value, res.type, exp.type)
  return self:exp(castedValue, exp.type)
end

function Compiler:codeExpNew(exp)
  local size = self:codeExp(exp.size)
  local sizeRawType = self:getRawType(size.type)
  local expType = exp.type

  if expType.tag ~= "array type" then
      self.error("invalid type for new, expected array type, but received '%s'", self:strType(exp.type))
  end

  if sizeRawType ~= types.int then
    self.error("array size must be an int value")
  end

  local res = self:newTemp()
  self:codeMalloc(res, expType.nestedType, size.value)

  return self:exp(res, exp.type)
end

function Compiler:codeExpPreInc(exp)
  local varAddress = self:codeExp(exp.varAddress)
  local varExp = self:codeExp(exp.varExp)
  local res = self:newTemp()
  self:codeInc(res, varExp.type, varExp.value, varAddress.value)
  return self:exp(res, varExp.type)
end

function Compiler:codeExpPostInc(exp)
  local varAddress = self:codeExp(exp.varAddress)
  local varExp = self:codeExp(exp.varExp)
  local res = self:newTemp()
  self:codeInc(res, varExp.type, varExp.value, varAddress.value)
  return self:exp(varExp.value, varExp.type)
end

function Compiler:codeExpPreDec(exp)
  local varAddress = self:codeExp(exp.varAddress)
  local varExp = self:codeExp(exp.varExp)
  local res = self:newTemp()
  self:codeDec(res, varExp.type, varExp.value, varAddress.value)
  return self:exp(res, varExp.type)
end

function Compiler:codeExpPostDec(exp)
  local varAddress = self:codeExp(exp.varAddress)
  local varExp = self:codeExp(exp.varExp)
  local res = self:newTemp()
  self:codeDec(res, varExp.type, varExp.value, varAddress.value)
  return self:exp(varExp.value, varExp.type)
end

-- MARK: Statement Functions
function Compiler:codeStat(st)
    local tag = st.tag
    if tag == "seq" then
      self:codeStatSeq(st)
    elseif tag == "block" then
      self:codeStatBlock(st)
    elseif tag == "call" then
        self:codeStatCall(st)
    elseif tag == "return" then
      self:codeStatReturn(st)
    elseif tag == "if" then
      self:codeStatIf(st)
    elseif tag == "while" then
      self:codeStatWhile(st)
    elseif tag == "print" then
      self:codeStatPrint(st)
    elseif tag == "createVar" then
      self:codeStatCreateVar(st)
    elseif tag == "assignVar" then
      self:codeStatAssignAss(st)
    elseif tag == "preInc" then
      self:codeStatInc(st)
    elseif tag == "postInc" then
      self:codeStatInc(st)
    elseif tag == "preDec" then
      self:codeStatDec(st)
    elseif tag == "postDec" then
      self:codeStatDec(st)
    else
        self.error("'%s': statement not yet implemented", tag)
    end
end

function Compiler:codeStatSeq(st) 
  self:codeStat(st.s1)
  self:codeStat(st.s2)
end

function Compiler:codeStatBlock(st)
  local vars = self.vars
  local level = #vars
  self:codeStat(st.body)
  for i = #vars, level + 1, -1 do
      table.remove(vars)
  end
end

function Compiler:codeStatCall(st)
  local funcName = st.name
  local params = st.params
  local func = self.funcs[funcName]
  if not func then
      self.error("Attempt to call a nil value '%s'", func.name)
  end

  if #params ~= func.nArgs then
      self.error("Expected %d parameters, but received %d", func.nArgs, #params)
  end

  local paramsTable = {}
  for _, param in ipairs(params) do
      local exp = self:codeExp(param)
      table.insert(paramsTable, exp)
  end

  local paramsString = ""
  for i, param in ipairs(paramsTable) do
      local paramRawType = self:getRawType(param.type)
      local paramValue = param.value
      local argRawType = self:getRawType(func.argsType[i])
      local castedParam = param

      if not self:typeIsEqual(param.type, func.argsType[i]) then
        if argRawType == types.double and paramRawType == types.int then
          castedParam = self:implicitCastExpToDouble(param)
        elseif argRawType == types.int and paramRawType == types.double then
          castedParam = self:implicitCastExpToInt(param)
        else
          self.error("expected parameter of type '%s', but received type '%s'", self:strType(func.argsType[i]),
              self:strType(param.type))
        end
      end

      local castedParamRawType = self:getRawType(castedParam.type)

      paramsString = paramsString .. typeToLLVM[castedParamRawType] .. " " .. castedParam.value .. ', '
  end
  paramsString = paramsString:sub(1, -3)

  local funcRawRetType = self:getRawType(func.retType)
  local reg = nil

  if func.retType.type == types.void then
    self.emit("call %s @%s(%s)", typeToLLVM[funcRawRetType], funcName, paramsString)
  else 
    reg = self:newTemp()
    self.emit("%s = call %s @%s(%s)", reg, typeToLLVM[funcRawRetType], funcName, paramsString)
  end

  return reg, func.retType
end

function Compiler:codeStatReturn(st)
  local returnExp = ""
  local returnType = {
      tag = "primitive type",
      type = types.void
  }

  if st.e and st.e ~= "" then
      returnExp = self:codeExp(st.e)
      returnType = returnExp.type
  end

  local returnRawType = self:getRawType(returnType)
  local castedReturnExp = returnExp
  local castedReturnType = returnType

  local isValidReturnType, expectedReturnType = self:isValidReturnType(returnType)

  if not isValidReturnType then
      local expectedReturnRawType = self:getRawType(expectedReturnType)
      if expectedReturnRawType == types.double and returnRawType == types.int then
        castedReturnExp = self:implicitCastExpToDouble(returnExp)
      elseif expectedReturnRawType == types.int and returnRawType == types.double then
        castedReturnExp = self:implicitCastExpToInt(returnExp)
      else
        self.error("wrong return type, function '%s' should be returning '%s', but is returning '%s'",
          self.currentFunc.name, self:strType(expectedReturnType), self:strType(returnType))
      end

      castedReturnType = castedReturnExp.type
  end

  local castedReturnExpRawType = self:getRawType(castedReturnType)

  self.emit("ret %s %s", typeToLLVM[castedReturnExpRawType], castedReturnExp.value or "")
end

function Compiler:codeStatIf(st)
  local Lthen = self:newLabel()
  local Lelse = self:newLabel()
  local Lend = self:newLabel()

  self:codeCond(st.cond, Lthen, st.els and Lelse or Lend)

  self:codeLabel(Lthen)
  self:codeStat(st.th)
  self:codeJmp(Lend)

  if st.els then
      self:codeLabel(Lelse)
      self:codeStat(st.els)
      self:codeJmp(Lend)
  end

  self:codeLabel(Lend)
end

function Compiler:codeStatWhile(st)
  local Lcond = self:newLabel()
  local Lbody = self:newLabel()
  local Lend = self:newLabel()
  self:codeJmp(Lcond)
  self:codeLabel(Lcond)
  self:codeCond(st.cond, Lbody, Lend)
  self:codeLabel(Lbody)
  self:codeStat(st.body)
  self:codeJmp(Lcond)
  self:codeLabel(Lend)
end

function Compiler:codeStatPrint(st)
  local exp = self:codeExp(st.e)
  local reg = exp.value
  local expType = exp.type
  local expRawType = self:getRawType(expType)
  if expRawType == types.double then
    self.emit("call void @printD(double %s)", reg)
  elseif expRawType == types.int then
    self.emit("call void @printI(i32 %s)", reg)
  else
    self.error("attemp to print '%s' value", self:strType(exp.type))
  end
end

function Compiler:codeStatCreateVar(st)
  local reg = self:newTemp()
  local varType = st.type

  if st.e == nil then
    self:codeEmptyVar(st.id, reg, varType)
    return
  end
  
  local exp = self:codeExp(st.e)
  local expValue = exp.value
  local expType = exp.type

  self:codeVar(st.id, reg, exp, varType)
end

function Compiler:codeStatAssignAss(st)
  local var = self:codeExp(st.var)
  local exp = self:codeExp(st.e)
  local varRawType = self:getRawType(var.type)
  local expRawType = self:getRawType(exp.type)

  if not self:typeIsEqual(exp.type, var.type) then
    if varRawType == types.double and expRawType == types.int then
      exp = self:implicitCastExpToDouble(exp)
    elseif varRawType == types.int and expRawType == types.double then
      exp = self:implicitCastExpToInt(exp)
    else
      self.error("Tried to assing '%s' value to '%s' var", self:strType(exp.type), self:strType(var.type))
    end
  end

  local rawExpType = self:getRawType(exp.type)

  self.emit("store %s %s, ptr %s", typeToLLVM[rawExpType], exp.value, var.value)
end

function Compiler:codeStatInc(exp)
  local varAddress = self:codeExp(exp.varAddress)
  local varExp = self:codeExp(exp.varExp)
  local res = self:newTemp()
  self:codeInc(res, varAddress.type, varExp.value, varAddress.value)
end

function Compiler:codeStatDec(exp)
  local varAddress = self:codeExp(exp.varAddress)
  local varExp = self:codeExp(exp.varExp)
  local res = self:newTemp()
  self:codeDec(res, varAddress.type, varExp.value, varAddress.value)
end

-- MARK: Prog Functions
function Compiler:codeFunc(func)
    if func.type == "void" then
        func.type = {
            tag = "primitive type",
            type = types.void
        }
    end

    self.funcs[func.name] = {
        retType = func.type,
        nArgs = #func.args,
        argsType = {}
    }
    self.currentFunc.name = func.name

    self:codeFuncHeader(func)
    self:codeStat(func.body)

    local funcRawReturnType = self:getRawType(func.type)

    if funcRawReturnType == types.array then
      local temp = self:newTemp()
      self.emit("%s = alloca ptr", temp)
      self.emit("ret ptr %s", temp)
    elseif funcRawReturnType == types.void then
      self.emit("ret void")
    elseif funcRawReturnType == types.int then
      self.emit("ret i32 0")
    elseif funcRawReturnType == types.double then
      self.emit("ret double 0.0")
    end

    self.emit("}")

    self.currentFunc.name = ""
end

function Compiler:codeFuncHeader(func)
    local args = ""
    local params = {}
    for _, arg in ipairs(func.args) do
        local regArg = self:newTemp()

        local argType = arg.type
        local argId = arg.id

        if not self:typeExists(argType) then
            self.error(" Type '%s' of argument '%s' does not exists", argType, argId)
        end

        local argRawType = self:getRawType(argType)

        if argRawType == types.void then
            self.error("void type only allowed for function results")
        end

        table.insert(self.funcs[func.name].argsType, argType)

        args = args .. typeToLLVM[argRawType] .. ' ' .. regArg .. ', '
        table.insert(params, {
            id = argId,
            type = argType,
            reg = self:newTemp(),
            value = regArg
        })
    end

    args = args:sub(1, -3)

    local funcRawType = self:getRawType(func.type)
    self.emit("define %s @%s(%s) {", typeToLLVM[funcRawType], func.name, args)

    for _, param in ipairs(params) do
        self:codeVar(param.id, param.reg, param, param.type)
    end
end

function Compiler:codeProg(prog)
    for i = 1, #prog do
        self:codeFunc(prog[i])
    end
    if not self.funcs["main"] then
        self.error("missing main function")
    end
end

-- MARK: Premable
local premable = [[
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [7 x i8] c"%.16g\0A\00"

declare dso_local i32 @printf(i8*, ...)
declare ptr @malloc(i64)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}

define internal void @printD(double %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %x)
  ret void
}

]]

local input = io.read("a")
local tree = grammar.prog:match(input)
if not tree then
    Compiler.error("syntax error near <<%s|%s>>", string.sub(input, grammar.lastpos - 10, grammar.lastpos - 1),
        string.sub(input, grammar.lastpos, grammar.lastpos + 10))
end

-- print(pt.pt(tree))
Compiler.emit(premable)
local e = Compiler:codeProg(tree)