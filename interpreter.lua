
local lpeg = require "lpeg"
local pt = require "pt"
local utils = require "utils"
local Compiler = require "compiler"


local function I (msg)
  return lpeg.P(function () print(msg); return true end)
end

--- FRONTEND ---
----------------

local alpha = lpeg.R("AZ", "az")
local digit = lpeg.R("09")
local alphanum = alpha + digit

local comment = "#" * (lpeg.P(1) - "\n")^0
local block_comment = "#{" * (lpeg.P(1) - "#}") ^ 0 * "#}"
local comments = block_comment + comment;

local maxmatch = 0
local space = lpeg.V"space"


local numeral = lpeg.P("-")^0 * lpeg.R("09")^1 / tonumber /
                     utils.node("number", "val")  * space

local reserved = {"return", "if", "else", "while", "@"}
local excluded = lpeg.P(false)
for i = 1, #reserved do
  excluded = excluded + reserved[i]
end
excluded = excluded * -alphanum

local ID = (lpeg.C(alpha * alphanum^0) - excluded) * space
local var = ID / utils.node("variable", "var")


local function T (t)
  return t * space
end


local function Rw (t)
  assert(excluded:match(t))
  return t * -alphanum * space
end


local opA = lpeg.C(lpeg.S"+-") * space
local opM = lpeg.C(lpeg.S"*/") * space
local opR = lpeg.C(lpeg.S"%") * space
local opP = lpeg.C(lpeg.S"^") * space
local opLessThen = lpeg.C(lpeg.S"<") * space
local opGreaterThen = lpeg.C(lpeg.S">") * space
local opLessOrEqualThen = lpeg.C(lpeg.P"<=") * space
local opGreaterOrEqualThen = lpeg.C(lpeg.P">=") * space
local opEqualThen = lpeg.C(lpeg.P"==") * space
local opNotEqualThen = lpeg.C(lpeg.P"!=") * space


-- Convert a list {n1, "+", n2, "+", n3, ...} into a tree
-- {...{ op = "+", e1 = {op = "+", e1 = n1, n2 = n2}, e2 = n3}...}
local function foldBin (lst)
  local tree = lst[1]
  for i = 2, #lst, 2 do
    tree = { tag = "binop", e1 = tree, op = lst[i], e2 = lst[i + 1] }
  end
  return tree
end

local factor = lpeg.V"factor"
local term0 = lpeg.V"term0"
local term1 = lpeg.V"term1"
local term2 = lpeg.V"term2"
local exp = lpeg.V"exp"
local stat = lpeg.V"stat"
local stats = lpeg.V"stats"
local block = lpeg.V"block"
 
--(T";" * stats) + T";"

grammar = lpeg.P{"prog",
  prog = space * stats * -1,
  stats = stat * (T";" * stats)^-1 / utils.nodeSeq,
  block = T"{" * I("test2") * stats * T"}",
  stat = block
       + Rw"if" * exp * block * (Rw"else" * block)^-1
           / utils.node("if1", "cond", "th", "el")
       + Rw"while" * exp * block / utils.node("while1", "cond", "body")
       + ID * T"=" * exp / utils.node("assgn", "id", "exp")
       + Rw"@" * exp / utils.node("print", "exp")
       + Rw"return" * exp / utils.node("ret", "exp"),
  factor = numeral + T"(" * exp * T")" + var,
  term0 = lpeg.Ct(factor * (opP * factor)^0) / foldBin,
  term1 = lpeg.Ct(term0 * ((opR + opM) * term0)^0) / foldBin,
  term2 = lpeg.Ct(term1 * (opA * term1)^0) / foldBin,
  exp = lpeg.Ct(term2 * (( opLessThen + opGreaterThen + opLessOrEqualThen + opGreaterOrEqualThen + opEqualThen + opNotEqualThen) * term2)^0) / foldBin,

  space = (lpeg.S(" \t\n") + comments)^0
            * lpeg.P(function (_,p)
                       maxmatch = math.max(maxmatch, p)
                       return true
                     end)
}

local function syntaxError (input, max)
  io.stderr:write("syntax error\n")
  io.stderr:write(string.sub(input, max - 10, max - 1),
        "|", string.sub(input, max, max + 11), "\n")
end

local function parse (input)
  local res = grammar:match(input)
  if (not res) then
    syntaxError(input, maxmatch)
    os.exit(1)
  end
  return res
end

--- COMPILER ---
----------------

local function compile (ast)
  Compiler:codeStat(ast)
  Compiler:addCode("push")
  Compiler:addCode(0)
  Compiler:addCode("ret")
  return Compiler.code
end

--- INTERPRETER ---
-------------------

local function run (code, mem, stack)
  local pc = 1
  local top = 0
  while true do
  local comp_result = 0
  --[[
  io.write("--> ")
  for i = 1, top do io.write(stack[i], " ") end
  io.write("\n", code[pc], "\n")
  --]]
    if code[pc] == "ret" then
      return
    elseif code[pc] == "print" then
      print(stack[top])
    elseif code[pc] == "push" then
      pc = pc + 1
      top = top + 1
      stack[top] = code[pc]
    elseif code[pc] == "add" then
      stack[top - 1] = stack[top - 1] + stack[top]
      top = top - 1
    elseif code[pc] == "sub" then
      stack[top - 1] = stack[top - 1] - stack[top]
      top = top - 1
    elseif code[pc] == "mul" then
      stack[top - 1] = stack[top - 1] * stack[top]
      top = top - 1
    elseif code[pc] == "div" then
      stack[top - 1] = stack[top - 1] / stack[top]
      top = top - 1
    elseif code[pc] == "mod" then
      stack[top - 1] = stack[top - 1] % stack[top]
      top = top - 1
    elseif code[pc] == "pow" then
      stack[top - 1] = stack[top - 1] ^ stack[top]
      top = top - 1
    elseif code[pc] == "less_then" then
      if (stack[top - 1] < stack[top]) then
          comp_result = 1
      end
      stack[top - 1] = comp_result
      top = top - 1
    elseif code[pc] == "greater_then" then
      if (stack[top - 1] > stack[top]) then
          comp_result = 1
      end
      stack[top - 1] = comp_result
      top = top - 1
    elseif code[pc] == "less_or_equal_then" then
      if (stack[top - 1] <= stack[top]) then
          comp_result = 1
      end
      stack[top - 1] = comp_result
      top = top - 1
    elseif code[pc] == "greater_or_equal_then" then
      if (stack[top - 1] >= stack[top]) then
          comp_result = 1
      end
      stack[top - 1] = comp_result
      top = top - 1
    elseif code[pc] == "equal_then" then
      if (stack[top - 1] == stack[top]) then
          comp_result = 1
      end
      stack[top - 1] = comp_result
      top = top - 1
    elseif code[pc] == "not_equal_then" then
      if (stack[top - 1] ~= stack[top]) then
          comp_result = 1
      end
      stack[top - 1] = comp_result
      top = top - 1
    elseif code[pc] == "load" then
      pc = pc + 1
      local id = code[pc]
      top = top + 1
      stack[top] = mem[id]
    elseif code[pc] == "store" then
      pc = pc + 1
      local id = code[pc]
      mem[id] = stack[top]
      top = top - 1
    elseif code[pc] == "jmp" then
      pc = code[pc + 1]
    elseif code[pc] == "jmpZ" then
      pc = pc + 1
      if stack[top] == 0 or stack[top] == nil then
        pc = code[pc]
      end
      top = top - 1
    else error("unknown instruction")
    end
    pc = pc + 1
  end
end


local input = io.read("a")
local ast = parse(input)
print(pt.pt(ast))
local code = compile(ast)
--print(pt.pt(code))
local stack = {}
local mem = {}
run(code, mem, stack)
print(stack[1])