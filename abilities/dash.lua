local ability = require("util.ability")
local vec2 = require("util.vec2")
local dash = {}

function dash.new(cd, dash_range, champ_range)
  local self = ability:new(cd)

  function self:cast(context)
    local dodge_dir = vec2.new(0, 0)
    for _, projectile in pairs(context.projectiles) do
      dodge_dir = dodge_dir + projectile:dodge_dir(context.champ)
    end
    if dodge_dir:is_zero() and context.closest_dist > champ_range / 2 then
      return nil
    end
    local target = context.closest_enemy
    local dir = target.pos - context.champ.pos
    local mag = dir:mag()
    dir = dir:normalize()
    dodge_dir = dodge_dir:normalize()
    local fallback = {
      dir = dodge_dir,
      mag = dash_range,
      pos = context.champ.pos + dodge_dir * dash_range
    }
    local pos
    local x = (mag * mag + champ_range * champ_range - dash_range * dash_range) / (2 * mag)
    if champ_range >= x then
      local h = math.sqrt(champ_range * champ_range - x * x) * (context.champ.random.value > 0.5 and 1 or -1)
      pos = target.pos - dir * x + vec2.new(dir.y, -dir.x) * h
      dir = pos - context.champ.pos
      mag = dir:mag()
      dir = dir:normalize()
      if dir:dot(dodge_dir) < -0.2 then
        return fallback
      end
      return {
        target = target,
        pos = pos,
        dir = dir,
        mag = mag
      }
    else
      return fallback
    end
  end

  return self
end

return setmetatable(dash, dash)
