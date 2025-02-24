local retreat = {}

function retreat:__call(context)
  local dir = (context.champ.pos - context.enemies_avg_pos):normalize() * (context.champ.health / context.champ.max_health)

  return dir:softinv(20)
end

return setmetatable(retreat, retreat)
