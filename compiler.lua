local grammar = require "grammar"
local pt = require "pt"

local Compiler = {
    binAOps = {
        ["+"] = "add",
        ["-"] = "sub",
        ["*"] = "mul",
        ["/"] = "sdiv"
    },
    binCOps = {
        [">="] = "sge",
        ["<="] = "sle",
        [">"] = "sgt",
        ["<"] = "slt",
        ["=="] = "eq",
        ["~="] = "ne"
    },
    tempCount = 0,
    vars = {},
    funcs = {}
}

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
    local finalContent = string.format(content, ...)
    io.write('  ' .. finalContent .. '\n')
end
  
  
  function Compiler:codeLabel (label)
    self.emit("%s:", label)
  end


function Compiler:codeJmp (label)
    self.emit("br label %%%s", label)
  end
  
  
function Compiler:codeCond (exp, Ltrue, Lfalse)
    local reg = self:codeExp(exp)
    local aux = self:newTemp()
    self.emit("%s = icmp ne i32 %s, 0", aux, reg)
    self.emit("br i1 %s, label %%%s, label %%%s", aux, Ltrue, Lfalse)
end

function Compiler:findVar(id)
    local vars = self.vars
    for i = #vars, 1, -1 do
        if vars[i].id == id then
            return vars[i].reg
        end
    end
    error("variable not found " .. id)
end

function Compiler:codeExp(exp)
    local tag = exp.tag
    if tag == "number" then
        return exp.num
    elseif tag == "varId" then
        local regV = self:findVar(exp.id)
        local res = self:newTemp()
        self.emit("%s = load i32, i32* %s", res, regV)
        return res
    elseif tag == "unarith" then
        local e = self:codeExp(exp.e)
        local res = self:newTemp()
        self.emit("%s = sub i32 0, %s", res, e)
        return res
    elseif tag == "binarith" then
        local r1 = self:codeExp(exp.e1)
        local r2 = self:codeExp(exp.e2)
        local res = self:newTemp()
        self.emit("%s = %s i32 %s, %s", res, self.binAOps[exp.op], r1, r2)
        return res
    elseif tag == "binarith comp" then
        local r1 = self:codeExp(exp.e1)
        local r2 = self:codeExp(exp.e2)
        local res1 = self:newTemp()
        local res2 = self:newTemp()
        self.emit("%s = icmp %s i32 %s, %s", res1, self.binCOps[exp.op], r1, r2)
        self.emit("%s = zext i1 %s to i32", res2, res1)
        return res2
    elseif tag == "call" then
        print("To no call")
        print(exp.name)
    else
        error(tag .. ": expression not yet implemented")
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
        if not self.funcs[st.name] then
          error("unknown function " .. st.name)
        end
        local reg = self:newTemp()
        io.write(string.format("%s = call i32 @%s()\n", reg, st.name))
    elseif tag == "return" then
        local exp = nil
        if st.e then
            exp = self:codeExp(st.e)
        end
        self.emit("ret i32 %s", exp or '0')
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
      self.emit("call void @printI(i32 %s)", reg)
    elseif tag == "var" then
      local regE = self:codeExp(st.e)
      local regV = self:newTemp()
      self.emit("%s = alloca i32", regV) 
      self.emit("store i32 %s, i32* %s", regE, regV)
      self.vars[#self.vars + 1] = {id = st.id, reg = regV}
    elseif tag == "ass" then
      local regE = self:codeExp(st.e)
      local regV = self:findVar(st.id)
      self.emit("store i32 %s, i32* %s", regE, regV)
    else
      error(tag .. ": statement not yet implemented")
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

local poscode = [[
  ret i32 0
}
]]


function Compiler:codeFunc (func)
    self.funcs[func.name] = true
    io.write(string.format("define i32 @%s() {\n", func.name))
    self:codeStat(func.body)
    io.write(poscode)  
end


function Compiler:codeProg (prog)
    for i = 1, #prog do
    self:codeFunc(prog[i])
    end
    if not self.funcs["main"] then
    error("missing main function")
    end
end


local input = io.read("a")
local tree = grammar.prog:match(input)

if not tree then
    io.write("syntax error near <<" ..
    string.sub(input, grammar.lastpos - 10, grammar.lastpos - 1) .. "|" ..
    string.sub(input, grammar.lastpos, grammar.lastpos + 10), ">>\n")
    os.exit(1)
end
io.write(premable)
local e = Compiler:codeProg(tree)