local ability = require("util.ability")
local ranged = {}

function ranged.new(cd, range)
  local self = ability:new(cd)

  function self:cast(context)
    local target = context.closest_enemy
    local dir = (target.pos - context.champ.pos + target.move_dir:normalize() * 20)
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

return setmetatable(ranged, ranged)
