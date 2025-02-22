local ability = require("util.ability")
local damage = require("util.damage")
local melee_aa = {}

function melee_aa.new(cd, range, dmg)
  local self = ability:new(cd)

  function self:ready(context)
    local target = context.closest_enemy
    local dir = (target.pos - context.champ.pos)
    local mag = dir:mag()
    if mag > range then
      return false
    end
    damage:new(dmg, damage.PHYSICAL):deal(context.champ, target)
    return true
  end

  return self
end

return setmetatable(melee_aa, melee_aa)
