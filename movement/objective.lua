local vec2 = require("util.vec2")
local objective = {}

function objective:__call(context)
  local cap = math.abs(context.capture)
  local dir = vec2.new(0, 0) - context.champ.pos
  local free = math.clamp(context.closest_dist / (dir:mag() + 100), 0, 1)
  return dir:softcap(30 + cap * 30) * (1+cap) * (1+free)
end

return setmetatable(objective, objective)
