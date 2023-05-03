local utils = {}

--- FRONTEND ---
----------------

-- Convert a list {n1, "+", n2, "+", n3, ...} into a tree
-- {...{ op = "+", e1 = {op = "+", e1 = n1, n2 = n2}, e2 = n3}...}
function utils.foldBin(lst)
  local tree = lst[1]
  for i = 2, #lst, 2 do
    tree = { tag = "binop", e1 = tree, op = lst[i], e2 = lst[i + 1] }
  end
  return tree
end

function utils.foldIndex(lst)
  local tree = lst[1]
  for i = 2, #lst do
    tree = { tag = "indexed", array = tree, index = lst[i] }
  end
  return tree
end

function utils.node(tag, ...)
  local labels = table.pack(...)
  local params = table.concat(labels, ", ")
  local fields = string.gsub(params, "(%w+)", "%1 = %1")

  local code = string.format(
    "return function (%s) return {tag = '%s', %s} end",
    params, tag, fields)
  return assert(load(code))()
end

function utils.nodeSeq(st1, st2)
  if st2 == nil then
    return st1
  else
    return { tag = "seq", st1 = st1, st2 = st2 }
  end
end

function utils.syntaxError(input, max, err_line_nr)
  io.stderr:write("syntax error (line " .. err_line_nr .. ") : \n")
  io.stderr:write(string.sub(input, max, string.find(input, "\n", max, true)), "\n")
end

function utils.neg(nr)
  if nr == 0 then
    return 1
  else
    return 0
  end
end

function utils.get_err_line(a, p, err_line_index)
  local ret = 1
  local once = true
  local eoli = {}

  if once then
    while (true)
    do
      ret, _ = string.find(a, "\n", ret + 1, true)
      eoli[#eoli + 1] = ret
      if ret == nil then
        break
      end
    end
    once = false
  end

  if string.sub(a, p, p) == ";" then
    for i = 1, #eoli do
      ret, _ = string.find(a, "\n", p, true)
      if eoli[i] == ret then
        err_line_index = i;
      end
    end
  end

  return err_line_index
end

function utils.assign_type_check_err_str(var, type, tag)
  return "ERR: Type check failed on assign, (var: " .. var .. " type: " .. type .. ") attempt to assign " .. tag
end

function utils.comparison_type_check_err_str(var1, var2)
  return "ERR: Type check failed on if comparison, (var: " ..
      var1.var .. " type: " .. var1.type .. ") with " .. "(var: " ..
      var2.var .. " type: " .. var2.type .. ")"
end

return utils
