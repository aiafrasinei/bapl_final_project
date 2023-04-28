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
