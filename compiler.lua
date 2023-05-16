local pt = require "pt"
local utils = require "utils"

local Compiler = { funcs = {}, vars = {}, nvars = 0, locals = {} }

function Compiler:addCode(op)
  local code = self.code
  code[#code + 1] = op
end

local ops = {
  ["+"] = "add",
  ["-"] = "sub",
  ["*"] = "mul",
  ["/"] = "div",
  ["%"] = "mod",
  ["^"] = "pow",
  ["lt"] = "less_then",
  ["gt"] = "greater_then",
  ["le"] = "less_or_equal_then",
  ["ge"] = "greater_or_equal_then",
  ["eq"] = "equal_then",
  ["ne"] = "not_equal_then"
}


function Compiler:var2num(id)
  local num = self.vars[id]
  if not num then
    num = self.nvars + 1
    self.nvars = num
    self.vars[id] = num
  end
  return num
end

function Compiler:currentPosition()
  return #self.code
end

function Compiler:codeJmpB(op, label)
  self:addCode(op)
  self:addCode(label)
end

function Compiler:codeJmpF(op)
  self:addCode(op)
  self:addCode(0)
  return self:currentPosition()
end

function Compiler:fixJmp2here(jmp)
  self.code[jmp] = self:currentPosition()
end

function Compiler:findLocal(name)
  local vars = self.locals
  for i = #vars, 1, -1 do
    if name == vars[i] then
      return i
    end
  end
  local params = self.params
  for i = 1, #params do
    if name == params[i].var then
      return -(#params - i)
    end
  end
  return false -- not found
end

function Compiler:codeCall(ast)
  local func = self.funcs[ast.fname]
  if not func then
    print("ERR: Undefined function " .. ast.fname)
    os.exit(1)
  end
  local args = ast.args
  if #args ~= #func.params then
    print("ERR: Wrong number of arguments calling " .. ast.fname)
    os.exit(1)
  end

  for i = 1, #args do
    self:codeExp(args[i])
  end
  self:addCode("call")
  self:addCode(func.code)
end

function Compiler:codeExp(ast)
  if ast.tag == "number" then
    self:addCode("push")
    self:addCode(ast.val)
  elseif ast.tag == "text" then
    self:addCode("push")
    self:addCode(ast.val)
  elseif ast.tag == "bool" then
    self:addCode("push")
    self:addCode(ast.val)
  elseif ast.tag == "call" then
    self:codeCall(ast)
  elseif ast.tag == "variable" then
    local idx = self:findLocal(ast.var)
    if idx then
      self:addCode("loadL")
      self:addCode(idx)
    else
      self:addCode("load")
      self:addCode(self:var2num(ast.var))
    end
  elseif ast.tag == "indexed" then
    self:codeExp(ast.array)
    self:codeExp(ast.index)
    self:addCode("getarray")
  elseif ast.tag == "new" then
    self:codeExp(ast.size)
    self:addCode("newarray")
  elseif ast.tag == "binop" then
    -- ALEX TODO
    self:codeExp(ast.e1)
    self:codeExp(ast.e2)
    self:addCode(ops[ast.op])
  else
    error("invalid tree")
  end
end

function Compiler:codeAssgn(ast)
  local lhs = ast.lhs
  if lhs.tag == "variable" then
    -- TODO TYPE CHECKING
    if ast.exp.tag == "text" then
      if ast.lhs.type == "e" or ast.lhs.type == "n" or ast.lhs.type == "b" or ast.lhs.type == "f" or ast.lhs.type == "t" then
        print(utils.assign_type_check_err_str(ast.lhs.var, ast.lhs.type, ast.exp.tag))
        os.exit(1)
      end
    elseif ast.exp.tag == "number" then
      if ast.lhs.type == "e" or ast.lhs.type == "s" or ast.lhs.type == "b" or ast.lhs.type == "f" or ast.lhs.type == "t" then
        print(utils.assign_type_check_err_str(ast.lhs.var, ast.lhs.type, ast.exp.tag))
        os.exit(1)
      end
    elseif ast.exp.tag == "bool" then
      if ast.lhs.type == "e" or ast.lhs.type == "s" or ast.lhs.type == "n" or ast.lhs.type == "f" or ast.lhs.type == "t" then
        print(utils.assign_type_check_err_str(ast.lhs.var, ast.lhs.type, ast.exp.tag))
        os.exit(1)
      end
    end

    if ast.exp.tag == "call" then
      if #self.funcs[ast.exp.fname].params ~= #ast.exp.args then
        print("ERR: Function call " .. ast.exp.fname .. " with " ..
          #ast.exp.args .. " parameters (function definition has " .. #self.funcs[ast.exp.fname].params .. ")")
        os.exit(1)
      else
        for i = 1, #ast.exp.args do
          if ast.exp.args[i].tag == 'number' and self.funcs[ast.exp.fname].params[i].type ~= 'n' then
            print("ERR: Function call " ..
              ast.exp.fname ..
              " parameter type mismatch (expected type: " .. self.funcs[ast.exp.fname].params[i].type .. ")")
            os.exit(1)
          end
          if ast.exp.args[i].tag == 'string' and self.funcs[ast.exp.fname].params[i].type ~= 's' then
            print("ERR: Function call " ..
              ast.exp.fname ..
              " parameter type mismatch (expected type: " .. self.funcs[ast.exp.fname].params[i].type .. ")")
            os.exit(1)
          end
        end
      end

      if self.funcs[ast.exp.fname].ret ~= ast.lhs.type then
        print("ERR: Type check failed on function call, asignement (var: " ..
          ast.lhs.var ..
          " type: " ..
          ast.lhs.type .. ") = (funct: " .. ast.exp.fname .. " type: " .. self.funcs[ast.exp.fname].ret .. ")")
        os.exit(1)
      end
    end

    self:codeExp(ast.exp)
    local idx = self:findLocal(lhs.var)
    if idx then
      self:addCode("storeL")
      self:addCode(idx)
    else
      self:addCode("store")
      self:addCode(self:var2num(lhs.var))
    end
  elseif lhs.tag == "indexed" then
    self:codeExp(lhs.array)
    self:codeExp(lhs.index)
    self:codeExp(ast.exp)
    self:addCode("setarray")
  else
    error("unkown tag")
  end
end

function Compiler:codeBlock(ast)
  local oldlevel = #self.locals
  self:codeStat(ast.body)
  local n = #self.locals - oldlevel -- number of new local variables
  if n > 0 then
    for i = 1, n do table.remove(self.locals) end
    self:addCode("pop")
    self:addCode(n)
  end
end

function Compiler:codeStat(ast)
  if ast.tag == "assgn" then
    self:codeAssgn(ast)
  elseif ast.tag == "local" then
    self:codeExp(ast.init)
    self.locals[#self.locals + 1] = ast.name
  elseif ast.tag == "call" then
    self:codeCall(ast)
    self:addCode("pop")
    self:addCode(1)
  elseif ast.tag == "block" then
    self:codeBlock(ast)
  elseif ast.tag == "seq" then
    self:codeStat(ast.st1)
    self:codeStat(ast.st2)
  elseif ast.tag == "ret" then
    self:codeExp(ast.exp)
    self:addCode("ret")
    self:addCode(#self.locals + #self.params)
  elseif ast.tag == "print" then
    self:codeExp(ast.exp)
    self:addCode("print")
  elseif ast.tag == "spush" then
    self:codeExp(ast.exp)
    self:addCode("spush")
  elseif ast.tag == "spop" then
    self:addCode("spop")
  elseif ast.tag == "sdepth" then
    self:addCode("sdepth")
  elseif ast.tag == "sprint" then
    self:addCode("sprint")
  elseif ast.tag == "speek" then
    self:codeExp(ast.exp)
    self:addCode("speek")
  elseif ast.tag == "sdup" then
    self:addCode("sdup")
  elseif ast.tag == "sover" then
    self:addCode("sover")
  elseif ast.tag == "sswap" then
    self:addCode("sswap")
  elseif ast.tag == "sdrop" then
    self:addCode("sdrop")
  elseif ast.tag == "srot" then
    self:addCode("srot")
  elseif ast.tag == "sminrot" then
    self:addCode("sminrot")
  elseif ast.tag == "s2drop" then
    self:addCode("s2drop")
  elseif ast.tag == "s2swap" then
    self:addCode("s2swap")
  elseif ast.tag == "s2dup" then
    self:addCode("s2dup")
  elseif ast.tag == "s2over" then
    self:addCode("s2over")
  elseif ast.tag == "stuck" then
    self:addCode("stuck")
  elseif ast.tag == "s2rot" then
    self:addCode("s2rot")
  elseif ast.tag == "s2minrot" then
    self:addCode("s2minrot")
  elseif ast.tag == "s+" then
    self:addCode("s+")
  elseif ast.tag == "s-" then
    self:addCode("s-")
  elseif ast.tag == "s*" then
    self:addCode("s*")
  elseif ast.tag == "s/" then
    self:addCode("s/")
  elseif ast.tag == "s%" then
    self:addCode("s%")
  elseif ast.tag == "srpneval" then
    self:codeExp(ast.exp)
    self:addCode("srpneval")
  elseif ast.tag == "not" then
    self:codeExp(ast.exp)
    self:addCode("not")
  elseif ast.tag == "suse" then
    self:codeExp(ast.exp)
    self:addCode("suse")
  elseif ast.tag == "sadd" then
    self:codeExp(ast.exp)
    self:addCode("sadd")
  elseif ast.tag == "srm" then
    self:codeExp(ast.exp)
    self:addCode("srm")
  elseif ast.tag == "srep" then
    self:codeExp(ast.exp)
    self:addCode("srep")
  elseif ast.tag == "sclear" then
    self:codeExp(ast.exp)
    self:addCode("sclear")
  elseif ast.tag == "sra" then
    self:addCode("sra")
  elseif ast.tag == "while1" then
    local ilabel = self:currentPosition()
    self:codeExp(ast.cond)
    local jmp = self:codeJmpF("jmpZ")
    self:codeStat(ast.body)
    self:codeJmpB("jmp", ilabel)
    self:fixJmp2here(jmp)
  elseif ast.tag == "if1" then
    if ast.cond.e1 ~= nil and ast.cond.e2 ~= nil then
      if ast.cond.e2.type == "s" then
        if ast.cond.e1.type == "e" or ast.cond.e1.type == "n" or ast.cond.e1.type == "b" or ast.cond.e1.type == "f" or ast.cond.e1.type == "t" then
          print(utils.comparison_type_check_err_str(ast.cond.e1, ast.cond.e2))
          os.exit(1)
        end
      elseif ast.cond.e2.type == "n" then
        if ast.cond.e1.type == "e" or ast.cond.e1.type == "s" or ast.cond.e1.type == "b" or ast.cond.e1.type == "f" or ast.cond.e1.type == "t" then
          print(utils.comparison_type_check_err_str(ast.cond.e1, ast.cond.e2))
          os.exit(1)
        end
      end
    end
    self:codeExp(ast.cond)
    local jmp = self:codeJmpF("jmpZ")
    self:codeStat(ast.th)
    if ast.el == nil then
      self:fixJmp2here(jmp)
    else
      local jmp2 = self:codeJmpF("jmp")
      self:fixJmp2here(jmp)
      self:codeStat(ast.el)
      self:fixJmp2here(jmp2)
    end
  else
    error("invalid tree")
  end
end

function Compiler:codeFunction(ast)
  local code = {}
  self.funcs[ast.name] = { code = code, params = ast.params, ret = ast.type }
  self.code = code
  self.params = ast.params
  self:codeStat(ast.body)
  self:addCode("push")
  self:addCode(0)
  self:addCode("ret")
  self:addCode(#self.locals + #self.params)
end

function Compiler:checkForMultipleFwdDeclaration(ast)
  local dups = {}

  for i = 1, #ast do
    if ast[i].tag == "function" then
      if ast[i].body == nil then
        dups[ast[i].name] = i
      end
    end
  end

  local fwd_errs = false
  for k, v in pairs(dups) do
    if v > 1 then
      fwd_errs = true
      print("ERR: multiple forward declarations for function " .. k)
    end
  end

  if fwd_errs then
    os.exit(1)
  end
end

function Compiler:fixFwdDeclaration(ast)
  Compiler:checkForMultipleFwdDeclaration(ast)

  local duplicates = {}
  local torm = {}

  for i = 1, #ast do
    if ast[i].tag == "function" then
      if ast[i].body == nil then
        duplicates[#duplicates + 1] = { i, ast[i].name }
      else
        for j = 1, #duplicates do
          if ast[i].name == duplicates[j][2] then
            ast[duplicates[j][1]].body = ast[i].body
            torm[#torm + 1] = i
          end
        end
      end
    end
  end

  for i = 1, #torm do
    table.remove(ast, i)
  end
end

return Compiler
