local ability = require("util.ability")
local distances = require("util.distances")
local big = {}

function big.new(cd, range, size)
  local self = ability:new(cd)

  function self:cast(context)
    local clump = distances.find_clump(context.champ, context.enemies, range, size)
    local target = clump.target
    if target == nil then
      return nil
    end
    local dir = (target.pos - context.champ.pos)
    local mag = dir:mag()
    local res = {
      target = target,
      pos = target.pos,
      dir = dir:normalize(),
      mag = mag
    }
    local enemy_count = #context.enemies
    if clump.count >= math.clamp(enemy_count - 1, 2, 3) then
      return res
    end
    if mag < range / 3 then
      return res
    end
    return nil
  end

  return self
end

return setmetatable(big, big)
