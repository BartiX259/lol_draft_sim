local engage = {}

function engage:__call(context)
  local dir = context.closest_enemy.pos - context.champ.pos
  return dir:softcap(20)
end

return setmetatable(engage, engage)
