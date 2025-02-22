local ability = require("util.ability")
local buff = {}

function buff.new(cd, range)
  local self = ability:new(cd)

  function self:cast(context)
    local target = context.closest_ally
    if target == nil then
      target = context.champ
    end
    local dir = (target.pos - context.champ.pos)
    local mag = dir:mag()
    if mag > range then
      return nil
    end
    return {
      target = target,
      pos = target.pos,
      dir = dir:normalize(),
      mag = mag
    }
  end

  return self
end

return setmetatable(buff, buff)
