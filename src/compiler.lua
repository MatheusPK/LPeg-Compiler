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
}

local typeToLLVM = {
  ["int"] = "i32",
  ["double"] = "double"
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
    local value = self:codeExp(param)
    table.insert(paramsTable, value)
  end

  local paramsString = ""
  for _, paramValue in ipairs(paramsTable) do
    paramsString = paramsString .. "i32 " .. paramValue .. ', '
  end
  paramsString = paramsString:sub(1, -3)

  local reg = self:newTemp()
  self.emit(self.ident() .. " %s = call i32 @%s(%s)", reg, funcName, paramsString)

  return reg
end

function Compiler:codeVar(id, reg, value, type, expectedType)
  if not type then
    self.error("type '%s' does not exists", type)
  end

  if type ~= expectedType then
    self.error("Invalid type '%s'", type)
  end

  self.emit(self.ident() .. " %s = alloca %s", reg, typeToLLVM[type]) 
  self.emit(self.ident() .. " store %s %s, ptr %s", typeToLLVM[type], value, reg)
  self.vars[#self.vars + 1] = {id = id, type = type, reg = reg}
end

function Compiler:findVar(id)
    local vars = self.vars
    for i = #vars, 1, -1 do
        if vars[i].id == id then
            return vars[i]
        end
    end
    self.error("variable not found '%s'", id)
end

function Compiler:isValidReturnType(retType)
    local expectedReturnType = self.funcs[self.currentFunc.name].retType
    return expectedReturnType == retType, expectedReturnType
end

function Compiler:codeExp(exp)
    local tag = exp.tag
    if tag == "number int" then
        return {value = exp.num, type = types.int}
    elseif tag == "number double" then
      return {value = exp.num, type = types.double}
    elseif tag == "varId" then
        local var = self:findVar(exp.id)
        local regV = var.reg
        local res = self:newTemp()
        self.emit(self.ident() .. " %s = load %s, %s* %s",res, typeToLLVM[var.type], typeToLLVM[var.type], regV)
        return {value = res, type = var.type}
    elseif tag == "unarith" then
        local e = self:codeExp(exp.e)
        local res = self:newTemp()
        self.emit(self.ident() .. " %s = %s %s %s, %s", res, binAOps["-"][e.type], e.type, e.type == types.double and '0.0' or '0' , e.value)
        return {value = res, type = e.type}
    elseif tag == "binarith" then
        local r1 = self:codeExp(exp.e1)
        local r2 = self:codeExp(exp.e2)

        if r1.type ~= r2.type then
          self.error("Invalid binAops type")
        end

        local opType = typeToLLVM[r1.type]
        local opBinarith = binAOps[exp.op][r1.type]

        local res = self:newTemp()
        self.emit(self.ident() .. " %s = %s %s %s, %s", res, opBinarith, opType, r1.value, r2.value)
        return {value = res, type = r1.type}
    elseif tag == "binarith comp" then
        local r1 = self:codeExp(exp.e1)
        local r2 = self:codeExp(exp.e2)

        if r1.type ~= r2.type then
          self.error("Invalid binComp Type type")
        end

        local opType = typeToLLVM[r1.type]
        local opBinarithComp = binCOps[exp.op][r1.type]

        local res1 = self:newTemp()
        local res2 = self:newTemp()
        local compCommand = r1.type == types.double and 'fcmp' or 'icmp'

        self.emit(self.ident() .. " %s = %s %s %s %s, %s", res1, compCommand, opBinarithComp, opType, r1.value, r2.value)
        self.emit(self.ident() .. " %s = zext i1 %s to i32", res2, res1)
        return {value = res2, type = types.int}
    elseif tag == "call" then
      return self:codeCall(exp.name, exp.params)
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
        local returnType = "void"

        if st.e and st.e ~= "" then
          returnExp = self:codeExp(st.e)
          returnType = "int"
        end

        local isValidReturnType, expectedReturnType = self:isValidReturnType(returnType)
        if not isValidReturnType then
          self.error("wrong return type, function '%s' should be returning '%s', but is returning '%s'", self.currentFunc.name, expectedReturnType, returnType)
        end

        self.emit(self.ident() .. " ret %s %s", types[returnType] ,returnExp)
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
      if expType == types.double then
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
      local var = self:findVar(st.id)
      self.emit(self.ident() .. " store %s %s, ptr %s", typeToLLVM[res.type], regE, var.reg)
    else
      self.error("'%s': statement not yet implemented", tag)
    end
  end

local premable = [[
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

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
    self.funcs[func.name] = {retType = func.type, nArgs = #func.args}
    self.currentFunc.name = func.name

    self:codeFuncHeader(func)
    self:codeStat(func.body)

    if func.type == "void" then
      self.emit(self.ident() .. " ret void")
    elseif func.type == "int" then
      self.emit(self.ident() .. " ret i32 0")
    end

    self.emit("}")

    self.currentFunc.name = ""
end

function Compiler:codeFuncHeader(func)
  local args = ""
  local params = {}
  for _, arg in ipairs(func.args) do
    local regArg = self:newTemp()
    args = args .. 'i32 ' .. regArg .. ', '
    table.insert(params, {id = arg, reg = self:newTemp(), value = regArg})
  end

  args = args:sub(1, -3)

  self.emit("define %s @%s(%s) {", typeToLLVM[types[func.type]], func.name, args)

  for _, param in ipairs(params) do self:codeVar(param.id, param.reg, param.value) end
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