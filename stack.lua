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
    self.stack[#self.stack] = nil
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
