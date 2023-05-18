Stack = {}
Stack.__index = Stack

function Stack:new()
    local self = setmetatable({}, Stack)
    self.stack = {}

    return self
end

function Stack:push(data)
    table.insert(self.stack, data)
end

function Stack:pop()
    table.remove(self.stack, #self.stack)
end

function Stack:clear()
    for i, _ in pairs(self.stack) do self.stack[i] = nil end
end

function Stack:peek(index)
    return self.stack[index]
end

function Stack:peekLast()
    return self.stack[#self.stack]
end

function Stack:getData()
    return self.stack
end

function Stack:printData()
    local tostr = ""
    for _, name in ipairs(self.stack) do
        tostr = tostr .. " " .. name
    end
    io.write(tostr)
end

function Stack:depth()
    return #self.stack
end

function Stack:dup()
    if #self.stack == 0 then
        return nil
    end
    local last = self.stack[#self.stack]
    table.insert(self.stack, last)
end

function Stack:swap()
    if #self.stack < 2 then
        return nil
    end
    local temp = self.stack[#self.stack]
    self.stack[#self.stack] = self.stack[#self.stack - 1]
    self.stack[#self.stack - 1] = temp
end

function Stack:over()
    if #self.stack < 1 then
        return nil
    end
    table.insert(self.stack, self.stack[#self.stack - 1])
end

function Stack:rot()
    if #self.stack < 3 then
        return nil
    end
    local temp = self.stack[#self.stack - 2]
    self.stack[#self.stack - 2] = self.stack[#self.stack - 1]
    self.stack[#self.stack - 1] = self.stack[#self.stack]
    self.stack[#self.stack] = temp
end

function Stack:minrot()
    if #self.stack < 3 then
        return nil
    end

    local temp = self.stack[#self.stack]
    self.stack[#self.stack] = self.stack[#self.stack - 1]
    self.stack[#self.stack - 1] = self.stack[#self.stack - 2]
    self.stack[#self.stack - 2] = temp
end

function Stack:twodrop()
    if #self.stack < 2 then
        return nil
    end

    self:pop()
    self:pop()
end

function Stack:twoswap()
    if #self.stack < 4 then
        return nil
    end

    local temp0 = self.stack[#self.stack]
    local temp1 = self.stack[#self.stack - 1]
    local temp2 = self.stack[#self.stack - 2]
    local temp3 = self.stack[#self.stack - 3]

    self:twodrop()
    self:twodrop()

    self:push(temp1)
    self:push(temp0)
    self:push(temp3)
    self:push(temp2)
end

function Stack:twoover()
    if #self.stack < 4 then
        return nil
    end

    local temp2 = self.stack[#self.stack - 2]
    local temp3 = self.stack[#self.stack - 3]

    self:push(temp3)
    self:push(temp2)
end

function Stack:tuck()
    if #self.stack < 2 then
        return nil
    end

    self:swap()
    self:over()
end

function Stack:tworot()
    if #self.stack < 6 then
        return nil
    end

    local temp0 = self.stack[#self.stack]
    local temp1 = self.stack[#self.stack - 1]
    local temp2 = self.stack[#self.stack - 2]
    local temp3 = self.stack[#self.stack - 3]
    local temp4 = self.stack[#self.stack - 4]
    local temp5 = self.stack[#self.stack - 5]

    self.stack[#self.stack] = temp4
    self.stack[#self.stack - 1] = temp5
    self.stack[#self.stack - 2] = temp0
    self.stack[#self.stack - 3] = temp1
    self.stack[#self.stack - 4] = temp3
    self.stack[#self.stack - 5] = temp2
end

function Stack:twominrot()
    if #self.stack < 6 then
        return nil
    end

    local temp0 = self.stack[#self.stack]
    local temp1 = self.stack[#self.stack - 1]
    local temp2 = self.stack[#self.stack - 2]
    local temp3 = self.stack[#self.stack - 3]
    local temp4 = self.stack[#self.stack - 4]
    local temp5 = self.stack[#self.stack - 5]

    self.stack[#self.stack] = temp3
    self.stack[#self.stack - 1] = temp2
    self.stack[#self.stack - 2] = temp5
    self.stack[#self.stack - 3] = temp4
    self.stack[#self.stack - 4] = temp1
    self.stack[#self.stack - 5] = temp0
end

function Stack:stackCleanForOp()
    table.remove(self.stack, #self.stack)
    table.remove(self.stack, #self.stack)
end

function Stack:add()
    if #self.stack < 2 then
        return nil
    end

    local res = self.stack[#self.stack] + self.stack[#self.stack - 1]
    self:stackCleanForOp()
    table.insert(self.stack, res)
end

function Stack:minus()
    if #self.stack < 2 then
        return nil
    end

    local res = self.stack[#self.stack] - self.stack[#self.stack - 1]
    self:stackCleanForOp()
    table.insert(self.stack, res)
end

function Stack:multiply()
    if #self.stack < 2 then
        return nil
    end

    local res = self.stack[#self.stack] * self.stack[#self.stack - 1]
    self:stackCleanForOp()
    table.insert(self.stack, res)
end

function Stack:division()
    if #self.stack < 2 then
        return nil
    end

    local res = self.stack[#self.stack] / self.stack[#self.stack - 1]
    self:stackCleanForOp()
    table.insert(self.stack, res)
end

function Stack:modulo()
    if #self.stack < 2 then
        return nil
    end

    local res = self.stack[#self.stack] % self.stack[#self.stack - 1]
    self:stackCleanForOp()
    table.insert(self.stack, res)
end
