local vec2 = require("util.vec2")

local avoid_clumping = {}

function avoid_clumping:__call(context)
  if context.closest_ally == nil then
    return vec2.new(0, 0)
  end
  local dir = context.champ.pos - context.closest_ally.pos
  return dir:softinv(100)
end

return setmetatable(avoid_clumping, avoid_clumping)
