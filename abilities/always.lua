local ability = require("util.ability")

local always = {}

function always.new()
  local self = ability:new(0)

  function self:tick()
      return true
  end
  
  function self:cast()
    return true
  end

  return self
end

return setmetatable(always, always)
