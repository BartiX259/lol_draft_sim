local ability = require("util.ability")
local distances = require("util.distances")
local buff = {}

function buff.new(cd, range)
  local self = ability:new(cd)

  function self:cast(context)
    local min_dist = math.huge
    local target
    for _, ally in pairs(distances.in_range_list(context.champ, context.allies, range)) do
      local dist = ally.pos:distance(context.enemies_avg_pos)
      if dist < min_dist then
        min_dist = dist
        target = ally
      end
    end
    if target == nil then
      return nil
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
