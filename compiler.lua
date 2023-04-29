local pt = require "pt"

local Compiler = { funcs = {}, vars = {}, nvars = 0 }

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

function Compiler:codeCall(ast)
  local func = self.funcs[ast.fname]
  if not func then
    error("undefined function " .. fname)
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
  elseif ast.tag == "call" then
    self:codeCall(ast)
  elseif ast.tag == "variable" then
    self:addCode("load")
    --ALEX TODO
    --if ast.val == nil then
    --  self:addCode(ast.var)
    --else
    self:addCode(self:var2num(ast.var))
    --end
  elseif ast.tag == "indexed" then
    self:codeExp(ast.array)
    self:codeExp(ast.index)
    self:addCode("getarray")
  elseif ast.tag == "new" then
    self:codeExp(ast.size)
    self:addCode("newarray")
  elseif ast.tag == "binop" then
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
    -- ALEX TODO
    self:codeExp(ast.exp)
    self:addCode("store")
    self:addCode(self:var2num(lhs.var))
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
  self:codeStat(ast.body)
end

function Compiler:codeStat(ast)
  if ast.tag == "assgn" then
    self:codeAssgn(ast)
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
  elseif ast.tag == "sdrop" then
    self:addCode("sdrop")
  elseif ast.tag == "not" then
    self:codeExp(ast.exp)
    self:addCode("not")
  elseif ast.tag == "suse" then
    self:codeExp(ast.exp)
    self:addCode("suse")
  elseif ast.tag == "while1" then
    local ilabel = self:currentPosition()
    self:codeExp(ast.cond)
    local jmp = self:codeJmpF("jmpZ")
    self:codeStat(ast.body)
    self:codeJmpB("jmp", ilabel)
    self:fixJmp2here(jmp)
  elseif ast.tag == "if1" then
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
  self.funcs[ast.name] = { code = code }
  self.code = code
  self:codeStat(ast.body)
  self:addCode("push")
  self:addCode(0)
  self:addCode("ret")
end

return Compiler
