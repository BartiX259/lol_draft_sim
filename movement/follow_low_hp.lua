local vec2 = require("util.vec2")

local follow_low_hp = {}

function follow_low_hp:__call(context)
  local dir = vec2.new(0, 0)
  for _, enemy in pairs(context.enemies) do
    local mag = 1 - enemy.health / enemy.max_health
    dir = dir + (enemy.pos - context.champ.pos):softinv(20 * mag)
  end

  return dir
end

return setmetatable(follow_low_hp, follow_low_hp)
