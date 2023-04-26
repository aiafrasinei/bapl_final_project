local lpeg = require "lpeg"
local pt = require "pt"
local utils = require "utils"
local Compiler = require "compiler"


local function I(msg)
  return lpeg.P(function()
    print(msg);
    return true
  end)
end

--- FRONTEND ---
----------------

local alpha = lpeg.R("AZ", "az")
local digit = lpeg.R("09")
local alphanum = alpha + digit

local comment = "#" * (lpeg.P(1) - "\n") ^ 0
local block_comment = "#{" * (lpeg.P(1) - "#}") ^ 0 * "#}"
local comments = block_comment + comment;

local maxmatch = 0
local space = lpeg.V "space"


local numeral = lpeg.P("-") ^ 0 * lpeg.R("09") ^ 1 / tonumber /
    utils.node("number", "val") * space

local reserved = { "return", "if", "else", "elif", "while", "new", "@", "!" }
local excluded = lpeg.P(false)
for i = 1, #reserved do
  excluded = excluded + reserved[i]
end
excluded = excluded * -alphanum

local ID = (lpeg.C(alpha * alphanum ^ 0) - excluded) * space
local var = ID / utils.node("variable", "var")


local function T(t)
  return t * space
end


local function Rw(t)
  assert(excluded:match(t))
  return t * -alphanum * space
end

local opA = lpeg.C(lpeg.S "+-") * space
local opM = lpeg.C(lpeg.S "*/") * space
local opR = lpeg.C(lpeg.S "%") * space
local opP = lpeg.C(lpeg.S "^") * space
local opLessThen = lpeg.C(lpeg.S "<") * space
local opGreaterThen = lpeg.C(lpeg.S ">") * space
local opLessOrEqualThen = lpeg.C(lpeg.P "<=") * space
local opGreaterOrEqualThen = lpeg.C(lpeg.P ">=") * space
local opEqualThen = lpeg.C(lpeg.P "==") * space
local opNotEqualThen = lpeg.C(lpeg.P "!=") * space

local lhs = lpeg.V "lhs"
local factor = lpeg.V "factor"
local term0 = lpeg.V "term0"
local term1 = lpeg.V "term1"
local term2 = lpeg.V "term2"
local exp = lpeg.V "exp"
local stat = lpeg.V "stat"
local stats = lpeg.V "stats"
local block = lpeg.V "block"

local grammar_table = {
  "prog",
  prog = space * stats * -1,
  stats = stat * (T ";" ^ 1 * stats) ^ -1 / utils.nodeSeq,
  block = T "{" * stats * T ";" ^ -1 * T "}",
  stat = block
      + Rw("if") * exp * block * (Rw("elif") * exp * block) ^ 0 * (Rw("else") * block) ^ -1
      / utils.node("if1", "cond", "th", "el")
      + Rw("while") * exp * block / utils.node("while1", "cond", "body")
      + lhs * T "=" * exp / utils.node("assgn", "lhs", "exp")
      + Rw("@") * exp / utils.node("print", "exp")
      + Rw("!") * exp / utils.node("not", "exp")
      + Rw("return") * exp / utils.node("ret", "exp"),
  lhs = lpeg.Ct(var * (T "[" * exp * T "]") ^ 0) / utils.foldIndex,
  factor = Rw("new") * T "[" * exp * T "]" / utils.node("new", "size")
      + numeral
      + T "(" * exp * T ")"
      + lhs,
  term0 = lpeg.Ct(factor * (opP * factor) ^ 0) / utils.foldBin,
  term1 = lpeg.Ct(term0 * ((opR + opM) * term0) ^ 0) / utils.foldBin,
  term2 = lpeg.Ct(term1 * (opA * term1) ^ 0) / utils.foldBin,
  exp = lpeg.Ct(term2 *
        ((opLessThen + opGreaterThen + opLessOrEqualThen + opGreaterOrEqualThen + opEqualThen + opNotEqualThen) * term2) ^
        0) /
      utils.foldBin,
  space = (lpeg.S(" \t\n") + comments) ^ 0
      * lpeg.P(function(_, p)
        maxmatch = math.max(maxmatch, p)
        return true
      end)
}

local grammar = lpeg.P(grammar_table)
local gram = require('pegdebug').trace(grammar_table)

local function parse(input)
  local res = grammar:match(input)
  if (not res) then
    utils.syntaxError(input, maxmatch)
    os.exit(1)
  end
  return res
end

--- COMPILER ---
----------------

local function compile(ast)
  Compiler:codeStat(ast)
  Compiler:addCode("push")
  Compiler:addCode(0)
  Compiler:addCode("ret")
  return Compiler.code
end

--- INTERPRETER ---
-------------------

local function run(code, mem, stack)
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
      if (type(stack[top] == "table")) then
        io.write("[")
        for i, v in ipairs(stack[top]) do
          io.write(" ")
          io.write(tostring(v))
        end
        io.write(" ]\n");
      else
        print(stack[top])
      end
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
    elseif code[pc] == "not" then
      stack[top] = utils.neg(stack[top])
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
    elseif code[pc] == "newarray" then
      local size = stack[top]
      stack[top] = { size = size }
    elseif code[pc] == "getarray" then
      local array = stack[top - 1]
      local index = stack[top]
      stack[top - 1] = array[index]
      top = top - 1
    elseif code[pc] == "setarray" then
      local array = stack[top - 2]
      local index = stack[top - 1]
      local value = stack[top]
      array[index] = value
      top = top - 3
    elseif code[pc] == "jmp" then
      pc = code[pc + 1]
    elseif code[pc] == "jmpZ" then
      pc = pc + 1
      if stack[top] == 0 or stack[top] == nil then
        pc = code[pc]
      end
      top = top - 1
    else
      error("unknown instruction")
    end
    pc = pc + 1
  end
end


local input = io.read("a")
--print(lpeg.match(lpeg.P(gram), input))

local ast = parse(input)
--print(pt.pt(ast))

local code = compile(ast)
--print(pt.pt(code))

local stack = {}
local mem = {}
run(code, mem, stack)
print(stack[1])
