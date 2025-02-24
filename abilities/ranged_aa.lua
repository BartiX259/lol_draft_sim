local ability = require("util.ability")
local damage = require("util.damage")
local missile = require("projectiles.missile")
local ranged_aa = {}

function ranged_aa.new(cd, range, dmg, color)
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
    self.champ = context.champ
    self.proj = missile.new(self, {
      size = 40,
      speed = 1600,
      color = color,
      from = context.champ.pos,
      to = cast.target,
    })
    context.spawn(self.proj)
  end

  function self:hit(target)
    damage:new(dmg, damage.PHYSICAL):deal(self.champ, target)
  end

  return self
end

return setmetatable(ranged_aa, ranged_aa)
