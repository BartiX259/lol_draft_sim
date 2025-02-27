local tether = {}

function tether:__call(context)
  local dir = context.closest_enemy.pos - context.champ.pos
  local mag = dir:mag() - context.champ.range;
  if mag > 0 then
    mag = math.min(math.sqrt(mag), 15)
  else
    mag = math.max(mag, -40)
  end
  return dir:normalize() * mag
end

return setmetatable(tether, tether)
