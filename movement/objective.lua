local vec2 = require("util.vec2")
local objective = {}

function objective:__call(context)
  local dir = vec2.new(0, 0) - context.champ.pos
  return dir:softcap(30)
end

return setmetatable(objective, objective)
