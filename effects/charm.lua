local effect = require("util.effect")
local vec2 = require("util.vec2")
local charm = {}

function charm.new(duration, speed, unit)
  local self = effect.new({ "stun" }, duration)

  function self:tick(context)
    if unit == nil then
      return true
    end
    local dir = unit.pos - context.champ.pos
    context.champ.pos = context.champ.pos + dir:normalize() * speed * context.dt
    return self:base_tick(context)
  end

  return self
end

return charm
