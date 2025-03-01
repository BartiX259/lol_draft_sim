local vec2 = require("util.vec2")

local follow_cc = {}

function follow_cc:__call(context)
  local dir = vec2.new(0, 0)
  for _, enemy in pairs(context.enemies) do
if enemy:has_effect("root") then
      dir = dir + (enemy.pos - context.champ.pos):softinv(20)
    elseif enemy:has_effect("slow") then
      dir = dir + (enemy.pos - context.champ.pos):softinv(8)
    elseif enemy:has_effect("silence") then
      dir = dir + (enemy.pos - context.champ.pos):softinv(5)
    end
  end

  return dir
end

return setmetatable(follow_cc, follow_cc)
