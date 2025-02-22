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
    if dodge_dir:is_zero() then
      return nil
    end
    local target = context.closest_enemy
    local dir = target.pos - context.champ.pos
    local mag = dir:mag()
    dir = dir:normalize()
    local pos
    local x = (mag * mag + champ_range * champ_range - dash_range * dash_range) / (2 * mag)
    if champ_range >= x then
      local h = math.sqrt(champ_range * champ_range - x * x) * (context.champ.random.value > 0.5 and 1 or -1)
      pos = target.pos - dir * x + vec2.new(dir.y, -dir.x) * h
      dir = pos - context.champ.pos
      mag = dir:mag()
      dir = dir:normalize()
    else
      target = nil
      dir = dodge_dir:normalize()
      mag = dash_range
      pos = context.champ.pos + dir * mag
    end

    return {
      target = target,
      pos = pos,
      dir = dir,
      mag = mag
    }
  end

  return self
end

return setmetatable(dash, dash)
