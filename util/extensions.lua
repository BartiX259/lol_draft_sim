function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function table.copy_items(from, to)
  for k,v in pairs(from) do
    to[k] = v
  end
end

function math.clamp(num, min, max)
  return math.max(math.min(num, max), min)
end
