local dump = {}

local function dump_local(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) == 'table' then
        k = ' ' .. dump_local(k) .. ' '
      elseif type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. dump_local(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function dump.dump(o)
  print(dump_local(o))
end

return dump
