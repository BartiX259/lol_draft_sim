local vec2 = require("util.vec2")

local follow_team = {}

function follow_team:__call(context)
  local avg = context.allies_avg_pos

  local dir = avg - context.champ.pos

  return dir:softcap(20)
end

return setmetatable(follow_team, follow_team)
