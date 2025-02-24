local tank = {}

function tank:__call(context)
  local point = (context.allies_avg_pos + context.enemies_avg_pos) / 2
  local dir = point - context.champ.pos

  return dir:softcap(20)
end

return setmetatable(tank, tank)
