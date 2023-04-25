local utils = {}

function utils.node (tag, ...)
    local labels = table.pack(...)
    local params = table.concat(labels, ", ")
    local fields = string.gsub(params, "(%w+)", "%1 = %1")
    local code = string.format(
      "return function (%s) return {tag = '%s', %s} end",
      params, tag, fields)
    return assert(load(code))()
  end

  function utils.nodeSeq (st1, st2)
    if st2 == nil then
      return st1
    else
      return {tag = "seq", st1 = st1, st2 = st2}
    end
  end

  return utils