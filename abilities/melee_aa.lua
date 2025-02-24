local ability = require("util.ability")
local damage = require("util.damage")
local melee_aa = {}

function melee_aa.new(cd, range, dmg)
  local self = ability:new(cd)

  function self:cast(context)
    local target = context.closest_enemy
    local dir = (target.pos - context.champ.pos)
    local mag = dir:mag()
    if mag > range then
      return nil
    end
    return { target = context.closest_enemy }
  end

  function self:use(context, cast)
    damage:new(dmg, damage.PHYSICAL):deal(context.champ, cast.target)
  end

  return self
end

return setmetatable(melee_aa, melee_aa)
