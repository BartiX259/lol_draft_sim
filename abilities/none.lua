local none = {}

function none.new()
  local self = {}

  function self:tick()
    return false
  end

  return self
end

return setmetatable(none, none)
