local lpeg = require "lpeg"
local locale = lpeg.locale();
local pt = require "pt"
local utils = require "utils"
local Compiler = require "compiler"
require "stackapi"


local function I(msg)
  return lpeg.P(function()
    print(msg);
    return true
  end)
end

--- FRONTEND ---
----------------

local DEBUG = false

local alpha = lpeg.R("AZ", "az")
local digit = lpeg.R("09")
local alphanum = alpha + digit

local comment = "#" * (lpeg.P(1) - "\n") ^ 0
local block_comment = "#{" * (lpeg.P(1) - "#}") ^ 0 * "#}"
local comments = block_comment + comment;
local types = lpeg.C((lpeg.P("e") + lpeg.P("f") + lpeg.P("t") + lpeg.P("n") + lpeg.P("s") + lpeg.P("b")))

local maxmatch = 0
local err_line_nr = 1
local space = lpeg.V "space"

local numeral = lpeg.P("-") ^ 0 * lpeg.R("09") ^ 1 / tonumber /
    utils.node("number", "val") * space
local text = ("\"" * (lpeg.P(1) - "\"") ^ 0 * "\"") ^ 1 / utils.node("text", "val") * space
local bool = (lpeg.P("true") + lpeg.P("false")) / utils.node("bool", "val") * space

local reserved = { "return", "if", "unless", "else", "elif", "while", "new", "function", "var", "@", "!",
  "PUSH", "POP", "DEPTH", "DROP", "PEEK",
  "DUP", "SWAP", "OVER", "TUCK", "ROT", "MINROT", "2DROP", "2SWAP", "2DUP", "2OVER", "2ROT", "2MINROT",
  "ADD", "SUB", "MUL", "DIV", "MOD",
  "SPRINT", "SUSE", "SADD", "SRM", "SREP", "SCLEAR", "SRA",
  "RPNEVAL", "EVAL", "PRINT", "INPUT", "FPUSH" }

local excluded = lpeg.P(false)
for i = 1, #reserved do
  excluded = excluded + reserved[i]
end
excluded = excluded * -alphanum

local ID = lpeg.V "ID"
local IDT = lpeg.V "IDT"
local var = (IDT + ID) / utils.node("variable", "var", "type")


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
local opLessThen = lpeg.C(lpeg.P "lt") * space
local opGreaterThen = lpeg.C(lpeg.P "gt") * space
local opLessOrEqualThen = lpeg.C(lpeg.P "le") * space
local opGreaterOrEqualThen = lpeg.C(lpeg.P "ge") * space
local opEqualThen = lpeg.C(lpeg.P "eq") * space
local opNotEqualThen = lpeg.C(lpeg.P "ne") * space

local lhs = lpeg.V "lhs"
local call = lpeg.V "call"
local factor = lpeg.V "factor"
local term0 = lpeg.V "term0"
local term1 = lpeg.V "term1"
local term2 = lpeg.V "term2"
local exp = lpeg.V "exp"
local stat = lpeg.V "stat"
local stats = lpeg.V "stats"
local block = lpeg.V "block"
local funcDec = lpeg.V "funcDec"
local funcFwdDec = lpeg.V "funcFwdDec"
local args = lpeg.V "args"
local params = lpeg.V "params"

local grammar_table = {
  "prog",
  prog = space * lpeg.Ct((funcDec + funcFwdDec) ^ 1) * -1,
  funcFwdDec = Rw "function" * IDT * T "(" * params * T ")"
      / utils.node("function", "name", "type"),
  funcDec = Rw "function" * IDT * T "(" * params * T ")" * block
      / utils.node("function", "name", "type", "params", "body"),
  params = lpeg.Ct((exp * (T "," * exp) ^ 0) ^ -1),
  stats = stat * stats ^ -1 / utils.nodeSeq,
  block = T "{" * stats * T "}" /
      utils.node("block", "body"),
  stat = block
      + Rw "var" * ID * T "=" * exp / utils.node("local", "name", "init")
      + Rw("if") * exp * block * (Rw("elif") * exp * block) ^ 0 *
      (Rw("else") * block) ^ -1
      / utils.node("if1", "cond", "th", "el")
      + Rw("unless") * exp * block * (Rw("else") * block) ^ -1
      / utils.node("unless1", "cond", "th", "el")
      + Rw("while") * exp * block / utils.node("while1", "cond", "body")
      + ((lhs * T "=" * exp) + lhs) / utils.node("assgn", "lhs", "exp")
      + Rw("@") * (exp + text) / utils.node("print", "exp")
      + Rw("!") * exp / utils.node("not", "exp")
      + Rw("PUSH") * exp / utils.node("spush", "exp")
      + Rw("POP") / utils.node("spop")
      + Rw("DEPTH") / utils.node("sdepth")
      + Rw("DROP") / utils.node("sdrop")
      + Rw("PEEK") * exp / utils.node("speek", "exp")
      + Rw("DUP") / utils.node("sdup")
      + Rw("SWAP") / utils.node("sswap")
      + Rw("OVER") / utils.node("sover")
      + Rw("TUCK") / utils.node("stuck")
      + Rw("ROT") / utils.node("srot")
      + Rw("MINROT") / utils.node("sminrot")
      + Rw("2DROP") / utils.node("s2drop")
      + Rw("2SWAP") / utils.node("s2swap")
      + Rw("2DUP") / utils.node("s2dup")
      + Rw("2OVER") / utils.node("s2over")
      + Rw("2ROT") / utils.node("s2rot")
      + Rw("2MINROT") / utils.node("s2minrot")
      + Rw("ADD") / utils.node("splus")
      + Rw("SUB") / utils.node("sminus")
      + Rw("MUL") / utils.node("smul")
      + Rw("DIV") / utils.node("sdiv")
      + Rw("MOD") / utils.node("smod")
      + Rw("RPNEVAL") / utils.node("srpneval")
      + Rw("EVAL") / utils.node("seval")
      + Rw("SPRINT") / utils.node("sprint")
      + Rw("SUSE") * exp / utils.node("suse", "exp")
      + Rw("SADD") * exp / utils.node("sadd", "exp")
      + Rw("SRM") * exp / utils.node("srm", "exp")
      + Rw("SREP") * exp / utils.node("srep", "exp")
      + Rw("SCLEAR") * exp / utils.node("sclear", "exp")
      + Rw("SRA") / utils.node("sra")
      + Rw("PRINT") / utils.node("tosprint")
      + Rw("INPUT") / utils.node("sinput")
      + Rw("FPUSH") * exp / utils.node("sfpush", "exp")
      + call
      + Rw("return") * exp / utils.node("ret", "exp"),
  lhs = lpeg.Ct(var * (T "[" * exp * T "]") ^ 0) / utils.foldIndex,
  call = ID * T "(" * args * T ")" / utils.node("call", "fname", "args"),
  args = lpeg.Ct((exp * (T "," * exp) ^ 0) ^ -1),
  factor = Rw("new") * T "[" * exp * T "]" / utils.node("new", "size")
      + numeral
      + text
      + bool
      + T "(" * exp * T ")"
      + call
      + lhs,
  term0 = lpeg.Ct(factor * (opP * factor) ^ 0) / utils.foldBin,
  term1 = lpeg.Ct(term0 * ((opR + opM) * term0) ^ 0) / utils.foldBin,
  term2 = lpeg.Ct(term1 * (opA * term1) ^ 0) / utils.foldBin,
  exp = lpeg.Ct(term2 *
        ((opLessThen + opGreaterThen + opLessOrEqualThen + opGreaterOrEqualThen + opEqualThen + opNotEqualThen) * term2) ^
        0) /
      utils.foldBin,
  space = (lpeg.S(" \t\n") + comments) ^ 0
      * lpeg.P(function(a, p)
        maxmatch = math.max(maxmatch, p)
        err_line_nr = utils.get_err_line(a, p, err_line_nr);

        return true
      end),
  ID = (lpeg.C(alpha * alphanum ^ 0) - excluded) * space,
  IDT = ((lpeg.C(alpha * alphanum ^ 0) * lpeg.P("_") * types) - excluded) * space
}

local grammar = lpeg.P(grammar_table)
local gram = require('pegdebug').trace(grammar_table)

local function parse(input)
  local res = grammar:match(input)
  if (not res) then
    utils.syntaxError(input, maxmatch, err_line_nr)
    os.exit(1)
  end
  return res
end

--- COMPILER ---
----------------

local function compile(ast)
  Compiler:fixFwdDeclaration(ast)

  for i = 1, #ast do
    Compiler:codeFunction(ast[i])
  end
  local main = Compiler.funcs["main"]
  if not main then
    error("no function 'main'")
  end
  return main.code
end

--- INTERPRETER ---
-------------------

local function run(code, mem, stack, top, sapi)
  local pc = 1
  local base = top
  while true do
    local comp_result = 0
    --[[
  io.write("--> ")
  for i = 1, top do io.write(stack[i], " ") end
  io.write("\n", code[pc], "\n")
  --]]
    if code[pc] == "ret" then
      local n = code[pc + 1] -- number of active local variables
      stack[top - n] = stack[top]
      top = top - n
      return top
    elseif code[pc] == "call" then
      pc = pc + 1
      local code = code[pc]
      top = run(code, mem, stack, top)
    elseif code[pc] == "pop" then
      pc = pc + 1
      top = top - code[pc]
    elseif code[pc] == "print" then
      if (type(stack[top]) == "table") then
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
      if (stack[top - 1] < tonumber(stack[top])) then
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
    elseif code[pc] == "loadL" then
      pc = pc + 1
      local n = code[pc]
      top = top + 1
      stack[top] = stack[base + n]
    elseif code[pc] == "storeL" then
      pc = pc + 1
      local n = code[pc]
      stack[base + n] = stack[top]
      top = top - 1
    elseif code[pc] == "load" then
      pc = pc + 1
      local id = code[pc]
      top = top + 1
      stack[top] = mem[id]
    elseif code[pc] == "store" then
      -- $stack_name'stack pos
      if type(stack[top]) == "string" then
        if string.sub(stack[top]:gsub('"', ''), 1, 1) == "$" then
          local pos = string.find(stack[top], "'")
          local stackname = string.sub(stack[top], 3, pos - 1)
          local stackpos = string.sub(stack[top], pos + 1, #stack[top] - 1)

          if stackpos == "tos" then
            stack[top] = sapi:getStack(stackname):peekLast()
          else
            stack[top] = sapi:getStack(stackname):peek(tonumber(stackpos))
          end
        end
      end

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
    elseif code[pc] == "spush" then
      sapi:getStack(current_stack):push(stack[top])
    elseif code[pc] == "spop" then
      sapi:getStack(current_stack):pop()
    elseif code[pc] == "sdepth" then
      sapi:getStack(current_stack):push(sapi:getStack(current_stack):depth())
    elseif code[pc] == "speek" then
      print(sapi:getStack(current_stack):peek(tonumber(stack[top])))
    elseif code[pc] == "sdrop" then
      sapi:getStack(current_stack):pop()
    elseif code[pc] == "sdup" then
      sapi:getStack(current_stack):dup()
    elseif code[pc] == "sswap" then
      sapi:getStack(current_stack):swap()
    elseif code[pc] == "sover" then
      sapi:getStack(current_stack):over()
    elseif code[pc] == "srot" then
      sapi:getStack(current_stack):rot()
    elseif code[pc] == "sminrot" then
      sapi:getStack(current_stack):minrot()
    elseif code[pc] == "s2drop" then
      sapi:getStack(current_stack):twodrop()
    elseif code[pc] == "s2swap" then
      sapi:getStack(current_stack):twoswap()
    elseif code[pc] == "s2dup" then
      sapi:getStack(current_stack):dup()
      sapi:getStack(current_stack):dup()
    elseif code[pc] == "s2over" then
      sapi:getStack(current_stack):twoover()
    elseif code[pc] == "stuck" then
      sapi:getStack(current_stack):tuck()
    elseif code[pc] == "s2rot" then
      sapi:getStack(current_stack):tworot()
    elseif code[pc] == "s2minrot" then
      sapi:getStack(current_stack):twominrot()
    elseif code[pc] == "splus" then
      sapi:getStack(current_stack):add()
    elseif code[pc] == "sminus" then
      sapi:getStack(current_stack):minus()
    elseif code[pc] == "smul" then
      sapi:getStack(current_stack):multiply()
    elseif code[pc] == "sdiv" then
      sapi:getStack(current_stack):division()
    elseif code[pc] == "smod" then
      sapi:getStack(current_stack):modulo()
    elseif code[pc] == "srpneval" then
      local rpnops = utils.split_string(sapi:getStack(current_stack):peekLast():gsub('"', ''), " ")
      for i = 1, #rpnops do
        if type(tonumber(rpnops[i])) == "number" then
          sapi:getStack(current_stack):push(rpnops[i])
        end
        if rpnops[i] == "+" then
          sapi:getStack(current_stack):add()
        elseif rpnops[i] == "-" then
          sapi:getStack(current_stack):minus()
        elseif rpnops[i] == "*" then
          sapi:getStack(current_stack):multiply()
        elseif rpnops[i] == "/" then
          sapi:getStack(current_stack):division()
        elseif rpnops[i] == "%" then
          sapi:getStack(current_stack):modulo()
        end
      end
    elseif code[pc] == "seval" then
      local params = sapi:getStack(current_stack):peekLast()
      sapi:getStack(current_stack):pop()
      local fs = load(sapi:getStack(current_stack):peekLast():gsub('"', ''))(params)
      sapi:getStack(current_stack):pop()
      sapi:getStack(current_stack):push(fs)
    elseif code[pc] == "sprint" then
      print(sapi:getStack(current_stack):printData())
    elseif code[pc] == "tosprint" then
      local s = sapi:getStack(current_stack):peekLast()
      if type(s) == "string" then
        print(string.sub(s, 2, string.len(s) - 1))
      else
        print(s)
      end
    elseif code[pc] == "sinput" then
      local ins = io.read()
      sapi:getStack(current_stack):push(ins)
    elseif code[pc] == "sfpush" then
      local fname = stack[top]:gsub('"', '')
      local f = io.open(fname, "rb")
      local data = f:read("*all")
      f:close()
      sapi:getStack(current_stack):push(data)
    elseif code[pc] == "suse" then
      current_stack = stack[top]:gsub('"', '')
      if DEBUG then
        print("current_stack: " .. current_stack)
      end
    elseif code[pc] == "sadd" then
      sapi:adde(stack[top]:gsub('"', ''))
    elseif code[pc] == "srm" then
      sapi:remove(stack[top]:gsub('"', ''))
    elseif code[pc] == "srep" then
      sapi:copy(current_stack, stack[top])
    elseif code[pc] == "sclear" then
      sapi:clear(stack[top]:gsub('"', ''))
    elseif code[pc] == "sra" then
      sapi:removeall()
    else
      error("unknown instruction" .. code[pc])
    end
    pc = pc + 1
  end
end


local sapi = StackApi:new()
current_stack = "default";
input = ""

if arg[1] == "-i" then
  input = io.read("a")
else
  local f = assert(io.open(arg[1], "r"))
  input = f:read("*all")
  f:close()
end

--print(lpeg.match(lpeg.P(gram), input))

local ast = parse(input)
--print(pt.pt(ast))

local code = compile(ast)
--print(pt.pt(code))

local stack = {}
local mem = {}
run(code, mem, stack, 0, sapi)
