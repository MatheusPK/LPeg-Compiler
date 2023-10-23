local lpeg = require "lpeg"
local pt = require "pt"

local grammar = {}

local function node(tag, ...)
    local labels = {...}
    return function(...)
        local values = {...}
        local t = {tag = tag}
        for i = 1, #labels do
            t[labels[i]] = values[i]
        end
        return t
    end
end

local function fold(t)
    local res = t[1]
    for i = 2, #t, 2 do
        res = {tag = "binarith", e1 = res, op = t[i], e2 = t[i + 1]}
    end
    return res
end

local function foldComp(t)
    local res = t[1]
    for i = 2, #t, 2 do
        res = {tag = "binarith comp", e1 = res, op = t[i], e2 = t[i + 1]}
    end
    return res
end

local function foldReturn(t)
    return {tag = "return", e = t[1]}
end

local function I(msg)
    return lpeg.P(function() print(msg); return true end)
end

local S = lpeg.S(" \n\t") ^ 0

local OP = "(" * S
local CP = ")" * S
local OB = "{" * S
local CB = "}" * S
local SC = ";" * S
local CL = ":" * S
local CM = "," * S
local Prt = "@" * S
local Eq = "=" * S

local digit = lpeg.R "09"
local alpha = lpeg.R("az", "AZ", "__")
local alphanum = alpha + digit

local reservedwords = {}
local function Rw(id)
    reservedwords[id] = true
    return lpeg.P(id) * -alphanum * S
end

local function isValidIdentifier (s, currentPos, id)
    if reservedwords[id] then
        error("invalid var name(reserved word): " .. id)
    end

    return true, id
end

local integer = (digit ^ 1) / tonumber * S
local opA = lpeg.C(lpeg.S("+-")) * S
local opM = lpeg.C(lpeg.S("*/")) * S
local opUn = lpeg.C("-") * S

local Id = lpeg.C(alpha * alphanum ^ 0) * S

local maior = lpeg.C(lpeg.P('>')) * S
local menor = lpeg.C(lpeg.P('<')) * S
local maiorIgual = lpeg.C(lpeg.P('>=')) * S
local menorIgual = lpeg.C(lpeg.P('<=')) * S
local igualdade = lpeg.C(lpeg.P('==')) * S
local diferenca = lpeg.C(lpeg.P('~=')) * S
local opComp = (igualdade + diferenca + maiorIgual + menorIgual + maior + menor)

local primary = lpeg.V "primary"
local postfix = lpeg.V"postfix"
local factor = lpeg.V "factor"
local expM = lpeg.V "expM"
local expA = lpeg.V "expA"
local expOp = lpeg.V "expOp"
local expC = lpeg.V "expC"
local exp = lpeg.V "exp"
local stat = lpeg.V "stat"
local stats = lpeg.V"stats"
local block = lpeg.V"block"
local call = lpeg.V"call"
local arguments = lpeg.V"arguments"
local parameters = lpeg.V"parameters"
local def = lpeg.V"def"

grammar.lastpos = 0

grammar.prog = lpeg.P {"defs",
    defs = lpeg.Ct(def^1),
    def = Rw"fun" * Id * OP * arguments * CP * ((CL * Id) + lpeg.C"") * block / node("func", "name", "args", "type", "body"),
    stats = stat * (SC * stats)^-1 * SC^-1 / function (st, pg)
        return pg and {tag="seq", s1 = st, s2 = pg} or st
    end,
    block = OB * stats * CB / node("block", "body"),
    stat = Prt * exp / node("print", "e")
        + Rw "var" * lpeg.Cmt(Id, isValidIdentifier) * Eq * exp / node("var", "id", "e")
        + Id * Eq * exp / node("ass", "id", "e")
        + Rw"if" * exp * block * (Rw"else" * block)^-1 / node("if", "cond", "th", "els")
        + Rw"while" * exp * block / node("while", "cond", "body")
        + call
        + Rw"return" * (exp + lpeg.C"") / node("return", "e"),
    call = Id * OP * parameters * CP / node("call", "name", "params"),
    arguments = lpeg.Ct((Id * (CM * Id)^0)^-1),
    parameters = lpeg.Ct((exp * (CM * exp)^0)^-1),
    primary = integer / node("number", "num") 
        + OP * exp * CP 
        + Id / node("varId", "id"),
    postfix = call + primary,
    factor = postfix
            + opUn * factor / node("unarith", "op", "e"),
    expM = lpeg.Ct(factor * (opM * factor) ^ 0) / fold,
    expA = lpeg.Ct(expM * (opA * expM) ^ 0) / fold,
    expOp = lpeg.Ct(expA * (opComp * expA) ^ 0) / foldComp,
    exp = expOp,
    S = lpeg.S(" \n\t")^0 *
        lpeg.P(function (_,p)
                 grammar.lastpos = math.max(grammar.lastpos, p); return true end);
}

grammar.prog = grammar.prog * -1

return grammar