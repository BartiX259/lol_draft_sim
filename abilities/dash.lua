local ability = require("util.ability")
local vec2 = require("util.vec2")
local distances = require("util.distances")
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
    dodge_dir = dodge_dir:is_zero() and (context.champ.pos - context.closest_enemy.pos):normalize() or dodge_dir:normalize()
    local fallback = {
      dir = dodge_dir,
      mag = dash_range,
      pos = context.champ.pos + dodge_dir * dash_range
    }
    local pos = distances.dash_pos(context, dash_range, champ_range)
    if pos then
      local dir = pos - context.champ.pos
      local mag = dir:mag()
      dir = dir:normalize()
      if dir:dot(dodge_dir) < -0.2 then
        return fallback
      end
      return {
        target = context.closest_enemy,
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
