local grammar = require "src/grammar"
local pt = require "src/pt"

local Compiler = {
    tempCount = 0,
    vars = {},
    funcs = {},
    currentFunc = {name = ""}
}

local binAOps = {
  ["+"] = "add",
  ["-"] = "sub",
  ["*"] = "mul",
  ["/"] = "sdiv"
}

local binCOps = {
  [">="] = "sge",
  ["<="] = "sle",
  [">"] = "sgt",
  ["<"] = "slt",
  ["=="] = "eq",
  ["~="] = "ne"
}

local types = {
  ["int"] = "i32",
  ["void"] = "void"
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
    local reg = self:codeExp(exp)
    local aux = self:newTemp()
    self.emit(self.ident() .. " %s = icmp ne i32 %s, 0", aux, reg)
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

function Compiler:codeVar(id, reg, value)
  self.emit(self.ident() .. " %s = alloca i32", reg) 
  self.emit(self.ident() .. " store i32 %s, i32* %s", value, reg)
  self.vars[#self.vars + 1] = {id = id, reg = reg}
end

function Compiler:findVar(id)
    local vars = self.vars
    for i = #vars, 1, -1 do
        if vars[i].id == id then
            return vars[i].reg
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
    if tag == "number" then
        return exp.num
    elseif tag == "varId" then
        local regV = self:findVar(exp.id)
        local res = self:newTemp()
        self.emit(self.ident() .. " %s = load i32, i32* %s", res, regV)
        return res
    elseif tag == "unarith" then
        local e = self:codeExp(exp.e)
        local res = self:newTemp()
        self.emit(self.ident() .. " %s = sub i32 0, %s", res, e)
        return res
    elseif tag == "binarith" then
        local r1 = self:codeExp(exp.e1)
        local r2 = self:codeExp(exp.e2)
        local res = self:newTemp()
        self.emit(self.ident() .. " %s = %s i32 %s, %s", res, binAOps[exp.op], r1, r2)
        return res
    elseif tag == "binarith comp" then
        local r1 = self:codeExp(exp.e1)
        local r2 = self:codeExp(exp.e2)
        local res1 = self:newTemp()
        local res2 = self:newTemp()
        self.emit(self.ident() .. " %s = icmp %s i32 %s, %s", res1, binCOps[exp.op], r1, r2)
        self.emit(self.ident() .. " %s = zext i1 %s to i32", res2, res1)
        return res2
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
      local reg = self:codeExp(st.e)
      self.emit(self.ident() .. " call void @printI(i32 %s)", reg)
    elseif tag == "var" then
      local value = self:codeExp(st.e)
      local reg = self:newTemp()
      self:codeVar(st.id, reg, value)
    elseif tag == "ass" then
      local regE = self:codeExp(st.e)
      local regV = self:findVar(st.id)
      self.emit(self.ident() .. " store i32 %s, i32* %s", regE, regV)
    else
      self.error("'%s': statement not yet implemented", tag)
    end
  end

local premable = [[
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare dso_local i32 @printf(i8*, ...)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
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

  self.emit("define %s @%s(%s) {", types[func.type], func.name, args)

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