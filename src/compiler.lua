local grammar = require "src/grammar"
local pt = require "src/pt"

local Compiler = {
    tempCount = 0,
    vars = {},
    funcs = {},
    currentFunc = {name = ""}
}

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
  [types.array] = "ptr",
}

local typeSize = {
  [types.int] = 4,
  [types.double] = 8,
  [types.array] = 8,
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

function Compiler.ident(len) 
  len = len or 2
  return string.rep(" ", len)
end

function Compiler:newTemp()
    local temp = string.format("%%T%d", self.tempCount)
    self.tempCount = self.tempCount + 1
    return temp
end
  
function Compiler:newLabel ()
    local temp = string.format("L%d", self.tempCount)
    self.tempCount = self.tempCount + 1
    return temp
end

function Compiler.emit(content, ...)
  local finalContent = ... and string.format(content, ...) or  content
  io.write(finalContent .. "\n")
end

function Compiler.error(error, ...)
  local finalContent = ... and string.format(error, ...) or  error
  io.stderr:write(finalContent .. "\n")
  os.exit(1)
end
  
function Compiler:codeLabel (label)
  self.emit(self.ident(1) .. "%s:", label)
end

function Compiler:codeJmp (label)
    self.emit(self.ident() .. " br label %%%s", label)
end
  
function Compiler:codeCond (exp, Ltrue, Lfalse)
    local exp = self:codeExp(exp)
    local aux = self:newTemp()
    self.emit(self.ident() .. " %s = icmp ne i32 %s, 0", aux, exp.value)
    self.emit(self.ident() .. " br i1 %s, label %%%s, label %%%s", aux, Ltrue, Lfalse)
end

function Compiler:codeCast(value, baseType, targetType)
  local res = self:newTemp()
  local baseRawType = self:getRawType(baseType)
  local targetRawType = self:getRawType(targetType)
  self.emit(self.ident() .. " %s = %s %s %s to %s", res, castOp[baseRawType][targetRawType], typeToLLVM[baseRawType], value, typeToLLVM[targetRawType])
  return res
end

function Compiler:codeCall(funcName, params)
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
    local paramType = typeToLLVM[paramRawType]
    local paramValue = param.value

    if not self:typeIsEqual(param.type, func.argsType[i]) then
      self.error("expected parameter of type '%s', but received type '%s'", func.argsType[i], paramType)
    end 
    paramsString = paramsString .. paramType .. " " .. paramValue .. ', '
  end
  paramsString = paramsString:sub(1, -3)

  local funcRawRetType = self:getRawType(func.retType)
  local reg = self:newTemp()
  self.emit(self.ident() .. " %s = call %s @%s(%s)", reg, typeToLLVM[funcRawRetType], funcName, paramsString)

  return reg, func.retType
end

function Compiler:typeExists(type)
  if type.tag == "primitive type" then
      return types[type.t] ~= nil
  elseif type.tag == "array type" then
    return self:typeExists(type.t)
  else
    return false
  end
end

function Compiler:typeIsEqual(typeA, typeB)
  if typeA.tag == typeB.tag and typeA.tag == "primitive type" then
    return typeA.t == typeB.t
  elseif typeA.tag == typeB.tag and typeA.tag == "array type" then
    return self:typeIsEqual(typeA.t, typeB.t)
  else
    return false
  end
end

function Compiler:getRawType(type)
  if type.tag == "primitive type" then
      return type.t
  elseif type.tag == "array type" then
      return types.array
  else
    self.error("'%s' type not yet implemented", type.tag)
  end
end

function Compiler:codeVar(id, reg, value, expType, varType)
  if not self:typeExists(varType) then
    self.error("declaring a var with type '%s' that does not exists", expType)
  end

  if not self:typeIsEqual(expType, varType) then
    self.error("code var: var type and expression type mismatch")
  end

  local expRawType = self:getRawType(expType)
  local varRawType = self:getRawType(varType)

  self.emit(self.ident() .. " %s = alloca %s", reg, typeToLLVM[expRawType]) 
  self.emit(self.ident() .. " store %s %s, ptr %s", typeToLLVM[varRawType], value, reg)
  self.vars[#self.vars + 1] = {id = id, type = varType, reg = reg}
end

function Compiler:codeMalloc(reg, type, size)
  local mallocSize = 0

  if type.tag == "array type" then
    mallocSize = typeSize[types.array]
  elseif type.tag == "primitive type" then
    mallocSize = typeSize[type.t]
  else
    self.error("Type '%s' not yet implemented", type.tag)
  end

  self.emit(self.ident() .. " %s = call ptr @malloc(i64 %s)", reg, mallocSize)
end

function Compiler:codeGetElementPtr(res, type, var, index)
  -- %4 = getelementptr inbounds i32, ptr %3, i64 1
  self.emit(self.ident() .. "%s = getelementptr inbounds %s, ptr %s, i64 %s", res, type, var, index)
end

function Compiler:newFindVar(var)
 if var.tag == "varExp" then
    for i = #self.vars, 1, -1 do
        if self.vars[i].id == var.t then
          local res =  {reg = self.vars[i].reg, type = self.vars[i].type}
          return res
        end
    end
  elseif var.tag == "indexed" then
    local value = self:newFindVar(var.t)
    local res = self:newTemp()
    local index = self:codeExp(var.index)
    local varRawType = self:getRawType(value.type.t)

    self:codeGetElementPtr(res, typeToLLVM[varRawType], value.reg, index.value)
    return {reg = res, type = {tag = value.type.t.tag, t = value.type.t.t}}
  end
end

function Compiler:findVar(var)
  local res = self:newFindVar(var)
  return res
end

function Compiler:isValidReturnType(retType)
    local expectedReturnType = self.funcs[self.currentFunc.name].retType
    return self:typeIsEqual(expectedReturnType, retType), expectedReturnType
end

function Compiler:exp(value, type)
  return {value = value, type = type}
end

function Compiler:codeExp(exp)
    local tag = exp.tag
    if tag == "number int" then
        return self:exp(exp.num,  {tag = "primitive type", t = types.int})
    elseif tag == "number double" then
      return self:exp(exp.num, {tag = "primitive type", t = types.double})
    elseif tag == "var" then
        local var = self:findVar(exp.var)
        local regV = var.reg
        local res = self:newTemp()
        local varRawType = self:getRawType(var.type)
        self.emit(self.ident() .. " %s = load %s, %s* %s",res, typeToLLVM[varRawType], typeToLLVM[varRawType], regV)
        return self:exp(res, var.type)
    elseif tag == "unarith" then
        local e = self:codeExp(exp.e)
        local res = self:newTemp()
        local eRawType = self:getRawType(e.type)
        self.emit(self.ident() .. " %s = %s %s %s, %s", res, binAOps["-"][eRawType], typeToLLVM[eRawType], eRawType == types.double and '0.0' or '0' , e.value)
        return self:exp(res, e.type)
    elseif tag == "binarith" then
        local r1 = self:codeExp(exp.e1)
        local r2 = self:codeExp(exp.e2)

        if not self:typeIsEqual(r1.type, r2.type) then
          self.error("Invalid binAops type")
        end

        local r1RawType = self:getRawType(r1.type)

        local opType = typeToLLVM[r1RawType]
        local opBinarith = binAOps[exp.op][r1RawType]

        local res = self:newTemp()
        self.emit(self.ident() .. " %s = %s %s %s, %s", res, opBinarith, opType, r1.value, r2.value)
        return self:exp(res, r1.type)
    elseif tag == "binarith comp" then
        local r1 = self:codeExp(exp.e1)
        local r2 = self:codeExp(exp.e2)

        if not self:typeIsEqual(r1.type, r2.type) then
          self.error("Invalid binComp Type type")
        end

        local r1RawType = self:getRawType(r1.type)

        local opType = typeToLLVM[r1RawType]
        local opBinarithComp = binCOps[exp.op][r1RawType]

        local res1 = self:newTemp()
        local res2 = self:newTemp()
        local compCommand = r1RawType == types.double and 'fcmp' or 'icmp'

        self.emit(self.ident() .. " %s = %s %s %s %s, %s", res1, compCommand, opBinarithComp, opType, r1.value, r2.value)
        self.emit(self.ident() .. " %s = zext i1 %s to i32", res2, res1)
        return self:exp(res2, {tag = "primitive type", t = types.int})
    elseif tag == "call" then
      local callReturnValue, callReturnType = self:codeCall(exp.name, exp.params)
      return self:exp(callReturnValue, callReturnType)
    elseif tag == "cast" then
      if not self:typeExists(exp.type) then
        self.error("cast: type '%s' does not exists", exp.type.tag)
      end

      local res = self:codeExp(exp.e)

      if self:typeIsEqual(res.type, exp.type) then
        --self.error("cast: '%s' already a '%s' value", exp.e, exp.type) vira warning
      end
      local castedValue = self:codeCast(res.value, res.type, exp.type)
      return self:exp(castedValue, exp.type)
    elseif tag == "new" then
      local size = exp.size

      if exp.type.tag ~= "array type" then
        self.error("invalid type for new, expected array type, but received '%s'", exp.type.tag)
      end

      local res = self:newTemp()
      self:codeMalloc(res, exp.type.t, exp.type.size)
      
      return self:exp(res, exp.type)
    else
        self.error("'%s': expression not yet implemented", tag)
    end
end

function Compiler:codeStat (st)
    local tag = st.tag
    if tag == "seq" then
      self:codeStat(st.s1)
      self:codeStat(st.s2)
    elseif tag == "block" then
      local vars = self.vars
      local level = #vars
      self:codeStat(st.body)
      for i = #vars, level + 1, -1 do
        table.remove(vars)
      end
    elseif tag == "call" then
      self:codeCall(st.name, st.params)
    elseif tag == "return" then
        local returnExp = ""
        local returnType = {tag = "primitive type", t = types.void}

        if st.e and st.e ~= "" then
          returnExp = self:codeExp(st.e)
          returnType = returnExp.type
        end

        local isValidReturnType, expectedReturnType = self:isValidReturnType(returnType)
        if not isValidReturnType then
          self.error("wrong return type, function '%s' should be returning '%s', but is returning '%s'", self.currentFunc.name, expectedReturnType, returnType)
        end

        local rawReturnType = self:getRawType(returnType)

        self.emit(self.ident() .. " ret %s %s", typeToLLVM[rawReturnType], returnExp.value or "")
    elseif tag == "if" then
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
    elseif tag == "while" then
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
    elseif tag == "print" then
      local exp = self:codeExp(st.e)
      local reg = exp.value
      local expType = exp.type
      local expRawType = self:getRawType(expType)
      if expRawType == types.double then
        self.emit(self.ident() .. " call void @printD(double %s)", reg)
      else
        self.emit(self.ident() .. " call void @printI(i32 %s)", reg)
      end
    elseif tag == "var" then
      local exp = self:codeExp(st.e)
      local expValue = exp.value
      local expType = exp.type
      local reg = self:newTemp()
      local varType = st.type

      self:codeVar(st.id, reg, expValue, expType, varType)
    elseif tag == "ass" then
      local res = self:codeExp(st.e)
      local regE = res.value
      local var = self:findVar(st.var)

      if not self:typeIsEqual(res.type, var.type) then
        self.error("Tried to assing '%s' value to '%s' var", res.type, var.type)
      end

      local rawResType = self:getRawType(res.type)

      self.emit(self.ident() .. " store %s %s, ptr %s", typeToLLVM[rawResType], regE, var.reg)
    else
      self.error("'%s': statement not yet implemented", tag)
    end
  end

local premable = [[
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [6 x i8] c"%.16g\00"

declare dso_local i32 @printf(i8*, ...)
declare ptr @malloc(i64 noundef)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}

define internal void @printD(double %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %x)
  ret void
}

]]


function Compiler:codeFunc (func)
    if func.type == "void" then
      func.type = {tag = "primitive type", t = types.void}
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
      self.emit(self.ident() .. " ret ptr")
    elseif funcRawReturnType == types.void then
      self.emit(self.ident() .. " ret void")
    elseif funcRawReturnType == types.int then
      self.emit(self.ident() .. " ret i32 0")
    elseif funcRawReturnType == types.double then
      self.emit(self.ident() .. "ret double 0.0")
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
    table.insert(params, {id = argId, type = argType, reg = self:newTemp(), value = regArg})
  end

  args = args:sub(1, -3)

  local funcRawType = self:getRawType(func.type)
  self.emit("define %s @%s(%s) {", typeToLLVM[funcRawType], func.name, args)

  for _, param in ipairs(params) do 
    self:codeVar(param.id, param.reg, param.value, param.type, param.type) 
  end
end

function Compiler:codeProg (prog)
    for i = 1, #prog do
      self:codeFunc(prog[i])
    end
    if not self.funcs["main"] then
      self.error("missing main function")
    end
end

local input = io.read("a")
local tree = grammar.prog:match(input)
if not tree then
    Compiler.error("syntax error near <<%s|%s>>", string.sub(input, grammar.lastpos - 10, grammar.lastpos - 1),  string.sub(input, grammar.lastpos, grammar.lastpos + 10))
end

-- print(pt.pt(tree))
Compiler.emit(premable)
local e = Compiler:codeProg(tree) 