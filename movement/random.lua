local vec2 = require("util.vec2")

local random = {}

function random:__call(context)
  local rand = context.champ.random
  local angle = rand.value * 2 * math.pi

  return vec2.new(math.cos(angle), math.sin(angle)) * 10
end

return setmetatable(random, random)
