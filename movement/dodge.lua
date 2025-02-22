local vec2 = require("util.vec2")

local dodge = {}

function dodge:__call(context)
  local dir = vec2.new(0, 0)
  for _, projectile in pairs(context.projectiles) do
    dir = dir + projectile:dodge_dir(context.champ)
  end
  return dir:softcap(40)
end

return setmetatable(dodge, dodge)
